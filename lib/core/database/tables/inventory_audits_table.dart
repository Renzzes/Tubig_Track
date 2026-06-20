import 'package:drift/drift.dart';

class InventoryAuditsTable extends Table {
  @override
  String get tableName => 'inventory_audits';

  TextColumn get id => text()();
  DateTimeColumn get auditDate => dateTime().withDefault(currentDateAndTime)();
  IntColumn get systemCount => integer()();
  IntColumn get physicalCount => integer()();
  IntColumn get difference => integer()();
  TextColumn get actionTaken => text()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
