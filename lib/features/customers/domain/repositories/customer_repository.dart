import '../entities/customer.dart';

abstract class CustomerRepository {
  Stream<List<Customer>> watchAll();
  Stream<List<Customer>> watchSearch(String query);
  Future<List<Customer>> getAll();
  Future<Customer?> getById(String id);
  Future<void> addCustomer(Customer customer);
  Future<void> updateCustomer(Customer customer);
  Future<void> deleteCustomer(String id);
  Future<CustomerStats> getCustomerStats(String customerId);
}
