// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bottle_transactions_dao.dart';

// ignore_for_file: type=lint
mixin _$BottleTransactionsDaoMixin on DatabaseAccessor<AppDatabase> {
  $BottleTransactionsTableTable get bottleTransactionsTable =>
      attachedDatabase.bottleTransactionsTable;
  BottleTransactionsDaoManager get managers =>
      BottleTransactionsDaoManager(this);
}

class BottleTransactionsDaoManager {
  final _$BottleTransactionsDaoMixin _db;
  BottleTransactionsDaoManager(this._db);
  $$BottleTransactionsTableTableTableManager get bottleTransactionsTable =>
      $$BottleTransactionsTableTableTableManager(
        _db.attachedDatabase,
        _db.bottleTransactionsTable,
      );
}
