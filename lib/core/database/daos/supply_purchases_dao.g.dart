// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supply_purchases_dao.dart';

// ignore_for_file: type=lint
mixin _$SupplyPurchasesDaoMixin on DatabaseAccessor<AppDatabase> {
  $SupplyPurchasesTableTable get supplyPurchasesTable =>
      attachedDatabase.supplyPurchasesTable;
  SupplyPurchasesDaoManager get managers => SupplyPurchasesDaoManager(this);
}

class SupplyPurchasesDaoManager {
  final _$SupplyPurchasesDaoMixin _db;
  SupplyPurchasesDaoManager(this._db);
  $$SupplyPurchasesTableTableTableManager get supplyPurchasesTable =>
      $$SupplyPurchasesTableTableTableManager(
        _db.attachedDatabase,
        _db.supplyPurchasesTable,
      );
}
