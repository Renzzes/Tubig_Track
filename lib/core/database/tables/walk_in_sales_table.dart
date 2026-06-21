import 'package:drift/drift.dart';

class WalkInSalesTable extends Table {
  @override
  String get tableName => 'walk_in_sales';

  TextColumn get id => text()();
  TextColumn get customerId => text().nullable()();
  TextColumn get walkInType => text()();
  IntColumn get businessOwnedQuantity => integer().withDefault(const Constant(0))();
  IntColumn get customerOwnedQuantity => integer().withDefault(const Constant(0))();
  IntColumn get returnedEmptyQuantity => integer().withDefault(const Constant(0))();
  RealColumn get pricePerBottle => real()();
  RealColumn get totalAmount => real()();
  TextColumn get paymentMethod => text().withDefault(const Constant('Cash'))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
