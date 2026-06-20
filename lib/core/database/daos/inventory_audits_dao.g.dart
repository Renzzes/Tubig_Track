// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_audits_dao.dart';

// ignore_for_file: type=lint
mixin _$InventoryAuditsDaoMixin on DatabaseAccessor<AppDatabase> {
  $InventoryAuditsTableTable get inventoryAuditsTable =>
      attachedDatabase.inventoryAuditsTable;
  InventoryAuditsDaoManager get managers => InventoryAuditsDaoManager(this);
}

class InventoryAuditsDaoManager {
  final _$InventoryAuditsDaoMixin _db;
  InventoryAuditsDaoManager(this._db);
  $$InventoryAuditsTableTableTableManager get inventoryAuditsTable =>
      $$InventoryAuditsTableTableTableManager(
        _db.attachedDatabase,
        _db.inventoryAuditsTable,
      );
}
