import 'package:drift/drift.dart';

class CustomersTable extends Table {
  @override
  String get tableName => 'customers';

  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get notes => text().nullable()();
  /// Last recorded physical count pending reconciliation adjustment.
  IntColumn get pendingPhysicalBottleCount => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
