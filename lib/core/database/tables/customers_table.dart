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
  /// Bottles owned by the customer (not business inventory).
  IntColumn get customerOwnedBottlesHeld =>
      integer().withDefault(const Constant(0))();
  /// Date of the most recent completed physical bottle count.
  DateTimeColumn get lastPhysicalCountDate => dateTime().nullable()();
  BoolColumn get lastPhysicalCountVerified =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
