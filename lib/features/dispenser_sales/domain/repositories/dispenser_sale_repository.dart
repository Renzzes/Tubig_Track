import '../entities/dispenser_sale.dart';

abstract class DispenserSaleRepository {
  Stream<List<DispenserSale>> watchAll();
  Future<List<DispenserSale>> getAll();
  Future<List<DispenserSale>> getByDateRange(DateTime start, DateTime end);
  Future<void> addSale(DispenserSale sale);
  Future<void> deleteSale(String id);
}
