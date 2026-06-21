import 'package:drift/drift.dart';

class CustomerDepositsTable extends Table {
  @override
  String get tableName => 'customer_deposits';

  TextColumn get id => text()();
  TextColumn get customerId => text()();
  RealColumn get amount => real()();
  // deposit_added | deposit_used | deposit_adjustment
  TextColumn get transactionType => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get notes => text().nullable()();
  TextColumn get deliveryId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
