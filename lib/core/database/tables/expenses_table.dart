import 'package:drift/drift.dart';

class ExpensesTable extends Table {
  @override
  String get tableName => 'expenses';

  TextColumn get id => text()();
  TextColumn get category => text()();
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
  TextColumn get notes => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get supplier => text().nullable()();
  IntColumn get quantity => integer().nullable()();
  RealColumn get unitCost => real().nullable()();
  TextColumn get supplyPurchaseId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
