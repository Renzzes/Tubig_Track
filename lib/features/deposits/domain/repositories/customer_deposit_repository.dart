import '../../domain/entities/customer_deposit.dart';

abstract class CustomerDepositRepository {
  Stream<List<CustomerDeposit>> watchByCustomer(String customerId);
  Future<List<CustomerDeposit>> getByCustomer(String customerId);
  Future<double> getBalanceForCustomer(String customerId);
  Future<double> getAvailableForDelivery(
    String customerId, {
    String? excludeDeliveryId,
  });
  Future<DepositSummary> getSummary();
}

class DepositSummary {
  final double totalDepositsHeld;
  final int activeCustomersWithDeposits;
  final double totalDepositsAdded;
  final double totalDepositsUsed;
  final double currentDepositLiability;

  const DepositSummary({
    required this.totalDepositsHeld,
    required this.activeCustomersWithDeposits,
    required this.totalDepositsAdded,
    required this.totalDepositsUsed,
    required this.currentDepositLiability,
  });
}
