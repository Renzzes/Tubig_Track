import 'package:drift/drift.dart';

class SupplyPurchasesTable extends Table {
  @override
  String get tableName => 'supply_purchases';

  TextColumn get id => text()();
  DateTimeColumn get purchaseDate =>
      dateTime().withDefault(currentDateAndTime)();
  TextColumn get supplierName => text()();
  TextColumn get supplierId => text().nullable()();
  // Gallons | Bottles | Caps | Water Stocks | Others
  TextColumn get itemType => text()();
  IntColumn get quantity => integer()();
  RealColumn get unitCost => real()();
  RealColumn get totalCost => real()();
  TextColumn get notes => text().nullable()();
  TextColumn get expenseId => text()();
  TextColumn get bottleTransactionId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
