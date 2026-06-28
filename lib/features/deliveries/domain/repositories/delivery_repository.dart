import '../entities/delivery.dart';

enum DeliveryFilter { today, completed, all }

enum DeliveryDateRangeFilter {
  none,
  today,
  thisWeek,
  thisMonth,
  custom,
}

enum OverdueSort { highestBalance, oldestDebt, newestDebt }

abstract class DeliveryRepository {
  Stream<List<Delivery>> watchAll();
  Stream<List<Delivery>> watchByFilter(
    DeliveryFilter filter, {
    DeliveryDateRangeFilter dateRange = DeliveryDateRangeFilter.none,
    DateTime? customStart,
    DateTime? customEnd,
  });
  Future<List<Delivery>> getAll();
  Future<List<Delivery>> getByCustomer(String customerId);
  Stream<List<Delivery>> watchByCustomer(String customerId);
  Future<List<Delivery>> getByDateRange(DateTime start, DateTime end);
  Future<Delivery?> getById(String id);
  Future<void> createDelivery(
    Delivery delivery, {
    double? cashReceived,
    double excessToDeposit = 0,
  });
  Future<void> updateDelivery(
    Delivery delivery, {
    double? cashReceived,
    double excessToDeposit = 0,
  });
  Future<void> deleteDelivery(String id);
  Future<void> syncAllPaymentStatuses();
}
