import 'package:drift/drift.dart';
import '../tables/bottle_transactions_table.dart';
import '../app_database.dart';

part 'bottle_transactions_dao.g.dart';

@DriftAccessor(tables: [BottleTransactionsTable])
class BottleTransactionsDao extends DatabaseAccessor<AppDatabase>
    with _$BottleTransactionsDaoMixin {
  BottleTransactionsDao(super.db);

  Stream<List<BottleTransactionsTableData>> watchAll() {
    return (select(bottleTransactionsTable)
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  Future<List<BottleTransactionsTableData>> getAll() {
    return (select(bottleTransactionsTable)
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  Future<List<BottleTransactionsTableData>> getByCustomer(String customerId) {
    return (select(bottleTransactionsTable)
          ..where((t) => t.customerId.equals(customerId))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  Future<List<BottleTransactionsTableData>> getByDateRange(
    DateTime start,
    DateTime end,
  ) {
    return (select(bottleTransactionsTable)
          ..where(
            (t) =>
                t.date.isBiggerOrEqualValue(start) &
                t.date.isSmallerOrEqualValue(end),
          ))
        .get();
  }

  Future<int> insertTransaction(BottleTransactionsTableCompanion companion) {
    return into(bottleTransactionsTable).insert(companion);
  }

  Future<bool> updateTransaction(BottleTransactionsTableCompanion companion) {
    return update(bottleTransactionsTable).replace(companion);
  }

  Future<int> deleteTransaction(String id) {
    return (delete(bottleTransactionsTable)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  Future<int> getTotalByType(String type) async {
    final qtyExpr = bottleTransactionsTable.quantity.sum();
    final query = selectOnly(bottleTransactionsTable)
      ..addColumns([qtyExpr])
      ..where(bottleTransactionsTable.transactionType.equals(type));
    final row = await query.getSingle();
    return row.read(qtyExpr) ?? 0;
  }

  Future<int> getTotalByTypeForCustomer(
    String type,
    String customerId,
  ) async {
    final qtyExpr = bottleTransactionsTable.quantity.sum();
    final query = selectOnly(bottleTransactionsTable)
      ..addColumns([qtyExpr])
      ..where(
        bottleTransactionsTable.transactionType.equals(type) &
            bottleTransactionsTable.customerId.equals(customerId),
      );
    final row = await query.getSingle();
    return row.read(qtyExpr) ?? 0;
  }
}
