import 'package:drift/drift.dart';

class SavingsTransfersTable extends Table {
  @override
  String get tableName => 'savings_transfers';

  TextColumn get id => text()();
  RealColumn get amount => real()();
  /// `transfer` (to savings) or `withdraw` (from savings).
  TextColumn get transferType => text()();
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
