import 'package:drift/drift.dart';
import '../tables/supply_purchases_table.dart';
import '../app_database.dart';

part 'supply_purchases_dao.g.dart';

@DriftAccessor(tables: [SupplyPurchasesTable])
class SupplyPurchasesDao extends DatabaseAccessor<AppDatabase>
    with _$SupplyPurchasesDaoMixin {
  SupplyPurchasesDao(super.db);

  Stream<List<SupplyPurchasesTableData>> watchAll() {
    return (select(supplyPurchasesTable)
          ..orderBy([(t) => OrderingTerm.desc(t.purchaseDate)]))
        .watch();
  }

  Future<List<SupplyPurchasesTableData>> getAll() {
    return (select(supplyPurchasesTable)
          ..orderBy([(t) => OrderingTerm.desc(t.purchaseDate)]))
        .get();
  }

  Future<List<SupplyPurchasesTableData>> getByDateRange(
    DateTime start,
    DateTime end,
  ) {
    return (select(supplyPurchasesTable)
          ..where(
            (t) =>
                t.purchaseDate.isBiggerOrEqualValue(start) &
                t.purchaseDate.isSmallerOrEqualValue(end),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.purchaseDate)]))
        .get();
  }

  Future<SupplyPurchasesTableData?> getById(String id) {
    return (select(supplyPurchasesTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<SupplyPurchasesTableData?> getByExpenseId(String expenseId) {
    return (select(supplyPurchasesTable)
          ..where((t) => t.expenseId.equals(expenseId)))
        .getSingleOrNull();
  }

  Future<int> insertPurchase(SupplyPurchasesTableCompanion companion) {
    return into(supplyPurchasesTable).insert(companion);
  }

  Future<int> deletePurchase(String id) {
    return (delete(supplyPurchasesTable)..where((t) => t.id.equals(id))).go();
  }

  Future<Set<String>> getLinkedBottleTransactionIds() async {
    final rows = await select(supplyPurchasesTable).get();
    return rows
        .map((r) => r.bottleTransactionId)
        .whereType<String>()
        .toSet();
  }
}
