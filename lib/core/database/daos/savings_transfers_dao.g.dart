// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'savings_transfers_dao.dart';

// ignore_for_file: type=lint
mixin _$SavingsTransfersDaoMixin on DatabaseAccessor<AppDatabase> {
  $SavingsTransfersTableTable get savingsTransfersTable =>
      attachedDatabase.savingsTransfersTable;
  SavingsTransfersDaoManager get managers => SavingsTransfersDaoManager(this);
}

class SavingsTransfersDaoManager {
  final _$SavingsTransfersDaoMixin _db;
  SavingsTransfersDaoManager(this._db);
  $$SavingsTransfersTableTableTableManager get savingsTransfersTable =>
      $$SavingsTransfersTableTableTableManager(
        _db.attachedDatabase,
        _db.savingsTransfersTable,
      );
}
