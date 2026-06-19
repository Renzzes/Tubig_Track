import 'package:drift/drift.dart';
import '../tables/customers_table.dart';
import '../tables/deliveries_table.dart';
import '../app_database.dart';

part 'deliveries_dao.g.dart';

@DriftAccessor(tables: [DeliveriesTable, CustomersTable])
class DeliveriesDao extends DatabaseAccessor<AppDatabase>
    with _$DeliveriesDaoMixin {
  DeliveriesDao(super.db);

  Stream<List<DeliveriesTableData>> watchAll() {
    return (select(deliveriesTable)
          ..orderBy([(t) => OrderingTerm.asc(t.deliveryDate)]))
        .watch();
  }

  Future<List<DeliveriesTableData>> getAll() {
    return (select(deliveriesTable)
          ..orderBy([(t) => OrderingTerm.asc(t.deliveryDate)]))
        .get();
  }

  /// Today tab: scheduled or in-progress deliveries for today only.
  Stream<List<DeliveriesTableData>> watchTodayActive() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return (select(deliveriesTable)
          ..where(
            (t) =>
                t.deliveryDate.isBiggerOrEqualValue(start) &
                t.deliveryDate.isSmallerThanValue(end) &
                (t.deliveryStatus.equals('scheduled') |
                    t.deliveryStatus.equals('in_progress')),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.deliveryDate)]))
        .watch();
  }

  /// Completed tab: completed deliveries OR fully paid deliveries.
  Stream<List<DeliveriesTableData>> watchCompletedOrPaid() {
    return (select(deliveriesTable)
          ..where(
            (t) =>
                t.deliveryStatus.equals('completed') |
                t.paymentStatus.equals('paid'),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.deliveryDate)]))
        .watch();
  }

  Stream<List<DeliveriesTableData>> watchCompletedOrPaidInRange(
    DateTime start,
    DateTime end,
  ) {
    return (select(deliveriesTable)
          ..where(
            (t) =>
                t.deliveryDate.isBiggerOrEqualValue(start) &
                t.deliveryDate.isSmallerOrEqualValue(end) &
                (t.deliveryStatus.equals('completed') |
                    t.paymentStatus.equals('paid')),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.deliveryDate)]))
        .watch();
  }

  Stream<List<DeliveriesTableData>> watchAllInRange(
    DateTime start,
    DateTime end,
  ) {
    return (select(deliveriesTable)
          ..where(
            (t) =>
                t.deliveryDate.isBiggerOrEqualValue(start) &
                t.deliveryDate.isSmallerOrEqualValue(end),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.deliveryDate)]))
        .watch();
  }

  /// Overdue: unpaid/partial where delivery date is before today.
  Future<List<DeliveriesTableData>> getOverdueDeliveries() {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    return (select(deliveriesTable)
          ..where(
            (t) =>
                t.deliveryDate.isSmallerThanValue(startOfToday) &
                (t.paymentStatus.equals('unpaid') |
                    t.paymentStatus.equals('partial')),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.deliveryDate)]))
        .get();
  }

  /// Today's scheduled/in-progress for delivery reminders.
  Future<List<DeliveriesTableData>> getTodayActiveDeliveries() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return (select(deliveriesTable)
          ..where(
            (t) =>
                t.deliveryDate.isBiggerOrEqualValue(start) &
                t.deliveryDate.isSmallerThanValue(end) &
                (t.deliveryStatus.equals('scheduled') |
                    t.deliveryStatus.equals('in_progress')),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.deliveryDate)]))
        .get();
  }

  Stream<List<DeliveriesTableData>> watchToday() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return (select(deliveriesTable)
          ..where(
            (t) =>
                t.deliveryDate.isBiggerOrEqualValue(start) &
                t.deliveryDate.isSmallerThanValue(end),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.deliveryDate)]))
        .watch();
  }

  Future<List<DeliveriesTableData>> getToday() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return (select(deliveriesTable)
          ..where(
            (t) =>
                t.deliveryDate.isBiggerOrEqualValue(start) &
                t.deliveryDate.isSmallerThanValue(end),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.deliveryDate)]))
        .get();
  }

  Stream<List<DeliveriesTableData>> watchTomorrow() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day + 1);
    final end = start.add(const Duration(days: 1));
    return (select(deliveriesTable)
          ..where(
            (t) =>
                t.deliveryDate.isBiggerOrEqualValue(start) &
                t.deliveryDate.isSmallerThanValue(end),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.deliveryDate)]))
        .watch();
  }

  Stream<List<DeliveriesTableData>> watchUpcoming() {
    final now = DateTime.now();
    final dayAfterTomorrow = DateTime(now.year, now.month, now.day + 2);
    return (select(deliveriesTable)
          ..where(
            (t) =>
                t.deliveryDate.isBiggerOrEqualValue(dayAfterTomorrow) &
                (t.deliveryStatus.equals('scheduled') |
                    t.deliveryStatus.equals('in_progress')),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.deliveryDate)]))
        .watch();
  }

  Stream<List<DeliveriesTableData>> watchCompleted() {
    return watchCompletedOrPaid();
  }

  Future<List<DeliveriesTableData>> getByCustomer(String customerId) {
    return (select(deliveriesTable)
          ..where((t) => t.customerId.equals(customerId))
          ..orderBy([(t) => OrderingTerm.desc(t.deliveryDate)]))
        .get();
  }

  Stream<List<DeliveriesTableData>> watchByCustomer(String customerId) {
    return (select(deliveriesTable)
          ..where((t) => t.customerId.equals(customerId))
          ..orderBy([(t) => OrderingTerm.desc(t.deliveryDate)]))
        .watch();
  }

  Future<List<DeliveriesTableData>> getByDateRange(
    DateTime start,
    DateTime end,
  ) {
    return (select(deliveriesTable)
          ..where(
            (t) =>
                t.deliveryDate.isBiggerOrEqualValue(start) &
                t.deliveryDate.isSmallerOrEqualValue(end),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.deliveryDate)]))
        .get();
  }

  Future<List<DeliveriesTableData>> getUnpaid() {
    return (select(deliveriesTable)
          ..where(
            (t) =>
                t.paymentStatus.equals('unpaid') |
                t.paymentStatus.equals('partial'),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.deliveryDate)]))
        .get();
  }

  Future<List<DeliveriesTableData>> getUnpaidByCustomer(String customerId) {
    return (select(deliveriesTable)
          ..where(
            (t) =>
                t.customerId.equals(customerId) &
                (t.paymentStatus.equals('unpaid') |
                    t.paymentStatus.equals('partial')),
          ))
        .get();
  }

  Future<List<DeliveriesTableData>> getUpcomingForDashboard() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final weekOut = DateTime(now.year, now.month, now.day + 8);
    return (select(deliveriesTable)
          ..where(
            (t) =>
                t.deliveryDate.isBiggerOrEqualValue(tomorrow) &
                t.deliveryDate.isSmallerThanValue(weekOut) &
                (t.deliveryStatus.equals('scheduled') |
                    t.deliveryStatus.equals('in_progress')),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.deliveryDate)]))
        .get();
  }

  Future<int> getTodayCount() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    final countExpr = deliveriesTable.id.count();
    final query = selectOnly(deliveriesTable)
      ..addColumns([countExpr])
      ..where(
        deliveriesTable.deliveryDate.isBiggerOrEqualValue(start) &
            deliveriesTable.deliveryDate.isSmallerThanValue(end) &
            (deliveriesTable.deliveryStatus.equals('scheduled') |
                deliveriesTable.deliveryStatus.equals('in_progress')),
      );
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }

  Future<DeliveriesTableData?> getById(String id) {
    return (select(deliveriesTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<int> insertDelivery(DeliveriesTableCompanion companion) {
    return into(deliveriesTable).insert(companion);
  }

  Future<bool> updateDelivery(DeliveriesTableCompanion companion) {
    return update(deliveriesTable).replace(companion);
  }

  Future<int> deleteDelivery(String id) {
    return (delete(deliveriesTable)..where((t) => t.id.equals(id))).go();
  }

  Future<double> getTotalSalesForDateRange(DateTime start, DateTime end) async {
    final amountExpr = deliveriesTable.totalAmount.sum();
    final query = selectOnly(deliveriesTable)
      ..addColumns([amountExpr])
      ..where(
        deliveriesTable.deliveryDate.isBiggerOrEqualValue(start) &
            deliveriesTable.deliveryDate.isSmallerOrEqualValue(end),
      );
    final row = await query.getSingle();
    return row.read(amountExpr) ?? 0.0;
  }

  Future<double> getTotalReceivables() async {
    final balanceExpr = deliveriesTable.remainingBalance.sum();
    final query = selectOnly(deliveriesTable)
      ..addColumns([balanceExpr])
      ..where(
        deliveriesTable.paymentStatus.equals('unpaid') |
            deliveriesTable.paymentStatus.equals('partial'),
      );
    final row = await query.getSingle();
    return row.read(balanceExpr) ?? 0.0;
  }

  Future<double> getTotalAmountPaidForDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final amountExpr = deliveriesTable.amountPaid.sum();
    final query = selectOnly(deliveriesTable)
      ..addColumns([amountExpr])
      ..where(
        deliveriesTable.deliveryDate.isBiggerOrEqualValue(start) &
            deliveriesTable.deliveryDate.isSmallerOrEqualValue(end),
      );
    final row = await query.getSingle();
    return row.read(amountExpr) ?? 0.0;
  }
}
