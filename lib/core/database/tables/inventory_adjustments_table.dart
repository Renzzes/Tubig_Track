import 'package:drift/drift.dart';

class InventoryAdjustmentsTable extends Table {
  @override
  String get tableName => 'inventory_adjustments';

  TextColumn get id => text()();
  DateTimeColumn get adjustmentDate =>
      dateTime().withDefault(currentDateAndTime)();
  IntColumn get quantity => integer()();
  TextColumn get reason => text()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
