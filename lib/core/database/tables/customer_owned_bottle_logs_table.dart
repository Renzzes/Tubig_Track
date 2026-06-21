import 'package:drift/drift.dart';

class CustomerOwnedBottleLogsTable extends Table {
  @override
  String get tableName => 'customer_owned_bottle_logs';

  TextColumn get id => text()();
  TextColumn get customerId => text()();
  /// set_balance | adjust_balance | collected | delivery_filled
  TextColumn get eventType => text()();
  IntColumn get businessOwnedDelta =>
      integer().withDefault(const Constant(0))();
  IntColumn get customerOwnedDelta =>
      integer().withDefault(const Constant(0))();
  IntColumn get businessOwnedAfter => integer()();
  IntColumn get customerOwnedAfter => integer()();
  DateTimeColumn get date => dateTime()();
  TextColumn get notes => text().nullable()();
  TextColumn get deliveryId => text().nullable()();
  TextColumn get bottleTransactionId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
