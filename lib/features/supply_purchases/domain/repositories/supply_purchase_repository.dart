import '../entities/supply_purchase.dart';

abstract class SupplyPurchaseRepository {
  Stream<List<SupplyPurchase>> watchAll();
  Future<List<SupplyPurchase>> getAll();
  Future<List<SupplyPurchase>> getByDateRange(DateTime start, DateTime end);
  Future<SupplyPurchase?> getById(String id);
  Future<List<SupplierSummaryEntry>> getSupplierSummary(
    DateTime start,
    DateTime end,
  );
  Future<void> createPurchase(SupplyPurchase purchase);
  Future<void> deletePurchase(String id);
}
