import '../../../deliveries/domain/repositories/delivery_repository.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/overdue_account.dart';
import '../../domain/repositories/overdue_repository.dart';

class OverdueRepositoryImpl implements OverdueRepository {
  final AppDatabase _db;

  OverdueRepositoryImpl(this._db);

  @override
  Future<OverdueSummary> getSummary() async {
    final accounts = await getAccounts(sort: OverdueSort.highestBalance);
    final total = accounts.fold<double>(0, (s, a) => s + a.balance);
    return OverdueSummary(
      customerCount: accounts.length,
      totalAmount: total,
    );
  }

  @override
  Future<List<OverdueAccount>> getAccounts({OverdueSort sort = OverdueSort.highestBalance}) async {
    final overdueRows = await _db.deliveriesDao.getOverdueDeliveries();
    if (overdueRows.isEmpty) return [];

    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);

    final Map<String, _Agg> grouped = {};
    for (final row in overdueRows) {
      final deliveryDay = DateTime(
        row.deliveryDate.year,
        row.deliveryDate.month,
        row.deliveryDate.day,
      );
      final days = startOfToday.difference(deliveryDay).inDays;
      grouped.putIfAbsent(
        row.customerId,
        () => _Agg(balance: 0, oldestDays: days),
      );
      final agg = grouped[row.customerId]!;
      grouped[row.customerId] = _Agg(
        balance: agg.balance + row.remainingBalance,
        oldestDays: days > agg.oldestDays ? days : agg.oldestDays,
      );
    }

    final customers = await _db.customersDao.getAll();
    final nameMap = {for (final c in customers) c.id: c};

    var accounts = grouped.entries.map((e) {
      final customer = nameMap[e.key];
      return OverdueAccount(
        customerId: e.key,
        customerName: customer?.name ?? 'Unknown',
        phone: customer?.phone,
        balance: e.value.balance,
        daysOverdue: e.value.oldestDays,
      );
    }).toList();

    switch (sort) {
      case OverdueSort.highestBalance:
        accounts.sort((a, b) => b.balance.compareTo(a.balance));
      case OverdueSort.oldestDebt:
        accounts.sort((a, b) => b.daysOverdue.compareTo(a.daysOverdue));
      case OverdueSort.newestDebt:
        accounts.sort((a, b) => a.daysOverdue.compareTo(b.daysOverdue));
    }

    return accounts;
  }
}

class _Agg {
  final double balance;
  final int oldestDays;

  const _Agg({required this.balance, required this.oldestDays});
}
