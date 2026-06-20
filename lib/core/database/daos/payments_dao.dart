import 'package:drift/drift.dart';
import '../tables/payments_table.dart';
import '../app_database.dart';

part 'payments_dao.g.dart';

@DriftAccessor(tables: [PaymentsTable])
class PaymentsDao extends DatabaseAccessor<AppDatabase>
    with _$PaymentsDaoMixin {
  PaymentsDao(super.db);

  Stream<List<PaymentsTableData>> watchAll() {
    return (select(paymentsTable)
          ..orderBy([(t) => OrderingTerm.desc(t.paymentDate)]))
        .watch();
  }

  Future<List<PaymentsTableData>> getAll() {
    return (select(paymentsTable)
          ..orderBy([(t) => OrderingTerm.desc(t.paymentDate)]))
        .get();
  }

  Future<List<PaymentsTableData>> getByCustomer(String customerId) {
    return (select(paymentsTable)
          ..where((t) => t.customerId.equals(customerId))
          ..orderBy([(t) => OrderingTerm.desc(t.paymentDate)]))
        .get();
  }

  Stream<List<PaymentsTableData>> watchByCustomer(String customerId) {
    return (select(paymentsTable)
          ..where((t) => t.customerId.equals(customerId))
          ..orderBy([(t) => OrderingTerm.desc(t.paymentDate)]))
        .watch();
  }

  Future<List<PaymentsTableData>> getByDelivery(String deliveryId) {
    return (select(paymentsTable)
          ..where((t) => t.deliveryId.equals(deliveryId))
          ..orderBy([(t) => OrderingTerm.desc(t.paymentDate)]))
        .get();
  }

  Future<List<PaymentsTableData>> getByDateRange(
    DateTime start,
    DateTime end,
  ) {
    return (select(paymentsTable)
          ..where(
            (t) =>
                t.paymentDate.isBiggerOrEqualValue(start) &
                t.paymentDate.isSmallerOrEqualValue(end),
          ))
        .get();
  }

  Future<int> insertPayment(PaymentsTableCompanion companion) {
    return into(paymentsTable).insert(companion);
  }

  Future<int> deletePayment(String id) {
    return (delete(paymentsTable)..where((t) => t.id.equals(id))).go();
  }

  Future<int> deleteByDelivery(String deliveryId) {
    return (delete(paymentsTable)
          ..where((t) => t.deliveryId.equals(deliveryId)))
        .go();
  }

  Future<double> getTotalForDateRange(DateTime start, DateTime end) async {
    final amountExpr = paymentsTable.amount.sum();
    final query = selectOnly(paymentsTable)
      ..addColumns([amountExpr])
      ..where(
        paymentsTable.paymentDate.isBiggerOrEqualValue(start) &
            paymentsTable.paymentDate.isSmallerOrEqualValue(end),
      );
    final row = await query.getSingle();
    return row.read(amountExpr) ?? 0.0;
  }

  Future<double> getTotalByCustomer(String customerId) async {
    final amountExpr = paymentsTable.amount.sum();
    final query = selectOnly(paymentsTable)
      ..addColumns([amountExpr])
      ..where(paymentsTable.customerId.equals(customerId));
    final row = await query.getSingle();
    return row.read(amountExpr) ?? 0.0;
  }
}
