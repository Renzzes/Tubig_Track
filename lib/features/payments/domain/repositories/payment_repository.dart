import '../entities/payment.dart';

abstract class PaymentRepository {
  Future<List<Payment>> getByCustomer(String customerId);
  Stream<List<Payment>> watchByCustomer(String customerId);
  Stream<List<Payment>> watchAll();
  Future<List<Payment>> getByDateRange(DateTime start, DateTime end);
  Future<void> recordPayment({
    required String customerId,
    required double amount,
    String? deliveryId,
    String? notes,
  });
}
