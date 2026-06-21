import '../../../../core/database/app_database.dart';
import '../../domain/entities/customer_deposit.dart';
import '../../domain/repositories/customer_deposit_repository.dart';

class CustomerDepositRepositoryImpl implements CustomerDepositRepository {
  final AppDatabase _db;

  CustomerDepositRepositoryImpl(this._db);

  CustomerDeposit _map(CustomerDepositsTableData row) {
    return CustomerDeposit(
      id: row.id,
      customerId: row.customerId,
      amount: row.amount,
      transactionType: CustomerDeposit.typeFromString(row.transactionType),
      createdAt: row.createdAt,
      notes: row.notes,
      deliveryId: row.deliveryId,
    );
  }

  @override
  Stream<List<CustomerDeposit>> watchByCustomer(String customerId) {
    return _db.customerDepositsDao.watchByCustomer(customerId).map(
          (rows) => rows.map(_map).toList(),
        );
  }

  @override
  Future<List<CustomerDeposit>> getByCustomer(String customerId) async {
    final rows = await _db.customerDepositsDao.getByCustomer(customerId);
    return rows.map(_map).toList();
  }

  @override
  Future<double> getBalanceForCustomer(String customerId) {
    return _db.customerDepositsDao.getBalanceForCustomer(customerId);
  }

  @override
  Future<double> getAvailableForDelivery(
    String customerId, {
    String? excludeDeliveryId,
  }) async {
    if (excludeDeliveryId != null) {
      return _db.customerDepositsDao.getBalanceExcludingDelivery(
        customerId,
        excludeDeliveryId,
      );
    }
    return getBalanceForCustomer(customerId);
  }

  @override
  Future<DepositSummary> getSummary() async {
    final held = await _db.customerDepositsDao.getTotalDepositsHeld();
    final active = await _db.customerDepositsDao.getCustomersWithDepositsCount();
    final added = await _db.customerDepositsDao.getTotalAdded();
    final used = await _db.customerDepositsDao.getTotalUsed();
    return DepositSummary(
      totalDepositsHeld: held,
      activeCustomersWithDeposits: active,
      totalDepositsAdded: added,
      totalDepositsUsed: used,
      currentDepositLiability: held,
    );
  }
}
