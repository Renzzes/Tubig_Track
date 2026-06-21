// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_deposits_dao.dart';

// ignore_for_file: type=lint
mixin _$CustomerDepositsDaoMixin on DatabaseAccessor<AppDatabase> {
  $CustomerDepositsTableTable get customerDepositsTable =>
      attachedDatabase.customerDepositsTable;
  CustomerDepositsDaoManager get managers => CustomerDepositsDaoManager(this);
}

class CustomerDepositsDaoManager {
  final _$CustomerDepositsDaoMixin _db;
  CustomerDepositsDaoManager(this._db);
  $$CustomerDepositsTableTableTableManager get customerDepositsTable =>
      $$CustomerDepositsTableTableTableManager(
        _db.attachedDatabase,
        _db.customerDepositsTable,
      );
}
