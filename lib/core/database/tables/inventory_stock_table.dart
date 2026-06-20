import 'package:drift/drift.dart';

class InventoryStockTable extends Table {
  @override
  String get tableName => 'inventory_stock';

  TextColumn get itemType => text()();
  IntColumn get quantity => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {itemType};
}
