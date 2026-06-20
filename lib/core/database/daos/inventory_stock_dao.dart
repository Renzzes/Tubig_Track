import 'package:drift/drift.dart';
import '../tables/inventory_stock_table.dart';
import '../app_database.dart';

part 'inventory_stock_dao.g.dart';

@DriftAccessor(tables: [InventoryStockTable])
class InventoryStockDao extends DatabaseAccessor<AppDatabase>
    with _$InventoryStockDaoMixin {
  InventoryStockDao(super.db);

  Stream<List<InventoryStockTableData>> watchAll() {
    return select(inventoryStockTable).watch();
  }

  Future<List<InventoryStockTableData>> getAll() {
    return select(inventoryStockTable).get();
  }

  Future<int> getQuantity(String itemType) async {
    final row = await (select(inventoryStockTable)
          ..where((t) => t.itemType.equals(itemType)))
        .getSingleOrNull();
    return row?.quantity ?? 0;
  }

  Future<void> addQuantity(String itemType, int amount) async {
    final current = await getQuantity(itemType);
    await into(inventoryStockTable).insertOnConflictUpdate(
      InventoryStockTableCompanion.insert(
        itemType: itemType,
        quantity: Value(current + amount),
      ),
    );
  }

  Future<void> subtractQuantity(String itemType, int amount) async {
    final current = await getQuantity(itemType);
    final next = (current - amount).clamp(0, 999999999);
    await into(inventoryStockTable).insertOnConflictUpdate(
      InventoryStockTableCompanion.insert(
        itemType: itemType,
        quantity: Value(next),
      ),
    );
  }

  Future<void> ensureDefaults(List<String> itemTypes) async {
    for (final type in itemTypes) {
      final existing = await (select(inventoryStockTable)
            ..where((t) => t.itemType.equals(type)))
          .getSingleOrNull();
      if (existing == null) {
        await into(inventoryStockTable).insert(
          InventoryStockTableCompanion.insert(itemType: type),
        );
      }
    }
  }
}
