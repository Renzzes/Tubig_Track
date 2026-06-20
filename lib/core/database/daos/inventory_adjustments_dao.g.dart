// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_adjustments_dao.dart';

// ignore_for_file: type=lint
mixin _$InventoryAdjustmentsDaoMixin on DatabaseAccessor<AppDatabase> {
  $InventoryAdjustmentsTableTable get inventoryAdjustmentsTable =>
      attachedDatabase.inventoryAdjustmentsTable;
  InventoryAdjustmentsDaoManager get managers =>
      InventoryAdjustmentsDaoManager(this);
}

class InventoryAdjustmentsDaoManager {
  final _$InventoryAdjustmentsDaoMixin _db;
  InventoryAdjustmentsDaoManager(this._db);
  $$InventoryAdjustmentsTableTableTableManager get inventoryAdjustmentsTable =>
      $$InventoryAdjustmentsTableTableTableManager(
        _db.attachedDatabase,
        _db.inventoryAdjustmentsTable,
      );
}
