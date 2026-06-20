// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'savings_goals_dao.dart';

// ignore_for_file: type=lint
mixin _$SavingsGoalsDaoMixin on DatabaseAccessor<AppDatabase> {
  $SavingsGoalsTableTable get savingsGoalsTable =>
      attachedDatabase.savingsGoalsTable;
  SavingsGoalsDaoManager get managers => SavingsGoalsDaoManager(this);
}

class SavingsGoalsDaoManager {
  final _$SavingsGoalsDaoMixin _db;
  SavingsGoalsDaoManager(this._db);
  $$SavingsGoalsTableTableTableManager get savingsGoalsTable =>
      $$SavingsGoalsTableTableTableManager(
        _db.attachedDatabase,
        _db.savingsGoalsTable,
      );
}
