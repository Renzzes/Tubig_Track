// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'savings_dao.dart';

// ignore_for_file: type=lint
mixin _$SavingsDaoMixin on DatabaseAccessor<AppDatabase> {
  $SavingsContributionsTableTable get savingsContributionsTable =>
      attachedDatabase.savingsContributionsTable;
  SavingsDaoManager get managers => SavingsDaoManager(this);
}

class SavingsDaoManager {
  final _$SavingsDaoMixin _db;
  SavingsDaoManager(this._db);
  $$SavingsContributionsTableTableTableManager get savingsContributionsTable =>
      $$SavingsContributionsTableTableTableManager(
        _db.attachedDatabase,
        _db.savingsContributionsTable,
      );
}
