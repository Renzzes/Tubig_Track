import 'package:drift/drift.dart';

class ExpensesTable extends Table {
  @override
  String get tableName => 'expenses';

  TextColumn get id => text()();
  // category: 'Fuel' | 'Electricity' | 'Water' | 'Maintenance' | 'Salary' | 'Supplies' | 'Others'
  TextColumn get category => text()();
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
