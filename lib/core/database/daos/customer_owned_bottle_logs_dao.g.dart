// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_owned_bottle_logs_dao.dart';

// ignore_for_file: type=lint
mixin _$CustomerOwnedBottleLogsDaoMixin on DatabaseAccessor<AppDatabase> {
  $CustomerOwnedBottleLogsTableTable get customerOwnedBottleLogsTable =>
      attachedDatabase.customerOwnedBottleLogsTable;
  CustomerOwnedBottleLogsDaoManager get managers =>
      CustomerOwnedBottleLogsDaoManager(this);
}

class CustomerOwnedBottleLogsDaoManager {
  final _$CustomerOwnedBottleLogsDaoMixin _db;
  CustomerOwnedBottleLogsDaoManager(this._db);
  $$CustomerOwnedBottleLogsTableTableTableManager
  get customerOwnedBottleLogsTable =>
      $$CustomerOwnedBottleLogsTableTableTableManager(
        _db.attachedDatabase,
        _db.customerOwnedBottleLogsTable,
      );
}
