// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_bottle_reconciliations_dao.dart';

// ignore_for_file: type=lint
mixin _$CustomerBottleReconciliationsDaoMixin on DatabaseAccessor<AppDatabase> {
  $CustomerBottleReconciliationsTableTable
  get customerBottleReconciliationsTable =>
      attachedDatabase.customerBottleReconciliationsTable;
  CustomerBottleReconciliationsDaoManager get managers =>
      CustomerBottleReconciliationsDaoManager(this);
}

class CustomerBottleReconciliationsDaoManager {
  final _$CustomerBottleReconciliationsDaoMixin _db;
  CustomerBottleReconciliationsDaoManager(this._db);
  $$CustomerBottleReconciliationsTableTableTableManager
  get customerBottleReconciliationsTable =>
      $$CustomerBottleReconciliationsTableTableTableManager(
        _db.attachedDatabase,
        _db.customerBottleReconciliationsTable,
      );
}
