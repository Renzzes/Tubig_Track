// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deliveries_dao.dart';

// ignore_for_file: type=lint
mixin _$DeliveriesDaoMixin on DatabaseAccessor<AppDatabase> {
  $DeliveriesTableTable get deliveriesTable => attachedDatabase.deliveriesTable;
  $CustomersTableTable get customersTable => attachedDatabase.customersTable;
  DeliveriesDaoManager get managers => DeliveriesDaoManager(this);
}

class DeliveriesDaoManager {
  final _$DeliveriesDaoMixin _db;
  DeliveriesDaoManager(this._db);
  $$DeliveriesTableTableTableManager get deliveriesTable =>
      $$DeliveriesTableTableTableManager(
        _db.attachedDatabase,
        _db.deliveriesTable,
      );
  $$CustomersTableTableTableManager get customersTable =>
      $$CustomersTableTableTableManager(
        _db.attachedDatabase,
        _db.customersTable,
      );
}
