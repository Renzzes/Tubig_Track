import 'package:drift/drift.dart';

class BottleTransactionsTable extends Table {
  @override
  String get tableName => 'bottle_transactions';

  TextColumn get id => text()();
  TextColumn get customerId => text().nullable()();
  // transactionType: 'borrow' | 'return' | 'damaged' | 'purchase'
  TextColumn get transactionType => text()();
  IntColumn get quantity => integer()();
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
