import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/app_database.dart';

/// Generates proactive business insights shown when the Copilot screen opens.
/// All data comes from local SQLite — no internet required.
class CopilotInsightsService {
  final AppDatabase _db;

  CopilotInsightsService(this._db);

  static final _currency = NumberFormat.currency(
    locale: 'en_PH',
    symbol: '₱',
    decimalDigits: 0,
  );

  static String _fmt(double v) => _currency.format(v);

  /// Returns up to 6 actionable insight strings, ordered by priority.
  Future<List<String>> generateInsights() async {
    final insights = <String>[];

    // 1. Overdue payments
    try {
      final overdue = await _db.deliveriesDao.getOverdueDeliveries();
      if (overdue.isNotEmpty) {
        final ids = overdue.map((d) => d.customerId).toSet();
        final total = overdue.fold(0.0, (sum, d) => sum + d.remainingBalance);
        insights.add(
          '${ids.length} customer${ids.length > 1 ? 's have' : ' has'} overdue payments totaling ${_fmt(total)}.',
        );
      }
    } catch (_) {}

    // 2. Missing bottles
    try {
      final txs = await _db.bottleTransactionsDao.getAll();
      var missing = 0;
      for (final t in txs) {
        if (t.transactionType == 'missing') missing += t.quantity;
        if (t.transactionType == 'found') missing -= t.quantity;
      }
      missing = missing.clamp(0, 999999);
      if (missing > 0) {
        insights.add('$missing bottle${missing > 1 ? 's are' : ' is'} currently missing.');
      }
    } catch (_) {}

    // 3. Audit recommendation
    try {
      final latestAudit = await _db.inventoryAuditsDao.getLatest();
      if (latestAudit == null) {
        insights.add('No inventory audit on record — consider running one.');
      } else {
        final days = DateTime.now().difference(latestAudit.auditDate).inDays;
        if (days >= 7) {
          insights.add('Inventory audit is overdue (last done $days days ago).');
        }
      }
    } catch (_) {}

    // 4. Inactive customers (30+ days)
    try {
      final customers = await _db.customersDao.getAll();
      final deliveries = await _db.deliveriesDao.getAll();
      final cutoff = DateTime.now().subtract(const Duration(days: 30));
      final lastDelivery = <String, DateTime>{};
      for (final d in deliveries) {
        if (d.deliveryStatus == 'cancelled') continue;
        final existing = lastDelivery[d.customerId];
        if (existing == null || d.deliveryDate.isAfter(existing)) {
          lastDelivery[d.customerId] = d.deliveryDate;
        }
      }
      final inactiveCount = customers
          .where((c) {
            final last = lastDelivery[c.id];
            return last == null || last.isBefore(cutoff);
          })
          .length;
      if (inactiveCount > 0) {
        insights.add(
          '$inactiveCount customer${inactiveCount > 1 ? 's have' : ' has'} not ordered in 30+ days.',
        );
      }
    } catch (_) {}

    // 5. Tomorrow's deliveries
    try {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day + 1);
      final end = start.add(const Duration(days: 1));
      final tomorrow = await _db.deliveriesDao.getByDateRange(start, end);
      final scheduled = tomorrow
          .where((d) => d.deliveryStatus == 'scheduled' || d.deliveryStatus == 'in_progress')
          .toList();
      if (scheduled.isNotEmpty) {
        insights.add(
          'You have ${scheduled.length} delivery${scheduled.length > 1 ? 'ies' : 'y'} scheduled for tomorrow.',
        );
      }
    } catch (_) {}

    // 6. High bottle balances (top customer)
    try {
      final balances = await _db.bottleTransactionsDao.getCustomerBottleBalances();
      if (balances.isNotEmpty) {
        final top = balances.entries.reduce((a, b) => a.value > b.value ? a : b);
        if (top.value >= 5) {
          final customers = await _db.customersDao.getAll();
          final name = customers
              .cast<dynamic>()
              .firstWhere((c) => c.id == top.key, orElse: () => null)
              ?.name as String?;
          if (name != null) {
            insights.add('$name holds ${top.value} bottle${top.value > 1 ? 's' : ''} — consider follow-up.');
          }
        }
      }
    } catch (_) {}

    // 7. Savings comparison (this month vs last month)
    try {
      final now = DateTime.now();
      final thisStart = DateTime(now.year, now.month, 1);
      final thisEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
      final lastStart = DateTime(now.year, now.month - 1, 1);
      final lastEnd = DateTime(now.year, now.month, 0, 23, 59, 59);

      final costRaw = await _db.settingsDao.getValue(AppConstants.settingCostPerBottle);
      final cost = double.tryParse(costRaw ?? '') ?? AppConstants.defaultCostPerBottle;

      Future<double> periodSavings(DateTime s, DateTime e) async {
        final dels = await _db.deliveriesDao.getByDateRange(s, e);
        final exps = await _db.expensesDao.getByDateRange(s, e);
        final disp = await _db.dispenserSalesDao.getByDateRange(s, e);
        var p = 0.0;
        for (final d in dels) {
          if (d.deliveryStatus != 'cancelled') p += d.quantity * (d.pricePerBottle - cost);
        }
        p += disp.fold(0.0, (s, d) => s + d.amount);
        p -= exps.fold(0.0, (s, e) => s + e.amount);
        return p;
      }

      final thisSavings = await periodSavings(thisStart, thisEnd);
      final lastSavings = await periodSavings(lastStart, lastEnd);
      if (lastSavings != 0) {
        final delta = thisSavings - lastSavings;
        final pct = (delta / lastSavings.abs() * 100).abs();
        if (pct >= 5) {
          final dir = delta >= 0 ? 'increased' : 'decreased';
          insights.add(
            'Savings $dir by ${pct.toStringAsFixed(0)}% compared to last month.',
          );
        }
      }
    } catch (_) {}

    // 8. Total deposits held
    try {
      final depositTotal = await _db.customerDepositsDao.getTotalDepositsHeld();
      if (depositTotal > 0) {
        insights.add('You are holding ${_fmt(depositTotal)} in active customer deposits.');
      }
    } catch (_) {}

    return insights.take(6).toList();
  }
}
