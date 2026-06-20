import '../entities/supplier.dart';

abstract class SupplierRepository {
  Stream<List<Supplier>> watchAll();
  Future<List<Supplier>> getAll();
  Future<Supplier?> getById(String id);
  Future<SupplierAnalytics> getAnalytics(String supplierId);
  Future<void> addSupplier(Supplier supplier);
  Future<void> updateSupplier(Supplier supplier);
  Future<void> deleteSupplier(String id);
}
