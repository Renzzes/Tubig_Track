// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_stock_dao.dart';

// ignore_for_file: type=lint
mixin _$InventoryStockDaoMixin on DatabaseAccessor<AppDatabase> {
  $InventoryStockTableTable get inventoryStockTable =>
      attachedDatabase.inventoryStockTable;
  InventoryStockDaoManager get managers => InventoryStockDaoManager(this);
}

class InventoryStockDaoManager {
  final _$InventoryStockDaoMixin _db;
  InventoryStockDaoManager(this._db);
  $$InventoryStockTableTableTableManager get inventoryStockTable =>
      $$InventoryStockTableTableTableManager(
        _db.attachedDatabase,
        _db.inventoryStockTable,
      );
}
