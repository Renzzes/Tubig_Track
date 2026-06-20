import 'package:drift/drift.dart';
import '../tables/inventory_adjustments_table.dart';
import '../app_database.dart';

part 'inventory_adjustments_dao.g.dart';

@DriftAccessor(tables: [InventoryAdjustmentsTable])
class InventoryAdjustmentsDao extends DatabaseAccessor<AppDatabase>
    with _$InventoryAdjustmentsDaoMixin {
  InventoryAdjustmentsDao(super.db);

  Stream<List<InventoryAdjustmentsTableData>> watchAll() {
    return (select(inventoryAdjustmentsTable)
          ..orderBy([(t) => OrderingTerm.desc(t.adjustmentDate)]))
        .watch();
  }

  Future<List<InventoryAdjustmentsTableData>> getAll() {
    return (select(inventoryAdjustmentsTable)
          ..orderBy([(t) => OrderingTerm.desc(t.adjustmentDate)]))
        .get();
  }

  Future<int> getNetQuantity() async {
    final qtyExpr = inventoryAdjustmentsTable.quantity.sum();
    final q = selectOnly(inventoryAdjustmentsTable)..addColumns([qtyExpr]);
    final row = await q.getSingle();
    return row.read(qtyExpr) ?? 0;
  }

  Future<int> getPositiveTotal() async {
    final qtyExpr = inventoryAdjustmentsTable.quantity.sum();
    final q = selectOnly(inventoryAdjustmentsTable)
      ..addColumns([qtyExpr])
      ..where(inventoryAdjustmentsTable.quantity.isBiggerOrEqualValue(1));
    final row = await q.getSingle();
    return row.read(qtyExpr) ?? 0;
  }

  Future<int> insertAdjustment(InventoryAdjustmentsTableCompanion companion) {
    return into(inventoryAdjustmentsTable).insert(companion);
  }
}
