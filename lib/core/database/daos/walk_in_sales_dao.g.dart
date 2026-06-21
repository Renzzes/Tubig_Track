// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'walk_in_sales_dao.dart';

// ignore_for_file: type=lint
mixin _$WalkInSalesDaoMixin on DatabaseAccessor<AppDatabase> {
  $WalkInSalesTableTable get walkInSalesTable =>
      attachedDatabase.walkInSalesTable;
  WalkInSalesDaoManager get managers => WalkInSalesDaoManager(this);
}

class WalkInSalesDaoManager {
  final _$WalkInSalesDaoMixin _db;
  WalkInSalesDaoManager(this._db);
  $$WalkInSalesTableTableTableManager get walkInSalesTable =>
      $$WalkInSalesTableTableTableManager(
        _db.attachedDatabase,
        _db.walkInSalesTable,
      );
}
