import 'package:drift/drift.dart';
import '../tables/dispenser_sales_table.dart';
import '../app_database.dart';

part 'dispenser_sales_dao.g.dart';

@DriftAccessor(tables: [DispenserSalesTable])
class DispenserSalesDao extends DatabaseAccessor<AppDatabase>
    with _$DispenserSalesDaoMixin {
  DispenserSalesDao(super.db);

  Stream<List<DispenserSalesTableData>> watchAll() {
    return (select(dispenserSalesTable)
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  Future<List<DispenserSalesTableData>> getAll() {
    return (select(dispenserSalesTable)
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  Future<List<DispenserSalesTableData>> getByDateRange(
    DateTime start,
    DateTime end,
  ) {
    return (select(dispenserSalesTable)
          ..where(
            (t) =>
                t.date.isBiggerOrEqualValue(start) &
                t.date.isSmallerOrEqualValue(end),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  Future<int> insertSale(DispenserSalesTableCompanion companion) {
    return into(dispenserSalesTable).insert(companion);
  }

  Future<int> deleteSale(String id) {
    return (delete(dispenserSalesTable)..where((t) => t.id.equals(id))).go();
  }

  Future<double> getTotalForDateRange(DateTime start, DateTime end) async {
    final amountExpr = dispenserSalesTable.amount.sum();
    final query = selectOnly(dispenserSalesTable)
      ..addColumns([amountExpr])
      ..where(
        dispenserSalesTable.date.isBiggerOrEqualValue(start) &
            dispenserSalesTable.date.isSmallerOrEqualValue(end),
      );
    final row = await query.getSingle();
    return row.read(amountExpr) ?? 0.0;
  }
}
