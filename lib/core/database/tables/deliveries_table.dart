import 'package:drift/drift.dart';

class DeliveriesTable extends Table {
  @override
  String get tableName => 'deliveries';

  TextColumn get id => text()();
  TextColumn get customerId => text()();
  IntColumn get quantity => integer()();
  RealColumn get pricePerBottle => real()();
  RealColumn get totalAmount => real()();
  // paymentStatus: 'paid' | 'unpaid' | 'partial'
  TextColumn get paymentStatus =>
      text().withDefault(const Constant('unpaid'))();
  RealColumn get amountPaid => real().withDefault(const Constant(0.0))();
  RealColumn get remainingBalance => real().withDefault(const Constant(0.0))();
  DateTimeColumn get deliveryDate =>
      dateTime().withDefault(currentDateAndTime)();
  // deliveryTime: "09:00 AM" format, nullable
  TextColumn get deliveryTime => text().nullable()();
  // deliveryStatus: 'scheduled' | 'in_progress' | 'completed' | 'cancelled'
  TextColumn get deliveryStatus =>
      text().withDefault(const Constant('completed'))();
  TextColumn get notes => text().nullable()();
  TextColumn get receiptNumber => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
