import 'package:drift/drift.dart';

class SuppliersTable extends Table {
  @override
  String get tableName => 'suppliers';

  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get contactPerson => text().nullable()();
  TextColumn get mobile => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
