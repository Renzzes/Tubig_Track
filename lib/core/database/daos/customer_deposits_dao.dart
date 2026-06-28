import 'package:drift/drift.dart';
import '../tables/customer_deposits_table.dart';
import '../app_database.dart';

part 'customer_deposits_dao.g.dart';

@DriftAccessor(tables: [CustomerDepositsTable])
class CustomerDepositsDao extends DatabaseAccessor<AppDatabase>
    with _$CustomerDepositsDaoMixin {
  CustomerDepositsDao(super.db);

  Stream<List<CustomerDepositsTableData>> watchAll() {
    return (select(customerDepositsTable)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Stream<List<CustomerDepositsTableData>> watchByCustomer(String customerId) {
    return (select(customerDepositsTable)
          ..where((t) => t.customerId.equals(customerId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Future<List<CustomerDepositsTableData>> getAll() {
    return (select(customerDepositsTable)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Future<List<CustomerDepositsTableData>> getByCustomer(String customerId) {
    return (select(customerDepositsTable)
          ..where((t) => t.customerId.equals(customerId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Future<List<CustomerDepositsTableData>> getByDelivery(String deliveryId) {
    return (select(customerDepositsTable)
          ..where((t) => t.deliveryId.equals(deliveryId)))
        .get();
  }

  Future<double> getBalanceForCustomer(String customerId) async {
    final rows = await getByCustomer(customerId);
    return _computeBalance(rows);
  }

  double _computeBalance(List<CustomerDepositsTableData> rows) {
    var balance = 0.0;
    for (final row in rows) {
      switch (row.transactionType) {
        case 'deposit_added':
          balance += row.amount;
        case 'deposit_used':
          balance -= row.amount;
        case 'deposit_adjustment':
          balance += row.amount;
        case 'change_given':
          break;
      }
    }
    return balance.clamp(0.0, double.infinity);
  }

  Future<double> getBalanceExcludingDelivery(
    String customerId,
    String deliveryId,
  ) async {
    final rows = await (select(customerDepositsTable)
          ..where(
            (t) =>
                t.customerId.equals(customerId) &
                t.deliveryId.isNotValue(deliveryId),
          ))
        .get();
    return _computeBalance(rows);
  }

  Future<int> insertDeposit(CustomerDepositsTableCompanion companion) {
    return into(customerDepositsTable).insert(companion);
  }

  Future<int> deleteByDelivery(String deliveryId) {
    return (delete(customerDepositsTable)
          ..where((t) => t.deliveryId.equals(deliveryId)))
        .go();
  }

  Future<int> getCustomersWithDepositsCount() async {
    final rows = await getAll();
    final balances = <String, double>{};
    for (final row in rows) {
      balances.putIfAbsent(row.customerId, () => 0);
      switch (row.transactionType) {
        case 'deposit_added':
          balances[row.customerId] = balances[row.customerId]! + row.amount;
        case 'deposit_used':
          balances[row.customerId] = balances[row.customerId]! - row.amount;
        case 'deposit_adjustment':
          balances[row.customerId] = balances[row.customerId]! + row.amount;
      }
    }
    return balances.values.where((b) => b > 0.001).length;
  }

  Future<double> getTotalDepositsHeld() async {
    final rows = await getAll();
    final byCustomer = <String, double>{};
    for (final row in rows) {
      byCustomer.putIfAbsent(row.customerId, () => 0);
      switch (row.transactionType) {
        case 'deposit_added':
          byCustomer[row.customerId] = byCustomer[row.customerId]! + row.amount;
        case 'deposit_used':
          byCustomer[row.customerId] = byCustomer[row.customerId]! - row.amount;
        case 'deposit_adjustment':
          byCustomer[row.customerId] = byCustomer[row.customerId]! + row.amount;
      }
    }
    return byCustomer.values
        .where((b) => b > 0.001)
        .fold<double>(0.0, (sum, b) => sum + b);
  }

  Future<double> getTotalAdded() async {
    return _sumByType('deposit_added');
  }

  Future<double> getTotalUsed() async {
    return _sumByType('deposit_used');
  }

  Future<double> _sumByType(String type) async {
    final amountExpr = customerDepositsTable.amount.sum();
    final q = selectOnly(customerDepositsTable)
      ..addColumns([amountExpr])
      ..where(customerDepositsTable.transactionType.equals(type));
    final row = await q.getSingle();
    return row.read(amountExpr) ?? 0.0;
  }
}
