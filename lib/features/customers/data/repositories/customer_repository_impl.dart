import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/inventory_calculator.dart';
import '../../../../core/utils/customer_operational_bottles_utils.dart';
import '../../domain/entities/customer.dart';
import '../../../deliveries/domain/entities/delivery.dart';
import '../../domain/repositories/customer_repository.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final AppDatabase _db;

  CustomerRepositoryImpl(this._db);

  Customer _map(CustomersTableData row) {
    return Customer(
      id: row.id,
      name: row.name,
      phone: row.phone,
      address: row.address,
      notes: row.notes,
      pendingPhysicalBottleCount: row.pendingPhysicalBottleCount,
      customerOwnedBottlesHeld: row.customerOwnedBottlesHeld,
      lastPhysicalCountDate: row.lastPhysicalCountDate,
      lastPhysicalCountVerified: row.lastPhysicalCountVerified,
      createdAt: row.createdAt,
    );
  }

  @override
  Stream<List<Customer>> watchAll() {
    return _db.customersDao.watchAll().map(
          (rows) => rows.map(_map).toList(),
        );
  }

  @override
  Stream<List<Customer>> watchSearch(String query) {
    return _db.customersDao.watchSearch(query).map(
          (rows) => rows.map(_map).toList(),
        );
  }

  @override
  Future<List<Customer>> getAll() async {
    final rows = await _db.customersDao.getAll();
    return rows.map(_map).toList();
  }

  @override
  Future<Customer?> getById(String id) async {
    final row = await _db.customersDao.getById(id);
    return row != null ? _map(row) : null;
  }

  @override
  Future<void> addCustomer(Customer customer) async {
    await _db.customersDao.insertCustomer(
      CustomersTableCompanion.insert(
        id: customer.id,
        name: customer.name,
        phone: Value(customer.phone),
        address: Value(customer.address),
        notes: Value(customer.notes),
        createdAt: Value(customer.createdAt),
      ),
    );
  }

  @override
  Future<void> updateCustomer(Customer customer) async {
    await _db.customersDao.updateCustomer(
      CustomersTableCompanion(
        id: Value(customer.id),
        name: Value(customer.name),
        phone: Value(customer.phone),
        address: Value(customer.address),
        notes: Value(customer.notes),
      ),
    );
  }

  @override
  Future<void> deleteCustomer(String id) async {
    await _db.customersDao.deleteCustomer(id);
  }

  @override
  Future<CustomerStats> getCustomerStats(String customerId) async {
    final borrowed = await _db.bottleTransactionsDao.getTotalByTypeForCustomer(
      'borrow',
      customerId,
    );
    final returned = await _db.bottleTransactionsDao.getTotalByTypeForCustomer(
      'return',
      customerId,
    );
    final damaged = await _db.bottleTransactionsDao.getTotalByTypeForCustomer(
      'damaged',
      customerId,
    );
    final adjustments = await _db.bottleTransactionsDao.getTotalByTypeForCustomer(
      'customer_adjustment',
      customerId,
    );

    final initialRow = await _db.bottleTransactionsDao.getById(
      AppConstants.initialBalanceTransactionId(customerId),
    );
    final hasInitialBalance = initialRow != null;
    final initialBottleBalance = initialRow?.quantity ?? 0;

    final bottlesHeld = InventoryCalculator.customerBottlesHeld(
      delivered: borrowed,
      collected: returned,
      manualAdjustments: adjustments,
    );

    final unpaidDeliveries =
        await _db.deliveriesDao.getUnpaidByCustomer(customerId);
    final unpaidBalance = unpaidDeliveries.fold<double>(
      0,
      (sum, d) => sum + d.remainingBalance,
    );

    final allDeliveries = await _db.deliveriesDao.getByCustomer(customerId);
    final completedDeliveries = allDeliveries
        .where((d) => d.deliveryStatus == 'completed')
        .toList();

    final totalAmountPaid = allDeliveries.fold<double>(
      0,
      (sum, d) => sum + d.amountPaid,
    );
    final lifetimeRevenue = completedDeliveries.fold<double>(
      0,
      (sum, d) => sum + d.totalAmount,
    );
    final lifetimeBottles = completedDeliveries.fold<int>(
      0,
      (sum, d) => sum + d.quantity,
    );
    final lastDeliveryDate = completedDeliveries.isNotEmpty
        ? completedDeliveries.first.deliveryDate
        : null;

    final payments = await _db.paymentsDao.getByCustomer(customerId);
    final bottleTxs = await _db.bottleTransactionsDao.getByCustomer(customerId);

    DateTime? lastActivityDate = lastDeliveryDate;
    for (final p in payments) {
      if (lastActivityDate == null || p.paymentDate.isAfter(lastActivityDate)) {
        lastActivityDate = p.paymentDate;
      }
    }
    for (final tx in bottleTxs) {
      if (lastActivityDate == null || tx.date.isAfter(lastActivityDate)) {
        lastActivityDate = tx.date;
      }
    }

    final depositBalance =
        await _db.customerDepositsDao.getBalanceForCustomer(customerId);

    final customerRow = await _db.customersDao.getById(customerId);
    final customerOwnedHeld = customerRow?.customerOwnedBottlesHeld ?? 0;

    final deliveryEntities = allDeliveries.map((row) {
      return Delivery(
        id: row.id,
        customerId: row.customerId,
        quantity: row.quantity,
        pricePerBottle: row.pricePerBottle,
        totalAmount: row.totalAmount,
        paymentStatus: Delivery.paymentStatusFromString(row.paymentStatus),
        amountPaid: row.amountPaid,
        depositApplied: row.depositApplied,
        remainingBalance: row.remainingBalance,
        deliveryDate: row.deliveryDate,
        deliveryTime: row.deliveryTime,
        deliveryStatus:
            Delivery.deliveryStatusFromString(row.deliveryStatus),
        collectedEmptyBottles: row.collectedEmptyBottles,
        customerOwnedBottlesFilled: row.customerOwnedBottlesFilled,
        notes: row.notes,
        receiptNumber: row.receiptNumber,
      );
    }).toList();

    final returnEntries = bottleTxs
        .where((t) => t.transactionType == 'return')
        .map((t) => (date: t.date, quantity: t.quantity, id: t.id));

    final operationalCollected =
        CustomerOperationalBottlesUtils.operationalCollected(
      deliveries: deliveryEntities,
      returnEntries: returnEntries,
    );
    final pendingDeliveryQty =
        CustomerOperationalBottlesUtils.pendingDeliveryQty(deliveryEntities);

    return CustomerStats(
      borrowedBottles: borrowed,
      returnedBottles: returned,
      damagedBottles: damaged,
      outstandingBottles: bottlesHeld,
      bottlesHeld: bottlesHeld,
      customerOwnedBottlesHeld: customerOwnedHeld,
      totalBottlesAtCustomer: bottlesHeld + customerOwnedHeld,
      unpaidBalance: unpaidBalance,
      depositBalance: depositBalance,
      totalAmountPaid: totalAmountPaid,
      totalDeliveries: completedDeliveries.length,
      lifetimeRevenue: lifetimeRevenue,
      lifetimeBottlesDelivered: lifetimeBottles,
      lastDeliveryDate: lastDeliveryDate,
      lastActivityDate: lastActivityDate,
      hasInitialBalance: hasInitialBalance,
      initialBottleBalance: initialBottleBalance,
      operationalCollected: operationalCollected,
      pendingDeliveryQty: pendingDeliveryQty,
    );
  }
}
