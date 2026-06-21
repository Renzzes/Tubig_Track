import '../entities/walk_in_sale.dart';

abstract class WalkInRepository {
  Stream<List<WalkInSale>> watchAll();
  Future<List<WalkInSale>> getAll();
  Future<List<WalkInSale>> getByDateRange(DateTime start, DateTime end);
  Future<List<WalkInSale>> getByCustomer(String customerId);
  Future<void> recordWalkIn(WalkInSale sale);
  Future<void> deleteWalkIn(String id);
  Future<double> getTotalRevenueForDateRange(DateTime start, DateTime end);
  Future<int> getCountForDateRange(DateTime start, DateTime end);
  Future<int> getTotalBottlesForDateRange(DateTime start, DateTime end);
}
