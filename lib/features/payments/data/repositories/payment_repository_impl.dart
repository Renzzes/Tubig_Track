import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/utils/payment_status_utils.dart';
import '../../domain/entities/payment.dart';
import '../../domain/repositories/payment_repository.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final AppDatabase _db;

  PaymentRepositoryImpl(this._db);

  Payment _map(PaymentsTableData row) {
    return Payment(
      id: row.id,
      customerId: row.customerId,
      deliveryId: row.deliveryId,
      amount: row.amount,
      paymentDate: row.paymentDate,
      notes: row.notes,
    );
  }

  @override
  Future<List<Payment>> getByCustomer(String customerId) async {
    final rows = await _db.paymentsDao.getByCustomer(customerId);
    return rows.map(_map).toList();
  }

  @override
  Stream<List<Payment>> watchByCustomer(String customerId) {
    return _db.paymentsDao.watchByCustomer(customerId).map(
          (rows) => rows.map(_map).toList(),
        );
  }

  @override
  Future<List<Payment>> getByDateRange(DateTime start, DateTime end) async {
    final rows = await _db.paymentsDao.getByDateRange(start, end);
    return rows.map(_map).toList();
  }

  @override
  Future<void> recordPayment({
    required String customerId,
    required double amount,
    String? deliveryId,
    String? notes,
  }) async {
    await _db.transaction(() async {
      await _db.paymentsDao.insertPayment(
        PaymentsTableCompanion.insert(
          id: const Uuid().v4(),
          customerId: customerId,
          deliveryId: Value(deliveryId),
          amount: amount,
          paymentDate: Value(DateTime.now()),
          notes: Value(notes),
        ),
      );

      if (deliveryId != null) {
        await _applyPaymentToDelivery(deliveryId, amount);
      } else {
        var remaining = amount;
        final unpaidDeliveries =
            await _db.deliveriesDao.getUnpaidByCustomer(customerId);
        for (final d in unpaidDeliveries) {
          if (remaining <= 0) break;
          final apply = remaining.clamp(0.0, d.remainingBalance);
          remaining -= apply;
          await _applyPaymentToDelivery(d.id, apply);
        }
      }
    });
  }

  Future<void> _applyPaymentToDelivery(String deliveryId, double amount) async {
    final delivery = await _db.deliveriesDao.getById(deliveryId);
    if (delivery == null) return;

    final newPaid = delivery.amountPaid + amount;
    final newBalance = PaymentStatusUtils.computeRemainingBalance(
      totalAmount: delivery.totalAmount,
      amountPaid: newPaid,
    );
    final newStatus = PaymentStatusUtils.computeStatus(
      totalAmount: delivery.totalAmount,
      amountPaid: newPaid,
    );

    var deliveryStatus = delivery.deliveryStatus;
    if (newStatus == 'paid' && deliveryStatus != 'cancelled') {
      deliveryStatus = 'completed';
    }

    await _db.deliveriesDao.updateDelivery(
      DeliveriesTableCompanion(
        id: Value(delivery.id),
        customerId: Value(delivery.customerId),
        quantity: Value(delivery.quantity),
        pricePerBottle: Value(delivery.pricePerBottle),
        totalAmount: Value(delivery.totalAmount),
        paymentStatus: Value(newStatus),
        amountPaid: Value(newPaid),
        remainingBalance: Value(newBalance),
        deliveryDate: Value(delivery.deliveryDate),
        deliveryTime: Value(delivery.deliveryTime),
        deliveryStatus: Value(deliveryStatus),
        notes: Value(delivery.notes),
      ),
    );
  }
}
