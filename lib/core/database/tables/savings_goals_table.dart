import 'package:drift/drift.dart';

class SavingsGoalsTable extends Table {
  @override
  String get tableName => 'savings_goals';

  TextColumn get id => text()();
  TextColumn get name => text()();
  RealColumn get targetAmount => real()();
  DateTimeColumn get targetDate => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
