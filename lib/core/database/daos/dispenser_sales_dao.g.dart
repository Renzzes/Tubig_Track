// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dispenser_sales_dao.dart';

// ignore_for_file: type=lint
mixin _$DispenserSalesDaoMixin on DatabaseAccessor<AppDatabase> {
  $DispenserSalesTableTable get dispenserSalesTable =>
      attachedDatabase.dispenserSalesTable;
  DispenserSalesDaoManager get managers => DispenserSalesDaoManager(this);
}

class DispenserSalesDaoManager {
  final _$DispenserSalesDaoMixin _db;
  DispenserSalesDaoManager(this._db);
  $$DispenserSalesTableTableTableManager get dispenserSalesTable =>
      $$DispenserSalesTableTableTableManager(
        _db.attachedDatabase,
        _db.dispenserSalesTable,
      );
}
