import 'package:drift/drift.dart';
import '../tables/walk_in_sales_table.dart';
import '../app_database.dart';

part 'walk_in_sales_dao.g.dart';

@DriftAccessor(tables: [WalkInSalesTable])
class WalkInSalesDao extends DatabaseAccessor<AppDatabase>
    with _$WalkInSalesDaoMixin {
  WalkInSalesDao(super.db);

  Stream<List<WalkInSalesTableData>> watchAll() {
    return (select(walkInSalesTable)
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  Future<List<WalkInSalesTableData>> getAll() {
    return (select(walkInSalesTable)
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  Future<List<WalkInSalesTableData>> getByDateRange(
    DateTime start,
    DateTime end,
  ) {
    return (select(walkInSalesTable)
          ..where(
            (t) =>
                t.date.isBiggerOrEqualValue(start) &
                t.date.isSmallerOrEqualValue(end),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  Future<List<WalkInSalesTableData>> getByCustomer(String customerId) {
    return (select(walkInSalesTable)
          ..where((t) => t.customerId.equals(customerId))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  Future<WalkInSalesTableData?> getById(String id) {
    return (select(walkInSalesTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<int> insertSale(WalkInSalesTableCompanion companion) {
    return into(walkInSalesTable).insert(companion);
  }

  Future<int> deleteSale(String id) {
    return (delete(walkInSalesTable)..where((t) => t.id.equals(id))).go();
  }

  Future<double> getTotalRevenueForDateRange(DateTime start, DateTime end) async {
    final amountExpr = walkInSalesTable.totalAmount.sum();
    final query = selectOnly(walkInSalesTable)
      ..addColumns([amountExpr])
      ..where(
        walkInSalesTable.date.isBiggerOrEqualValue(start) &
            walkInSalesTable.date.isSmallerOrEqualValue(end),
      );
    final row = await query.getSingle();
    return row.read(amountExpr) ?? 0.0;
  }

  Future<int> getCountForDateRange(DateTime start, DateTime end) async {
    final countExpr = walkInSalesTable.id.count();
    final query = selectOnly(walkInSalesTable)
      ..addColumns([countExpr])
      ..where(
        walkInSalesTable.date.isBiggerOrEqualValue(start) &
            walkInSalesTable.date.isSmallerOrEqualValue(end),
      );
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }

  Future<int> countByTypeForDateRange(
    String walkInType,
    DateTime start,
    DateTime end,
  ) async {
    final countExpr = walkInSalesTable.id.count();
    final query = selectOnly(walkInSalesTable)
      ..addColumns([countExpr])
      ..where(
        walkInSalesTable.walkInType.equals(walkInType) &
            walkInSalesTable.date.isBiggerOrEqualValue(start) &
            walkInSalesTable.date.isSmallerOrEqualValue(end),
      );
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }

  Future<double> revenueByTypeForDateRange(
    String walkInType,
    DateTime start,
    DateTime end,
  ) async {
    final amountExpr = walkInSalesTable.totalAmount.sum();
    final query = selectOnly(walkInSalesTable)
      ..addColumns([amountExpr])
      ..where(
        walkInSalesTable.walkInType.equals(walkInType) &
            walkInSalesTable.date.isBiggerOrEqualValue(start) &
            walkInSalesTable.date.isSmallerOrEqualValue(end),
      );
    final row = await query.getSingle();
    return row.read(amountExpr) ?? 0.0;
  }

  Future<int> totalBottlesForDateRange(DateTime start, DateTime end) async {
    final rows = await getByDateRange(start, end);
    var total = 0;
    for (final r in rows) {
      switch (r.walkInType) {
        case 'BUSINESS_BOTTLES':
          total += r.businessOwnedQuantity;
        case 'CUSTOMER_REFILL':
          total += r.customerOwnedQuantity;
        case 'EXCHANGE':
          total += r.businessOwnedQuantity;
      }
    }
    return total;
  }
}
