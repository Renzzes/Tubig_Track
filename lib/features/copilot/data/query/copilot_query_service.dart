import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/utils/bottle_verification_utils.dart';
import '../../../customers/domain/entities/customer.dart';
import '../../domain/entities/copilot_intent.dart';
import '../../domain/query/business_query_handler.dart';

/// Built-in query handler. Implements [BusinessQueryHandler] so it can be
/// registered in [QueryHandlerRegistry]. All answers come from live Drift DAOs.
class CopilotQueryService implements BusinessQueryHandler {
  static final _currency = NumberFormat.currency(
    locale: 'en_PH',
    symbol: '₱',
    decimalDigits: 2,
  );

  static final _intents = CopilotIntent.values
      .where((i) => i != CopilotIntent.unknown)
      .toSet();

  static String _fmt(double v) => _currency.format(v);

  // ── BusinessQueryHandler ────────────────────────────────────────────────

  @override
  bool supports(CopilotIntent intent) => _intents.contains(intent);

  @override
  Future<String> handle(
    CopilotIntent intent,
    String question,
    AppDatabase db,
  ) async {
    switch (intent) {
      case CopilotIntent.getSavings:
        return getSavings(db);
      case CopilotIntent.getProfit:
        return getProfit(db);
      case CopilotIntent.getYearlyProfit:
        return getYearlyProfit(db);
      case CopilotIntent.getCompareSavings:
        return getCompareSavings(db);
      case CopilotIntent.getBestMonth:
        return getBestMonth(db);
      case CopilotIntent.getHighestRevenueMonth:
        return getHighestRevenueMonth(db);
      case CopilotIntent.getOverdueCustomers:
        return getOverdueCustomers(db);
      case CopilotIntent.getTopCustomers:
        return getTopCustomers(db);
      case CopilotIntent.getInactiveCustomers:
        final days = _extractDays(question);
        return getInactiveCustomers(db, days: days);
      case CopilotIntent.getRevenueByCustomer:
        return getRevenueByCustomer(db);
      case CopilotIntent.getCustomerStatement:
        final name = _extractName(question);
        return getCustomerStatementSafe(db, name);
      case CopilotIntent.getCustomerProfile:
        final name = _extractName(question);
        return getCustomerProfileSafe(db, name);
      case CopilotIntent.getSpecificCustomerBalance:
        final name = _extractName(question);
        return getSpecificCustomerBalance(db, name);
      case CopilotIntent.getSpecificCustomerBottles:
        final name = _extractName(question);
        return getSpecificCustomerBottles(db, name);
      case CopilotIntent.getCustomersWithDeposits:
        return getCustomersWithDeposits(db);
      case CopilotIntent.getCustomersWithBottlesAndOverdue:
        return getCustomersWithBottlesAndOverdue(db);
      case CopilotIntent.getCustomerMostDeliveries:
        return getCustomerMostDeliveries(db);
      case CopilotIntent.getCustomersNeedingReconciliation:
        return getCustomersNeedingReconciliation(db);
      case CopilotIntent.getNeverVerifiedCustomers:
        return getNeverVerifiedCustomers(db);
      case CopilotIntent.getCustomersWithMissingBottles:
        return getCustomersWithMissingBottles(db);
      case CopilotIntent.getCustomersWithOverdueBalances:
        return getOverdueCustomers(db);
      case CopilotIntent.getTotalCustomerOwnedBottles:
        return getTotalCustomerOwnedBottles(db);
      case CopilotIntent.getCustomerStatementSummary:
        final name = _extractName(question);
        return getCustomerStatementSummarySafe(db, name);
      case CopilotIntent.getWalkInRevenue:
        return getWalkInRevenue(db, question);
      case CopilotIntent.getWalkInRefillsThisMonth:
        return getWalkInRefillsThisMonth(db);
      case CopilotIntent.getWalkInExchangesThisMonth:
        return getWalkInExchangesThisMonth(db);
      case CopilotIntent.compareWalkInsVsDeliveries:
        return compareWalkInsVsDeliveries(db);
      case CopilotIntent.getMissingBottles:
        return getMissingBottles(db);
      case CopilotIntent.getDamagedBottles:
        return getDamagedBottles(db);
      case CopilotIntent.getInventoryStatus:
        return getInventoryStatus(db);
      case CopilotIntent.getCustomerBottles:
        return getCustomerBottles(db);
      case CopilotIntent.getCustomerBalance:
        return getCustomerBalance(db);
      case CopilotIntent.getMonthlyBottlePurchases:
        return getMonthlyBottlePurchases(db);
      case CopilotIntent.getDeliverySummary:
        return getDeliverySummary(db);
      case CopilotIntent.getTodayDeliveries:
        return getTodayDeliveries(db);
      case CopilotIntent.getTomorrowDeliveries:
        return getTomorrowDeliveries(db);
      case CopilotIntent.getUpcomingDeliveries:
        return getUpcomingDeliveriesFormatted(db);
      case CopilotIntent.getWeekDeliveries:
        return getWeekDeliveries(db);
      case CopilotIntent.getDepositStatus:
        return getDepositStatus(db);
      case CopilotIntent.getTotalReceivables:
        return getTotalReceivables(db);
      case CopilotIntent.getMonthlyExpenses:
        return getMonthlyExpenses(db);
      case CopilotIntent.getAuditStatus:
        return getAuditStatus(db);
      case CopilotIntent.getFollowUps:
        return getFollowUps(db);
      case CopilotIntent.getHealthCheck:
        return getHealthCheck(db);
      case CopilotIntent.unknown:
        return "I couldn't understand that question yet.";
    }
  }

  // ── Private helpers ──────────────────────────────────────────────────────

  int _extractDays(String q) {
    final match = RegExp(r'\b(90|60|30)\b').firstMatch(q);
    if (match != null) return int.parse(match.group(1)!);
    return 30;
  }

  String? _extractName(String question) {
    final patterns = [
      RegExp(r'(?:statement|account|profile|history|summary)\s+(?:for|of|ni|para sa)\s+(.+)', caseSensitive: false),
      RegExp(r'(?:show|tingnan|ipakita)\s+(?:customer\s+)?(?:statement|account|summary|profile|history)\s+(?:for|of|ni|para sa)\s+(.+)', caseSensitive: false),
      RegExp(r'tell\s+me\s+about\s+(.+)', caseSensitive: false),
      RegExp(r'how\s+much\s+(?:does|do)\s+(.+?)\s+owe', caseSensitive: false),
      RegExp(r'how\s+many\s+bottles\s+(?:does|do)\s+(.+?)\s+(?:have|hold|has)', caseSensitive: false),
      RegExp(r"(\w+)'s\s+(?:balance|bottles|statement|account|profile)", caseSensitive: false),
      RegExp(r'(?:utang|bayad)\s+ni\s+(.+)', caseSensitive: false),
    ];
    for (final p in patterns) {
      final m = p.firstMatch(question);
      if (m != null) {
        final raw = m.group(1)?.trim() ?? '';
        if (raw.isNotEmpty) {
          final clean = raw.split('?').first.trim();
          return clean[0].toUpperCase() + clean.substring(1);
        }
      }
    }
    return null;
  }

  Future<double> _computeSavingsForPeriod(
    AppDatabase db,
    DateTime start,
    DateTime end,
  ) async {
    final costRaw = await db.settingsDao.getValue(AppConstants.settingCostPerBottle);
    final costPerBottle = double.tryParse(costRaw ?? '') ?? AppConstants.defaultCostPerBottle;

    final deliveries = await db.deliveriesDao.getByDateRange(start, end);
    final expenses = await db.expensesDao.getByDateRange(start, end);
    final dispenser = await db.dispenserSalesDao.getByDateRange(start, end);

    var profit = 0.0;
    for (final d in deliveries) {
      if (d.deliveryStatus == 'cancelled') continue;
      profit += d.quantity * (d.pricePerBottle - costPerBottle);
    }
    profit += dispenser.fold(0.0, (s, d) => s + d.amount);
    for (final w in await db.walkInSalesDao.getByDateRange(start, end)) {
      final qty = _walkInBottlesSold(w);
      profit += qty * (w.pricePerBottle - costPerBottle);
    }
    profit -= expenses.fold(0.0, (s, e) => s + e.amount);
    return profit;
  }

  int _walkInBottlesSold(WalkInSalesTableData row) {
    return switch (row.walkInType) {
      'BUSINESS_BOTTLES' => row.businessOwnedQuantity,
      'CUSTOMER_REFILL' => row.customerOwnedQuantity,
      'EXCHANGE' => row.businessOwnedQuantity,
      _ => row.businessOwnedQuantity,
    };
  }

  Future<String> _customerNotFound(String? name) async =>
      'Customer "${name ?? 'unknown'}" not found. Please check the name and try again.';

  // ── SAVINGS ─────────────────────────────────────────────────────────────

  Future<String> getSavings(AppDatabase db) async {
    final costRaw = await db.settingsDao.getValue(AppConstants.settingCostPerBottle);
    final costPerBottle = double.tryParse(costRaw ?? '') ?? AppConstants.defaultCostPerBottle;

    final deliveries = await db.deliveriesDao.getAll();
    final expenses = await db.expensesDao.getAll();
    final dispenserSales = await db.dispenserSalesDao.getAll();
    final manualAdditions = await db.savingsDao.getTotalContributions();

    var deliveryProfit = 0.0;
    for (final d in deliveries) {
      if (d.deliveryStatus == 'cancelled') continue;
      deliveryProfit += d.quantity * (d.pricePerBottle - costPerBottle);
    }

    var walkInProfit = 0.0;
    for (final w in await db.walkInSalesDao.getAll()) {
      walkInProfit +=
          _walkInBottlesSold(w) * (w.pricePerBottle - costPerBottle);
    }

    final dispenserProfit = dispenserSales.fold(0.0, (sum, s) => sum + s.amount);
    var totalExpenses = 0.0;
    for (final e in expenses) {
      totalExpenses += e.amount;
    }

    final current = deliveryProfit +
        walkInProfit +
        dispenserProfit -
        totalExpenses +
        manualAdditions;
    return 'Your current savings is ${_fmt(current)}.';
  }

  // ── PROFIT (THIS MONTH) ──────────────────────────────────────────────────

  Future<String> getProfit(AppDatabase db) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    final profit = await _computeSavingsForPeriod(db, start, end);
    final monthName = DateFormat('MMMM yyyy').format(now);

    final deliveries = await db.deliveriesDao.getByDateRange(start, end);
    final expenses = await db.expensesDao.getByDateRange(start, end);
    final totalRevenue = deliveries.where((d) => d.deliveryStatus != 'cancelled').fold(0.0, (s, d) => s + d.totalAmount);
    final totalExpenses = expenses.fold(0.0, (s, e) => s + e.amount);

    return 'Profit for $monthName:\n'
        '• Net profit: ${_fmt(profit)}\n'
        '• Revenue: ${_fmt(totalRevenue)}\n'
        '• Expenses: ${_fmt(totalExpenses)}';
  }

  // ── YEARLY PROFIT ────────────────────────────────────────────────────────

  Future<String> getYearlyProfit(AppDatabase db) async {
    final now = DateTime.now();
    final start = DateTime(now.year, 1, 1);
    final end = DateTime(now.year, 12, 31, 23, 59, 59);
    final profit = await _computeSavingsForPeriod(db, start, end);

    final deliveries = await db.deliveriesDao.getByDateRange(start, end);
    final expenses = await db.expensesDao.getByDateRange(start, end);
    final totalRevenue = deliveries.where((d) => d.deliveryStatus != 'cancelled').fold(0.0, (s, d) => s + d.totalAmount);
    final totalExpenses = expenses.fold(0.0, (s, e) => s + e.amount);

    return 'Profit for ${now.year}:\n'
        '• Net profit: ${_fmt(profit)}\n'
        '• Revenue: ${_fmt(totalRevenue)}\n'
        '• Expenses: ${_fmt(totalExpenses)}';
  }

  // ── COMPARE SAVINGS ──────────────────────────────────────────────────────

  Future<String> getCompareSavings(AppDatabase db) async {
    final now = DateTime.now();
    final thisStart = DateTime(now.year, now.month, 1);
    final thisEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    final lastStart = DateTime(now.year, now.month - 1, 1);
    final lastEnd = DateTime(now.year, now.month, 0, 23, 59, 59);

    final thisSavings = await _computeSavingsForPeriod(db, thisStart, thisEnd);
    final lastSavings = await _computeSavingsForPeriod(db, lastStart, lastEnd);
    final delta = thisSavings - lastSavings;
    final pct = lastSavings != 0 ? (delta / lastSavings.abs() * 100).abs() : 0.0;

    final thisMonth = DateFormat('MMMM').format(now);
    final lastMonth = DateFormat('MMMM').format(lastStart);

    final direction = delta >= 0 ? 'increased' : 'decreased';
    return 'Savings Comparison:\n'
        '• $thisMonth: ${_fmt(thisSavings)}\n'
        '• $lastMonth: ${_fmt(lastSavings)}\n'
        '• Savings $direction by ${_fmt(delta.abs())} (${pct.toStringAsFixed(1)}%)';
  }

  // ── BEST MONTH ────────────────────────────────────────────────────────────

  Future<String> getBestMonth(AppDatabase db) async {
    final allDeliveries = await db.deliveriesDao.getAll();
    if (allDeliveries.isEmpty) return 'No delivery data found yet.';

    final costRaw = await db.settingsDao.getValue(AppConstants.settingCostPerBottle);
    final cost = double.tryParse(costRaw ?? '') ?? AppConstants.defaultCostPerBottle;

    final profitByMonth = <String, double>{};
    final revenueByMonth = <String, double>{};
    for (final d in allDeliveries) {
      if (d.deliveryStatus == 'cancelled') continue;
      final key = DateFormat('yyyy-MM').format(d.deliveryDate);
      final profit = d.quantity * (d.pricePerBottle - cost);
      profitByMonth.update(key, (v) => v + profit, ifAbsent: () => profit);
      revenueByMonth.update(key, (v) => v + d.totalAmount, ifAbsent: () => d.totalAmount);
    }

    if (profitByMonth.isEmpty) return 'Not enough data to determine best month.';

    final bestProfitEntry = profitByMonth.entries.reduce((a, b) => a.value > b.value ? a : b);
    final bestRevenueEntry = revenueByMonth.entries.reduce((a, b) => a.value > b.value ? a : b);
    final worstEntry = profitByMonth.entries.reduce((a, b) => a.value < b.value ? a : b);

    String monthLabel(String key) {
      final parts = key.split('-');
      final dt = DateTime(int.parse(parts[0]), int.parse(parts[1]));
      return DateFormat('MMMM yyyy').format(dt);
    }

    return 'Business Performance Summary:\n\n'
        '• Best profit month: ${monthLabel(bestProfitEntry.key)} — ${_fmt(bestProfitEntry.value)}\n'
        '• Best revenue month: ${monthLabel(bestRevenueEntry.key)} — ${_fmt(bestRevenueEntry.value)}\n'
        '• Slowest month: ${monthLabel(worstEntry.key)} — ${_fmt(worstEntry.value)}';
  }

  // ── HIGHEST REVENUE MONTH ────────────────────────────────────────────────

  Future<String> getHighestRevenueMonth(AppDatabase db) async {
    final allDeliveries = await db.deliveriesDao.getAll();
    if (allDeliveries.isEmpty) return 'No delivery data found yet.';

    final revenueByMonth = <String, double>{};
    for (final d in allDeliveries) {
      if (d.deliveryStatus == 'cancelled') continue;
      final key = DateFormat('yyyy-MM').format(d.deliveryDate);
      revenueByMonth.update(key, (v) => v + d.totalAmount, ifAbsent: () => d.totalAmount);
    }

    if (revenueByMonth.isEmpty) return 'No revenue data available.';

    final sorted = revenueByMonth.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final buf = StringBuffer('Top months by revenue:\n\n');
    for (var i = 0; i < sorted.take(5).length; i++) {
      final entry = sorted[i];
      final parts = entry.key.split('-');
      final dt = DateTime(int.parse(parts[0]), int.parse(parts[1]));
      buf.writeln('${i + 1}. ${DateFormat('MMMM yyyy').format(dt)} — ${_fmt(entry.value)}');
    }
    return buf.toString().trim();
  }

  // ── OVERDUE CUSTOMERS ─────────────────────────────────────────────────────

  Future<String> getOverdueCustomers(AppDatabase db) async {
    final overdueDeliveries = await db.deliveriesDao.getOverdueDeliveries();
    if (overdueDeliveries.isEmpty) {
      return 'Great news! No customers have overdue payments.';
    }

    final customers = await db.customersDao.getAll();
    final customerMap = {for (final c in customers) c.id: c.name};

    final balanceByCustomer = <String, double>{};
    for (final d in overdueDeliveries) {
      balanceByCustomer.update(
        d.customerId,
        (v) => v + d.remainingBalance,
        ifAbsent: () => d.remainingBalance,
      );
    }

    final sorted = balanceByCustomer.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final total = sorted.fold(0.0, (sum, e) => sum + e.value);
    final buf = StringBuffer();
    buf.writeln('${sorted.length} customer${sorted.length > 1 ? 's have' : ' has'} unpaid balances totaling ${_fmt(total)}.\n');
    buf.writeln('Top balances:');
    for (final entry in sorted.take(10)) {
      final name = customerMap[entry.key] ?? 'Unknown';
      buf.writeln('• $name — ${_fmt(entry.value)}');
    }
    if (sorted.length > 10) buf.writeln('... and ${sorted.length - 10} more');
    return buf.toString().trim();
  }

  // ── TOP CUSTOMERS ─────────────────────────────────────────────────────────

  Future<String> getTopCustomers(AppDatabase db) async {
    final deliveries = await db.deliveriesDao.getAll();
    final customers = await db.customersDao.getAll();
    if (customers.isEmpty) return 'No customers found.';

    final customerMap = {for (final c in customers) c.id: c.name};
    final revenue = <String, double>{};
    final count = <String, int>{};

    for (final d in deliveries) {
      if (d.deliveryStatus == 'cancelled') continue;
      revenue.update(d.customerId, (v) => v + d.totalAmount, ifAbsent: () => d.totalAmount);
      count.update(d.customerId, (v) => v + 1, ifAbsent: () => 1);
    }

    if (revenue.isEmpty) return 'No delivery data found yet.';

    final sorted = revenue.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final buf = StringBuffer('Your top customers by revenue:\n\n');
    for (var i = 0; i < sorted.take(10).length; i++) {
      final entry = sorted[i];
      final name = customerMap[entry.key] ?? 'Unknown';
      buf.writeln('${i + 1}. $name — ${_fmt(entry.value)} (${count[entry.key]} deliveries)');
    }
    return buf.toString().trim();
  }

  // ── INACTIVE CUSTOMERS ────────────────────────────────────────────────────

  Future<String> getInactiveCustomers(AppDatabase db, {int days = 30}) async {
    final inactive = await _inactiveCustomerList(db, days);
    if (inactive.isEmpty) {
      return 'All customers have ordered within the last $days days.';
    }
    final buf = StringBuffer('${inactive.length} customer${inactive.length > 1 ? 's have' : ' has'} not ordered in $days+ days:\n');
    for (final name in inactive.take(15)) {
      buf.writeln('• $name');
    }
    if (inactive.length > 15) buf.writeln('... and ${inactive.length - 15} more');
    return buf.toString().trim();
  }

  // ── BOTTLE VERIFICATION ───────────────────────────────────────────────────

  Future<String> getCustomersNeedingReconciliation(AppDatabase db) async {
    final customers = _mapCustomers(await db.customersDao.getAll());
    final stale = BottleVerificationUtils.customersNeedingReconciliation(
      customers,
    );
    if (stale.isEmpty) {
      return 'All customers with a recorded physical count were verified within the last $physicalCountVerificationWindowDays days.';
    }
    final buf = StringBuffer(
      '${stale.length} customer${stale.length > 1 ? 's need' : ' needs'} bottle reconciliation (last count over $physicalCountVerificationWindowDays days ago):\n',
    );
    for (final c in stale.take(15)) {
      final days = BottleVerificationUtils.daysSinceLabel(c);
      buf.writeln('• ${c.name} — last count $days ago');
    }
    if (stale.length > 15) buf.writeln('... and ${stale.length - 15} more');
    return buf.toString().trim();
  }

  Future<String> getNeverVerifiedCustomers(AppDatabase db) async {
    final customers = _mapCustomers(await db.customersDao.getAll());
    final unverified = BottleVerificationUtils.neverVerifiedCustomers(
      customers,
    );
    if (unverified.isEmpty) {
      return 'Every customer has at least one recorded physical bottle count.';
    }
    final buf = StringBuffer(
      '${unverified.length} customer${unverified.length > 1 ? 's have' : ' has'} never been physically verified:\n',
    );
    for (final c in unverified.take(15)) {
      buf.writeln('• ${c.name}');
    }
    if (unverified.length > 15) {
      buf.writeln('... and ${unverified.length - 15} more');
    }
    return buf.toString().trim();
  }

  Future<String> getCustomersWithMissingBottles(AppDatabase db) async {
    final customers = _mapCustomers(await db.customersDao.getAll());
    final balances = await db.bottleTransactionsDao.getCustomerBottleBalances();
    final missing = <Customer>[];

    for (final c in customers) {
      final held = balances[c.id] ?? 0;
      final variance = c.bottleVariance(held);
      if (variance != null && variance < 0) missing.add(c);
    }

    if (missing.isEmpty) {
      return 'No customers currently have recorded missing bottles.';
    }

    final buf = StringBuffer(
      '${missing.length} customer${missing.length > 1 ? 's have' : ' has'} missing bottles:\n',
    );
    for (final c in missing.take(15)) {
      final held = balances[c.id] ?? 0;
      final variance = c.bottleVariance(held)!;
      buf.writeln('• ${c.name} — ${variance.abs()} missing (expected ${c.pendingPhysicalBottleCount}, held $held)');
    }
    if (missing.length > 15) {
      buf.writeln('... and ${missing.length - 15} more');
    }
    return buf.toString().trim();
  }

  Future<String> getTotalCustomerOwnedBottles(AppDatabase db) async {
    final customers = _mapCustomers(await db.customersDao.getAll());
    var total = 0;
    var withOwned = 0;
    for (final c in customers) {
      if (c.customerOwnedBottlesHeld > 0) {
        withOwned++;
        total += c.customerOwnedBottlesHeld;
      }
    }
    if (total == 0) {
      return 'No customer-owned bottles are currently tracked.';
    }
    return '$total customer-owned bottle${total > 1 ? 's' : ''} '
        'across $withOwned customer${withOwned > 1 ? 's' : ''}. '
        'These are not included in business inventory.';
  }

  Future<String> getCustomerStatementSummarySafe(
    AppDatabase db,
    String? name,
  ) async {
    if (name == null || name.isEmpty) {
      return 'Please specify a customer name. Example: "Statement summary for Ivy"';
    }
    try {
      return await _buildCustomerStatementSummary(db, name);
    } on StateError {
      return await _customerNotFound(name);
    }
  }

  Future<String> _buildCustomerStatementSummary(
    AppDatabase db,
    String nameLike,
  ) async {
    final customers = await db.customersDao.getAll();
    final row = customers.firstWhere(
      (c) => c.name.toLowerCase().contains(nameLike.toLowerCase()),
      orElse: () => throw StateError('not found'),
    );
    final customer = _mapCustomers([row]).first;
    final depositBalance =
        await db.customerDepositsDao.getBalanceForCustomer(customer.id);
    final balances = await db.bottleTransactionsDao.getCustomerBottleBalances();
    final businessHeld = balances[customer.id] ?? 0;
    final customerOwned = customer.customerOwnedBottlesHeld;
    final totalAtCustomer = businessHeld + customerOwned;

    final deliveries = await db.deliveriesDao.getUnpaidByCustomer(customer.id);
    final unpaid =
        deliveries.fold(0.0, (sum, d) => sum + d.remainingBalance);

    final payments = await db.paymentsDao.getByCustomer(customer.id);
    final totalPaid = payments.fold(0.0, (sum, p) => sum + p.amount);

    return 'Customer Statement Summary: ${customer.name}\n\n'
        'Bottle Summary:\n'
        '• Business-owned held: $businessHeld\n'
        '• Customer-owned held: $customerOwned\n'
        '• Total at customer: $totalAtCustomer\n\n'
        'Financial Summary:\n'
        '• Outstanding balance: ${_fmt(unpaid)}\n'
        '• Deposit balance: ${_fmt(depositBalance)}\n'
        '• Total paid: ${_fmt(totalPaid)}\n\n'
        'Verification: ${BottleVerificationUtils.statusFor(customer).label}\n'
        'Last physical count: ${BottleVerificationUtils.lastPhysicalCountLabel(customer)}';
  }

  Future<String> getWalkInRevenue(AppDatabase db, String question) async {
    final q = question.toLowerCase();
    final isYear =
        q.contains('this year') || q.contains('year') || q.contains('annual');
    final now = DateTime.now();
    late DateTime start;
    late DateTime end;
    if (isYear) {
      start = DateTime(now.year, 1, 1);
      end = DateTime(now.year, 12, 31, 23, 59, 59);
    } else {
      start = DateTime(now.year, now.month, 1);
      end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    }
    final revenue =
        await db.walkInSalesDao.getTotalRevenueForDateRange(start, end);
    final count = await db.walkInSalesDao.getCountForDateRange(start, end);
    if (count == 0) {
      return 'No walk-in operations recorded for this period.';
    }
    final label = isYear ? 'this year' : 'this month';
    return 'Walk-in revenue $label: ${_fmt(revenue)} from $count operation${count > 1 ? 's' : ''}.';
  }

  Future<String> getWalkInRefillsThisMonth(AppDatabase db) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    final count = await db.walkInSalesDao.countByTypeForDateRange(
      'CUSTOMER_REFILL',
      start,
      end,
    );
    if (count == 0) {
      return 'No customer bottle refills recorded this month.';
    }
    return '$count customer bottle refill${count > 1 ? 's' : ''} this month.';
  }

  Future<String> getWalkInExchangesThisMonth(AppDatabase db) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    final count = await db.walkInSalesDao.countByTypeForDateRange(
      'EXCHANGE',
      start,
      end,
    );
    if (count == 0) {
      return 'No bottle exchanges recorded this month.';
    }
    return '$count bottle exchange${count > 1 ? 's' : ''} this month.';
  }

  Future<String> compareWalkInsVsDeliveries(AppDatabase db) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    final walkInRevenue =
        await db.walkInSalesDao.getTotalRevenueForDateRange(start, end);
    final walkInCount =
        await db.walkInSalesDao.getCountForDateRange(start, end);
    final deliveryRevenue =
        await db.deliveriesDao.getTotalSalesForDateRange(start, end);
    final deliveries = await db.deliveriesDao.getByDateRange(start, end);
    return 'This month:\n'
        '• Walk-In: $walkInCount operations, ${_fmt(walkInRevenue)} revenue\n'
        '• Deliveries: ${deliveries.length} completed, ${_fmt(deliveryRevenue)} revenue';
  }

  List<Customer> _mapCustomers(List<CustomersTableData> rows) {
    return rows
        .map(
          (row) => Customer(
            id: row.id,
            name: row.name,
            phone: row.phone,
            address: row.address,
            notes: row.notes,
            pendingPhysicalBottleCount: row.pendingPhysicalBottleCount,
            customerOwnedBottlesHeld: row.customerOwnedBottlesHeld,
            lastPhysicalCountDate: row.lastPhysicalCountDate,
            lastPhysicalCountVerified: row.lastPhysicalCountVerified,
            createdAt: row.createdAt,
          ),
        )
        .toList();
  }

  Future<List<String>> _inactiveCustomerList(AppDatabase db, int days) async {
    final customers = await db.customersDao.getAll();
    final deliveries = await db.deliveriesDao.getAll();
    final cutoff = DateTime.now().subtract(Duration(days: days));

    final lastDelivery = <String, DateTime>{};
    for (final d in deliveries) {
      if (d.deliveryStatus == 'cancelled') continue;
      final existing = lastDelivery[d.customerId];
      if (existing == null || d.deliveryDate.isAfter(existing)) {
        lastDelivery[d.customerId] = d.deliveryDate;
      }
    }

    return customers
        .where((c) {
          final last = lastDelivery[c.id];
          return last == null || last.isBefore(cutoff);
        })
        .map((c) => c.name)
        .toList();
  }

  // ── REVENUE BY CUSTOMER ───────────────────────────────────────────────────

  Future<String> getRevenueByCustomer(AppDatabase db) async {
    final deliveries = await db.deliveriesDao.getAll();
    final customers = await db.customersDao.getAll();
    if (customers.isEmpty) return 'No customers found.';

    final customerMap = {for (final c in customers) c.id: c.name};
    final revenue = <String, double>{};

    for (final d in deliveries) {
      if (d.deliveryStatus == 'cancelled') continue;
      revenue.update(d.customerId, (v) => v + d.totalAmount, ifAbsent: () => d.totalAmount);
    }

    if (revenue.isEmpty) return 'No delivery revenue data found.';

    final sorted = revenue.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.first;
    final buf = StringBuffer(
      '${customerMap[top.key] ?? 'Unknown'} generates the highest revenue (${_fmt(top.value)}).\n\nTop 5 by lifetime revenue:\n',
    );
    for (var i = 0; i < sorted.take(5).length; i++) {
      final entry = sorted[i];
      buf.writeln('${i + 1}. ${customerMap[entry.key] ?? 'Unknown'} — ${_fmt(entry.value)}');
    }
    return buf.toString().trim();
  }

  // ── CUSTOMER STATEMENT ────────────────────────────────────────────────────

  Future<String> getCustomerStatementSafe(AppDatabase db, String? name) async {
    if (name == null || name.isEmpty) {
      return 'Please specify a customer name. Example: "statement for Ivy"';
    }
    try {
      return await _buildCustomerCard(db, name, title: 'Customer Statement');
    } on StateError {
      return await _customerNotFound(name);
    }
  }

  // ── CUSTOMER PROFILE ─────────────────────────────────────────────────────

  Future<String> getCustomerProfileSafe(AppDatabase db, String? name) async {
    if (name == null || name.isEmpty) {
      return 'Please specify a customer name. Example: "Tell me about Ivy"';
    }
    try {
      return await _buildCustomerCard(db, name, title: 'Customer Profile');
    } on StateError {
      return await _customerNotFound(name);
    }
  }

  Future<String> _buildCustomerCard(
    AppDatabase db,
    String nameLike, {
    required String title,
  }) async {
    final customers = await db.customersDao.getAll();
    final customer = customers.firstWhere(
      (c) => c.name.toLowerCase().contains(nameLike.toLowerCase()),
      orElse: () => throw StateError('not found'),
    );

    final deliveries = await db.deliveriesDao.getByCustomer(customer.id);
    final depositBalance = await db.customerDepositsDao.getBalanceForCustomer(customer.id);
    final bottleBalances = await db.bottleTransactionsDao.getCustomerBottleBalances();
    final bottleBalance = bottleBalances[customer.id] ?? 0;

    var totalRevenue = 0.0;
    var unpaidBalance = 0.0;
    DateTime? lastDelivery;
    var completedCount = 0;

    for (final d in deliveries) {
      if (d.deliveryStatus == 'cancelled') continue;
      completedCount++;
      totalRevenue += d.totalAmount;
      if (d.paymentStatus == 'unpaid' || d.paymentStatus == 'partial') {
        unpaidBalance += d.remainingBalance;
      }
      if (lastDelivery == null || d.deliveryDate.isAfter(lastDelivery)) {
        lastDelivery = d.deliveryDate;
      }
    }

    final paymentStatus = unpaidBalance > 0 ? 'Has unpaid balance' : 'Fully paid';

    return '$title: ${customer.name}\n\n'
        'Bottle Summary:\n'
        '• Business-owned held: $bottleBalance\n'
        '• Customer-owned held: ${customer.customerOwnedBottlesHeld}\n'
        '• Total at customer: ${bottleBalance + customer.customerOwnedBottlesHeld}\n\n'
        'Financial Summary:\n'
        '• Outstanding balance: ${_fmt(unpaidBalance)}\n'
        '• Deposit balance: ${_fmt(depositBalance)}\n'
        '• Total paid: ${_fmt(totalRevenue - unpaidBalance)}\n\n'
        '• Lifetime revenue: ${_fmt(totalRevenue)}\n'
        '• Total deliveries: $completedCount\n'
        '• Last delivery: ${lastDelivery != null ? DateFormat('MMM d, yyyy').format(lastDelivery) : 'None'}\n'
        '• Payment status: $paymentStatus\n'
        '• Verification: ${BottleVerificationUtils.statusFor(_mapCustomers([customer]).first).label}';
  }

  // ── SPECIFIC CUSTOMER BALANCE ─────────────────────────────────────────────

  Future<String> getSpecificCustomerBalance(AppDatabase db, String? name) async {
    if (name == null || name.isEmpty) {
      return 'Please specify a customer name. Example: "How much does Ivy owe?"';
    }
    final customers = await db.customersDao.getAll();
    final customer = customers.cast<dynamic>().firstWhere(
      (c) => c.name.toString().toLowerCase().contains(name.toLowerCase()),
      orElse: () => null,
    );
    if (customer == null) return await _customerNotFound(name);

    final deliveries = await db.deliveriesDao.getUnpaidByCustomer(customer.id as String);
    final balance = deliveries.fold(0.0, (sum, d) => sum + d.remainingBalance);
    if (balance == 0) {
      return '${customer.name} has no outstanding balance.';
    }
    return '${customer.name} owes ${_fmt(balance)}.\n'
        '(${deliveries.length} unpaid/partial delivery${deliveries.length > 1 ? 'ies' : 'y'})';
  }

  // ── SPECIFIC CUSTOMER BOTTLES ─────────────────────────────────────────────

  Future<String> getSpecificCustomerBottles(AppDatabase db, String? name) async {
    if (name == null || name.isEmpty) {
      return 'Please specify a customer name. Example: "How many bottles does Shierly have?"';
    }
    final customers = await db.customersDao.getAll();
    final customer = customers.cast<dynamic>().firstWhere(
      (c) => c.name.toString().toLowerCase().contains(name.toLowerCase()),
      orElse: () => null,
    );
    if (customer == null) return await _customerNotFound(name);

    final balances = await db.bottleTransactionsDao.getCustomerBottleBalances();
    final count = balances[customer.id as String] ?? 0;
    if (count == 0) {
      return '${customer.name} is not currently holding any bottles.';
    }
    return '${customer.name} currently holds $count bottle${count > 1 ? 's' : ''}.';
  }

  // ── CUSTOMERS WITH DEPOSITS ───────────────────────────────────────────────

  Future<String> getCustomersWithDeposits(AppDatabase db) async {
    final allDeposits = await db.customerDepositsDao.getAll();
    final customers = await db.customersDao.getAll();
    final customerMap = {for (final c in customers) c.id: c.name};

    final balances = <String, double>{};
    for (final d in allDeposits) {
      switch (d.transactionType) {
        case 'deposit_added':
          balances.update(d.customerId, (v) => v + d.amount, ifAbsent: () => d.amount);
        case 'deposit_used':
          balances.update(d.customerId, (v) => v - d.amount, ifAbsent: () => -d.amount);
        case 'deposit_adjustment':
          balances.update(d.customerId, (v) => v + d.amount, ifAbsent: () => d.amount);
      }
    }

    final withDeposits = balances.entries.where((e) => e.value > 0.001).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (withDeposits.isEmpty) {
      return 'No customers currently have active deposits.';
    }

    final total = withDeposits.fold(0.0, (sum, e) => sum + e.value);
    final buf = StringBuffer(
      '${withDeposits.length} customer${withDeposits.length > 1 ? 's have' : ' has'} active deposits '
      '(total: ${_fmt(total)}):\n',
    );
    for (final entry in withDeposits.take(10)) {
      final name = customerMap[entry.key] ?? 'Unknown';
      buf.writeln('• $name — ${_fmt(entry.value)}');
    }
    if (withDeposits.length > 10) buf.writeln('... and ${withDeposits.length - 10} more');
    return buf.toString().trim();
  }

  // ── CUSTOMERS WITH BOTTLES AND OVERDUE ────────────────────────────────────

  Future<String> getCustomersWithBottlesAndOverdue(AppDatabase db) async {
    final overdueDeliveries = await db.deliveriesDao.getOverdueDeliveries();
    final bottleBalances = await db.bottleTransactionsDao.getCustomerBottleBalances();
    final customers = await db.customersDao.getAll();
    final customerMap = {for (final c in customers) c.id: c.name};

    final overdueBalances = <String, double>{};
    for (final d in overdueDeliveries) {
      overdueBalances.update(d.customerId, (v) => v + d.remainingBalance, ifAbsent: () => d.remainingBalance);
    }

    // Customers with BOTH overdue balance AND bottles
    final combined = <String, Map<String, dynamic>>{};
    for (final id in overdueBalances.keys) {
      if (bottleBalances.containsKey(id)) {
        combined[id] = {
          'balance': overdueBalances[id]!,
          'bottles': bottleBalances[id]!,
        };
      }
    }

    if (combined.isEmpty) {
      return 'No customers have both overdue payments and unreturned bottles.';
    }

    final sorted = combined.entries.toList()
      ..sort((a, b) => (b.value['balance'] as double).compareTo(a.value['balance'] as double));

    final buf = StringBuffer(
      '${combined.length} customer${combined.length > 1 ? 's have' : ' has'} both overdue payments and unreturned bottles:\n',
    );
    for (final entry in sorted.take(10)) {
      final name = customerMap[entry.key] ?? 'Unknown';
      final balance = entry.value['balance'] as double;
      final bottles = entry.value['bottles'] as int;
      buf.writeln('• $name — owes ${_fmt(balance)}, holds $bottles bottle${bottles > 1 ? 's' : ''}');
    }
    return buf.toString().trim();
  }

  // ── CUSTOMER MOST DELIVERIES ──────────────────────────────────────────────

  Future<String> getCustomerMostDeliveries(AppDatabase db) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final deliveries = await db.deliveriesDao.getByDateRange(start, end);
    final customers = await db.customersDao.getAll();
    final customerMap = {for (final c in customers) c.id: c.name};

    if (deliveries.isEmpty) {
      return 'No deliveries recorded for ${DateFormat('MMMM yyyy').format(now)}.';
    }

    final count = <String, int>{};
    for (final d in deliveries) {
      if (d.deliveryStatus == 'cancelled') continue;
      count.update(d.customerId, (v) => v + 1, ifAbsent: () => 1);
    }

    if (count.isEmpty) return 'No completed deliveries this month.';

    final sorted = count.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.first;

    final buf = StringBuffer(
      '${customerMap[top.key] ?? 'Unknown'} had the most deliveries this month (${top.value}).\n\nTop customers this month:\n',
    );
    for (var i = 0; i < sorted.take(5).length; i++) {
      final entry = sorted[i];
      buf.writeln('${i + 1}. ${customerMap[entry.key] ?? 'Unknown'} — ${entry.value} delivery${entry.value > 1 ? 'ies' : 'y'}');
    }
    return buf.toString().trim();
  }

  // ── MISSING BOTTLES ───────────────────────────────────────────────────────

  Future<String> getMissingBottles(AppDatabase db) async {
    final txs = await db.bottleTransactionsDao.getAll();
    var missing = 0;
    for (final t in txs) {
      if (t.transactionType == 'missing') missing += t.quantity;
      if (t.transactionType == 'found') missing -= t.quantity;
    }
    missing = missing.clamp(0, 999999);
    if (missing == 0) return 'No missing bottles recorded.';
    return 'You currently have $missing missing bottle${missing > 1 ? 's' : ''}.';
  }

  // ── DAMAGED BOTTLES ───────────────────────────────────────────────────────

  Future<String> getDamagedBottles(AppDatabase db) async {
    final txs = await db.bottleTransactionsDao.getAll();
    var damaged = 0;
    for (final t in txs) {
      if (t.transactionType == 'damaged') damaged += t.quantity;
    }
    if (damaged == 0) return 'No damaged bottles recorded.';
    return 'You have recorded $damaged damaged bottle${damaged > 1 ? 's' : ''} in total.';
  }

  // ── INVENTORY STATUS ──────────────────────────────────────────────────────

  Future<String> getInventoryStatus(AppDatabase db) async {
    final txs = await db.bottleTransactionsDao.getAll();
    var purchased = 0;
    var borrowed = 0;
    var returned = 0;
    var missing = 0;
    var found = 0;
    var damaged = 0;

    for (final t in txs) {
      switch (t.transactionType) {
        case 'purchase':
          purchased += t.quantity;
        case 'borrow':
          borrowed += t.quantity;
        case 'return':
          returned += t.quantity;
        case 'missing':
          missing += t.quantity;
        case 'found':
          found += t.quantity;
        case 'damaged':
          damaged += t.quantity;
      }
    }

    final withCustomers = (borrowed - returned).clamp(0, 999999);
    final missingNet = (missing - found).clamp(0, 999999);
    final available = (purchased - withCustomers - missingNet - damaged).clamp(0, 999999);

    return 'Inventory Status:\n'
        '• Available bottles: $available\n'
        '• With customers: $withCustomers\n'
        '• Missing: $missingNet\n'
        '• Damaged: $damaged\n'
        '• Total purchased: $purchased';
  }

  // ── CUSTOMER BOTTLES ──────────────────────────────────────────────────────

  Future<String> getCustomerBottles(AppDatabase db) async {
    final balances = await db.bottleTransactionsDao.getCustomerBottleBalances();
    if (balances.isEmpty) return 'No customers currently hold any bottles.';

    final customers = await db.customersDao.getAll();
    final customerMap = {for (final c in customers) c.id: c.name};

    final sorted = balances.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final topEntry = sorted.first;
    final topName = customerMap[topEntry.key] ?? 'Unknown';
    final buf = StringBuffer(
      '$topName currently holds the most bottles (${topEntry.value}).\n\nAll customers with bottles:\n',
    );
    for (final entry in sorted.take(15)) {
      final name = customerMap[entry.key] ?? 'Unknown';
      buf.writeln('• $name — ${entry.value} bottle${entry.value > 1 ? 's' : ''}');
    }
    if (sorted.length > 15) buf.writeln('... and ${sorted.length - 15} more');
    return buf.toString().trim();
  }

  // ── CUSTOMER BALANCE (generic) ────────────────────────────────────────────

  Future<String> getCustomerBalance(AppDatabase db) async {
    final overdueDeliveries = await db.deliveriesDao.getOverdueDeliveries();
    if (overdueDeliveries.isEmpty) return 'All customers have zero outstanding balances.';

    final customers = await db.customersDao.getAll();
    final customerMap = {for (final c in customers) c.id: c.name};

    final balances = <String, double>{};
    for (final d in overdueDeliveries) {
      balances.update(d.customerId, (v) => v + d.remainingBalance, ifAbsent: () => d.remainingBalance);
    }

    final sorted = balances.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final total = sorted.fold(0.0, (sum, e) => sum + e.value);
    final buf = StringBuffer('Outstanding customer balances — Total: ${_fmt(total)}\n');
    for (final entry in sorted.take(10)) {
      buf.writeln('• ${customerMap[entry.key] ?? 'Unknown'} — ${_fmt(entry.value)}');
    }
    if (sorted.length > 10) buf.writeln('... and ${sorted.length - 10} more');
    return buf.toString().trim();
  }

  // ── MONTHLY BOTTLE PURCHASES ──────────────────────────────────────────────

  Future<String> getMonthlyBottlePurchases(AppDatabase db) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final txs = await db.bottleTransactionsDao.getByDateRange(start, end);
    final purchases = txs.where((t) => t.transactionType == 'purchase');
    final total = purchases.fold(0, (sum, t) => sum + t.quantity);

    if (total == 0) {
      return 'No bottles were purchased in ${DateFormat('MMMM yyyy').format(now)}.';
    }
    return 'You purchased $total bottle${total > 1 ? 's' : ''} in ${DateFormat('MMMM yyyy').format(now)}.';
  }

  // ── DELIVERY SUMMARY (MONTHLY) ────────────────────────────────────────────

  Future<String> getDeliverySummary(AppDatabase db) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final deliveries = await db.deliveriesDao.getByDateRange(start, end);
    final completed = deliveries.where((d) => d.deliveryStatus != 'cancelled');
    final totalSales = completed.fold(0.0, (sum, d) => sum + d.totalAmount);

    final monthName = DateFormat('MMMM yyyy').format(now);
    if (!completed.iterator.moveNext()) {
      return 'No deliveries recorded for $monthName.';
    }

    final count = deliveries.where((d) => d.deliveryStatus != 'cancelled').length;
    return 'Delivery Summary for $monthName:\n'
        '• Total deliveries: $count\n'
        '• Total sales: ${_fmt(totalSales)}';
  }

  // ── TODAY'S DELIVERIES ────────────────────────────────────────────────────

  Future<String> getTodayDeliveries(AppDatabase db) async {
    final deliveries = await db.deliveriesDao.getToday();
    final customers = await db.customersDao.getAll();
    final customerMap = {for (final c in customers) c.id: c.name};

    if (deliveries.isEmpty) return 'No deliveries scheduled for today.';

    final buf = StringBuffer('Today\'s deliveries (${deliveries.length}):\n');
    for (final d in deliveries) {
      final name = customerMap[d.customerId] ?? 'Unknown';
      final status = d.deliveryStatus;
      buf.writeln('• $name — ${d.quantity} btl (${_fmt(d.totalAmount)}) [$status]');
    }
    return buf.toString().trim();
  }

  // ── TOMORROW'S DELIVERIES ─────────────────────────────────────────────────

  Future<String> getTomorrowDeliveries(AppDatabase db) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day + 1);
    final end = start.add(const Duration(days: 1));

    final deliveries = await db.deliveriesDao.getByDateRange(start, end);
    final customers = await db.customersDao.getAll();
    final customerMap = {for (final c in customers) c.id: c.name};

    final scheduled = deliveries.where((d) =>
        d.deliveryStatus == 'scheduled' || d.deliveryStatus == 'in_progress');

    if (!scheduled.iterator.moveNext()) {
      return 'No deliveries scheduled for tomorrow.';
    }

    final list = deliveries.where((d) =>
        d.deliveryStatus == 'scheduled' || d.deliveryStatus == 'in_progress').toList();
    final buf = StringBuffer('Tomorrow\'s deliveries (${list.length}):\n');
    for (final d in list) {
      final name = customerMap[d.customerId] ?? 'Unknown';
      buf.writeln('• $name — ${d.quantity} btl (${_fmt(d.totalAmount)})');
    }
    return buf.toString().trim();
  }

  // ── UPCOMING DELIVERIES ───────────────────────────────────────────────────

  Future<String> getUpcomingDeliveriesFormatted(AppDatabase db) async {
    final deliveries = await db.deliveriesDao.getUpcomingForDashboard();
    final customers = await db.customersDao.getAll();
    final customerMap = {for (final c in customers) c.id: c.name};

    if (deliveries.isEmpty) return 'No upcoming deliveries in the next 7 days.';

    final buf = StringBuffer('Upcoming deliveries (next 7 days):\n');
    for (final d in deliveries) {
      final name = customerMap[d.customerId] ?? 'Unknown';
      final dateStr = DateFormat('MMM d').format(d.deliveryDate);
      buf.writeln('• $dateStr — $name (${d.quantity} btl)');
    }
    return buf.toString().trim();
  }

  // ── WEEK DELIVERIES ───────────────────────────────────────────────────────

  Future<String> getWeekDeliveries(AppDatabase db) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 7));

    final deliveries = await db.deliveriesDao.getByDateRange(start, end);
    final completed = deliveries.where((d) => d.deliveryStatus != 'cancelled').toList();
    final total = completed.fold(0.0, (sum, d) => sum + d.totalAmount);

    if (completed.isEmpty) return 'No deliveries scheduled for this week.';
    return 'This week\'s deliveries: ${completed.length} delivery${completed.length > 1 ? 'ies' : 'y'}, '
        'total ${_fmt(total)}.';
  }

  // ── DEPOSIT STATUS ────────────────────────────────────────────────────────

  Future<String> getDepositStatus(AppDatabase db) async {
    final total = await db.customerDepositsDao.getTotalDepositsHeld();
    final count = await db.customerDepositsDao.getCustomersWithDepositsCount();
    if (count == 0) return 'No customer deposits are currently held.';

    final allDeposits = await db.customerDepositsDao.getAll();
    final customers = await db.customersDao.getAll();
    final customerMap = {for (final c in customers) c.id: c.name};

    final balances = <String, double>{};
    for (final d in allDeposits) {
      switch (d.transactionType) {
        case 'deposit_added':
          balances.update(d.customerId, (v) => v + d.amount, ifAbsent: () => d.amount);
        case 'deposit_used':
          balances.update(d.customerId, (v) => v - d.amount, ifAbsent: () => -d.amount);
        case 'deposit_adjustment':
          balances.update(d.customerId, (v) => v + d.amount, ifAbsent: () => d.amount);
      }
    }

    final sorted = balances.entries.where((e) => e.value > 0.001).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final buf = StringBuffer(
      'You are holding ${_fmt(total)} in deposits from $count customer${count > 1 ? 's' : ''}.\n\nLargest deposits:\n',
    );
    for (final entry in sorted.take(5)) {
      buf.writeln('• ${customerMap[entry.key] ?? 'Unknown'} — ${_fmt(entry.value)}');
    }
    return buf.toString().trim();
  }

  // ── TOTAL RECEIVABLES ─────────────────────────────────────────────────────

  Future<String> getTotalReceivables(AppDatabase db) async {
    final total = await db.deliveriesDao.getTotalReceivables();
    if (total == 0) return 'You have no outstanding receivables. All payments are up to date.';

    final overdueDeliveries = await db.deliveriesDao.getOverdueDeliveries();
    final customers = await db.customersDao.getAll();
    final customerMap = {for (final c in customers) c.id: c.name};

    final balances = <String, double>{};
    for (final d in overdueDeliveries) {
      balances.update(d.customerId, (v) => v + d.remainingBalance, ifAbsent: () => d.remainingBalance);
    }

    final sorted = balances.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final buf = StringBuffer('Total collectible: ${_fmt(total)}\n\nTop debtors:\n');
    for (final entry in sorted.take(5)) {
      buf.writeln('• ${customerMap[entry.key] ?? 'Unknown'} — ${_fmt(entry.value)}');
    }
    return buf.toString().trim();
  }

  // ── MONTHLY EXPENSES ──────────────────────────────────────────────────────

  Future<String> getMonthlyExpenses(AppDatabase db) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final expenses = await db.expensesDao.getByDateRange(start, end);
    if (expenses.isEmpty) {
      return 'No expenses recorded for ${DateFormat('MMMM yyyy').format(now)}.';
    }

    final total = expenses.fold(0.0, (sum, e) => sum + e.amount);
    final byCategory = <String, double>{};
    for (final e in expenses) {
      byCategory.update(e.category, (v) => v + e.amount, ifAbsent: () => e.amount);
    }

    final sorted = byCategory.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final buf = StringBuffer(
      'You spent ${_fmt(total)} in ${DateFormat('MMMM yyyy').format(now)}.\n\nBreakdown:',
    );
    for (final entry in sorted) {
      buf.writeln('\n• ${entry.key}: ${_fmt(entry.value)}');
    }
    return buf.toString().trim();
  }

  // ── AUDIT STATUS ──────────────────────────────────────────────────────────

  Future<String> getAuditStatus(AppDatabase db) async {
    final latest = await db.inventoryAuditsDao.getLatest();
    final totalAudits = await db.inventoryAuditsDao.getCount();

    if (latest == null) {
      return 'No inventory audits have been performed yet.\n'
          'Consider running an audit to verify your bottle count.';
    }

    final daysSince = DateTime.now().difference(latest.auditDate).inDays;
    final daysLabel = daysSince == 0
        ? 'today'
        : daysSince == 1
            ? 'yesterday'
            : '$daysSince days ago';

    return 'Last inventory audit: $daysLabel (${DateFormat('MMM d, yyyy').format(latest.auditDate)}).\n'
        'Total audits performed: $totalAudits';
  }

  // ── FOLLOW-UPS ────────────────────────────────────────────────────────────

  Future<String> getFollowUps(AppDatabase db) async {
    final buf = StringBuffer('Here is what needs your attention:\n');
    var hasItems = false;

    final overdueDeliveries = await db.deliveriesDao.getOverdueDeliveries();
    if (overdueDeliveries.isNotEmpty) {
      final customers = await db.customersDao.getAll();
      final customerMap = {for (final c in customers) c.id: c.name};
      final overdueIds = overdueDeliveries.map((d) => d.customerId).toSet();
      buf.writeln('\n${overdueIds.length} customer${overdueIds.length > 1 ? 's have' : ' has'} overdue payments:');

      final balances = <String, double>{};
      for (final d in overdueDeliveries) {
        balances.update(d.customerId, (v) => v + d.remainingBalance, ifAbsent: () => d.remainingBalance);
      }
      final sorted = balances.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      for (final entry in sorted.take(3)) {
        buf.writeln('  • ${customerMap[entry.key] ?? 'Unknown'} — ${_fmt(entry.value)}');
      }
      hasItems = true;
    }

    final txs = await db.bottleTransactionsDao.getAll();
    var missing = 0;
    for (final t in txs) {
      if (t.transactionType == 'missing') missing += t.quantity;
      if (t.transactionType == 'found') missing -= t.quantity;
    }
    missing = missing.clamp(0, 999999);
    if (missing > 0) {
      buf.writeln('\n$missing missing bottle${missing > 1 ? 's' : ''} unresolved.');
      hasItems = true;
    }

    final latest = await db.inventoryAuditsDao.getLatest();
    if (latest == null) {
      buf.writeln('\nNo inventory audit yet — consider running one soon.');
      hasItems = true;
    } else if (DateTime.now().difference(latest.auditDate).inDays >= 30) {
      buf.writeln('\nInventory audit overdue (last: ${DateTime.now().difference(latest.auditDate).inDays} days ago).');
      hasItems = true;
    }

    final inactive = await _inactiveCustomerList(db, 30);
    if (inactive.isNotEmpty) {
      buf.writeln('\n${inactive.length} customer${inactive.length > 1 ? 's have' : ' has'} not ordered in 30+ days.');
      hasItems = true;
    }

    if (!hasItems) return 'Everything looks good! No urgent follow-ups today.';
    return buf.toString().trim();
  }

  // ── BUSINESS HEALTH CHECK ─────────────────────────────────────────────────

  Future<String> getHealthCheck(AppDatabase db) async {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    // Revenue this month
    final deliveries = await db.deliveriesDao.getByDateRange(monthStart, monthEnd);
    final revenue = deliveries
        .where((d) => d.deliveryStatus != 'cancelled')
        .fold(0.0, (sum, d) => sum + d.totalAmount);

    // Profit this month
    final profit = await _computeSavingsForPeriod(db, monthStart, monthEnd);

    // Savings
    final costRaw = await db.settingsDao.getValue(AppConstants.settingCostPerBottle);
    final costPerBottle = double.tryParse(costRaw ?? '') ?? AppConstants.defaultCostPerBottle;
    final allDeliveries = await db.deliveriesDao.getAll();
    final allExpenses = await db.expensesDao.getAll();
    final allDisp = await db.dispenserSalesDao.getAll();
    final allTxs = await db.bottleTransactionsDao.getAll();
    final manualSavings = await db.savingsDao.getTotalContributions();
    final linkedIds = await db.supplyPurchasesDao.getLinkedBottleTransactionIds();

    var dProfit = 0.0;
    for (final d in allDeliveries) {
      if (d.deliveryStatus == 'cancelled') continue;
      dProfit += d.quantity * (d.pricePerBottle - costPerBottle);
    }
    final dispProfit = allDisp.fold(0.0, (s, d) => s + d.amount);
    final totalExp = allExpenses.fold(0.0, (s, e) => s + e.amount);
    var bPurchases = 0.0;
    for (final t in allTxs) {
      if (t.transactionType == 'purchase' && !linkedIds.contains(t.id)) {
        bPurchases += t.quantity * costPerBottle;
      }
    }
    final savings = dProfit + dispProfit - totalExp - bPurchases + manualSavings;

    // Overdue
    final overdueDeliveries = await db.deliveriesDao.getOverdueDeliveries();
    final overdueCount = overdueDeliveries.map((d) => d.customerId).toSet().length;
    final overdueTotal = overdueDeliveries.fold(0.0, (sum, d) => sum + d.remainingBalance);

    // Missing bottles
    var missing = 0;
    for (final t in allTxs) {
      if (t.transactionType == 'missing') missing += t.quantity;
      if (t.transactionType == 'found') missing -= t.quantity;
    }
    missing = missing.clamp(0, 999999);

    // Deposits
    final depositTotal = await db.customerDepositsDao.getTotalDepositsHeld();

    // Audit
    final latestAudit = await db.inventoryAuditsDao.getLatest();
    final auditDays = latestAudit != null ? DateTime.now().difference(latestAudit.auditDate).inDays : null;
    final inventoryStatus = missing == 0 ? 'Healthy' : 'Attention needed ($missing missing)';

    // Recommendations
    final recs = <String>[];
    if (overdueCount > 0) recs.add('Follow up $overdueCount overdue customer${overdueCount > 1 ? 's' : ''}');
    if (missing > 0) recs.add('Investigate $missing missing bottle${missing > 1 ? 's' : ''}');
    if (auditDays == null || auditDays >= 30) recs.add('Perform an inventory audit');
    final inactive = await _inactiveCustomerList(db, 30);
    if (inactive.isNotEmpty) recs.add('Review ${inactive.length} inactive customer${inactive.length > 1 ? 's' : ''}');

    final monthName = DateFormat('MMMM yyyy').format(now);
    final buf = StringBuffer('Business Health Check\n');
    buf.writeln('─────────────────────\n');
    buf.writeln('Revenue ($monthName): ${_fmt(revenue)}');
    buf.writeln('Profit ($monthName): ${_fmt(profit)}');
    buf.writeln('Total Savings: ${_fmt(savings)}');
    buf.writeln('Overdue Customers: $overdueCount${overdueCount > 0 ? ' (${_fmt(overdueTotal)})' : ''}');
    buf.writeln('Missing Bottles: $missing');
    buf.writeln('Deposits Held: ${_fmt(depositTotal)}');
    buf.writeln('Inventory: $inventoryStatus');

    if (recs.isNotEmpty) {
      buf.writeln('\nRecommendations:');
      for (final rec in recs) {
        buf.writeln('• $rec');
      }
    } else {
      buf.writeln('\nAll indicators look healthy!');
    }

    return buf.toString().trim();
  }
}
