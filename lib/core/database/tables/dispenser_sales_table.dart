import 'package:drift/drift.dart';

class DispenserSalesTable extends Table {
  @override
  String get tableName => 'dispenser_sales';

  TextColumn get id => text()();
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
