import 'package:drift/drift.dart';

class CustomerBottleReconciliationsTable extends Table {
  @override
  String get tableName => 'customer_bottle_reconciliations';

  TextColumn get id => text()();
  TextColumn get customerId => text()();
  IntColumn get expectedCount => integer()();
  IntColumn get actualCount => integer()();
  IntColumn get variance => integer()();
  TextColumn get reason => text().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get adjustmentApplied =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
