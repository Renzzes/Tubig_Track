import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/services/inventory_state_effects.dart';
import '../../../../core/services/inventory_state_service.dart';
import '../../../../core/utils/payment_status_utils.dart';
import '../../../inventory/domain/entities/bottle_transaction.dart';
import '../../domain/entities/delivery.dart';
import '../../domain/repositories/delivery_repository.dart';

class DeliveryRepositoryImpl implements DeliveryRepository {
  final AppDatabase _db;

  DeliveryRepositoryImpl(this._db);

  Delivery _map(DeliveriesTableData row) {
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
      deliveryStatus: Delivery.deliveryStatusFromString(row.deliveryStatus),
      collectedEmptyBottles: row.collectedEmptyBottles,
      notes: row.notes,
      receiptNumber: row.receiptNumber,
    );
  }

  DeliveriesTableCompanion _companion(Delivery delivery) {
    return DeliveriesTableCompanion(
      id: Value(delivery.id),
      customerId: Value(delivery.customerId),
      quantity: Value(delivery.quantity),
      pricePerBottle: Value(delivery.pricePerBottle),
      totalAmount: Value(delivery.totalAmount),
      paymentStatus: Value(Delivery.paymentStatusToString(delivery.paymentStatus)),
      amountPaid: Value(delivery.amountPaid),
      depositApplied: Value(delivery.depositApplied),
      remainingBalance: Value(delivery.remainingBalance),
      deliveryDate: Value(delivery.deliveryDate),
      deliveryTime: Value(delivery.deliveryTime),
      deliveryStatus: Value(Delivery.deliveryStatusToString(delivery.deliveryStatus)),
      collectedEmptyBottles: Value(delivery.collectedEmptyBottles),
      notes: Value(delivery.notes),
      receiptNumber: Value(delivery.receiptNumber),
    );
  }

  (DateTime, DateTime) _resolveDateRange(
    DeliveryDateRangeFilter dateRange,
    DateTime? customStart,
    DateTime? customEnd,
  ) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    switch (dateRange) {
      case DeliveryDateRangeFilter.today:
        return (todayStart, todayStart.add(const Duration(days: 1)));
      case DeliveryDateRangeFilter.thisWeek:
        final weekday = now.weekday;
        final weekStart = todayStart.subtract(Duration(days: weekday - 1));
        return (weekStart, weekStart.add(const Duration(days: 7)));
      case DeliveryDateRangeFilter.thisMonth:
        final monthStart = DateTime(now.year, now.month, 1);
        final monthEnd = DateTime(now.year, now.month + 1, 1);
        return (monthStart, monthEnd);
      case DeliveryDateRangeFilter.custom:
        final start = customStart ?? todayStart;
        final end = (customEnd ?? todayStart).add(const Duration(days: 1));
        return (start, end);
      case DeliveryDateRangeFilter.none:
        return (DateTime(2000), DateTime(2100));
    }
  }

  /// Syncs the filled-bottle delivery (borrow) transaction for a delivery.
  ///
  /// A borrow transaction is created ONLY when status == completed.
  /// This increases the customer's bottle balance and decreases filled stock.
  Future<void> _syncBorrowTransaction(Delivery delivery) async {
    final borrowId = '${delivery.id}_borrow';
    final effects = InventoryStateEffects(InventoryStateService(_db));
    final existing = await _db.bottleTransactionsDao.getById(borrowId);

    if (existing != null) {
      await effects.applyTransaction(
        TransactionType.borrow,
        existing.quantity,
        reverse: true,
      );
      await _db.bottleTransactionsDao.deleteTransaction(borrowId);
    }

    if (delivery.deliveryStatus == DeliveryStatus.completed) {
      await _db.bottleTransactionsDao.insertTransaction(
        BottleTransactionsTableCompanion.insert(
          id: borrowId,
          customerId: Value(delivery.customerId),
          transactionType: 'borrow',
          quantity: delivery.quantity,
          date: Value(delivery.deliveryDate),
          notes: Value('Delivery #${delivery.id.substring(0, 8)}'),
        ),
      );
      await effects.applyTransaction(
        TransactionType.borrow,
        delivery.quantity,
      );
    }
  }

  Future<void> _syncDepositTransactions(
    Delivery delivery, {
    required double cashReceived,
  }) async {
    await _db.customerDepositsDao.deleteByDelivery(delivery.id);

    if (delivery.depositApplied > 0.001) {
      await _db.customerDepositsDao.insertDeposit(
        CustomerDepositsTableCompanion.insert(
          id: '${delivery.id}_used',
          customerId: delivery.customerId,
          amount: delivery.depositApplied,
          transactionType: 'deposit_used',
          deliveryId: Value(delivery.id),
          notes: const Value('Applied to delivery'),
        ),
      );
    }

    final amountDue = delivery.totalAmount - delivery.depositApplied;
    final excess = cashReceived - amountDue;
    if (excess > 0.001) {
      await _db.customerDepositsDao.insertDeposit(
        CustomerDepositsTableCompanion.insert(
          id: '${delivery.id}_added',
          customerId: delivery.customerId,
          amount: excess,
          transactionType: 'deposit_added',
          deliveryId: Value(delivery.id),
          notes: const Value('Excess payment from delivery'),
        ),
      );
    }
  }

  @override
  Stream<List<Delivery>> watchAll() {
    return _db.deliveriesDao.watchAll().map(
          (rows) => rows.map(_map).toList(),
        );
  }

  @override
  Stream<List<Delivery>> watchByFilter(
    DeliveryFilter filter, {
    DeliveryDateRangeFilter dateRange = DeliveryDateRangeFilter.none,
    DateTime? customStart,
    DateTime? customEnd,
  }) {
    switch (filter) {
      case DeliveryFilter.today:
        return _db.deliveriesDao
            .watchTodayActive()
            .map((rows) => rows.map(_map).toList());
      case DeliveryFilter.completed:
        if (dateRange != DeliveryDateRangeFilter.none) {
          final (start, end) =
              _resolveDateRange(dateRange, customStart, customEnd);
          return _db.deliveriesDao
              .watchCompletedOrPaidInRange(start, end)
              .map((rows) => rows.map(_map).toList());
        }
        return _db.deliveriesDao
            .watchCompletedOrPaid()
            .map((rows) => rows.map(_map).toList());
      case DeliveryFilter.all:
        if (dateRange != DeliveryDateRangeFilter.none) {
          final (start, end) =
              _resolveDateRange(dateRange, customStart, customEnd);
          return _db.deliveriesDao
              .watchAllInRange(start, end)
              .map((rows) => rows.map(_map).toList());
        }
        return _db.deliveriesDao
            .watchAll()
            .map((rows) => rows.map(_map).toList());
    }
  }

  @override
  Future<List<Delivery>> getAll() async {
    final rows = await _db.deliveriesDao.getAll();
    return rows.map(_map).toList();
  }

  @override
  Future<List<Delivery>> getByCustomer(String customerId) async {
    final rows = await _db.deliveriesDao.getByCustomer(customerId);
    return rows.map(_map).toList();
  }

  @override
  Stream<List<Delivery>> watchByCustomer(String customerId) {
    return _db.deliveriesDao.watchByCustomer(customerId).map(
          (rows) => rows.map(_map).toList(),
        );
  }

  @override
  Future<List<Delivery>> getByDateRange(DateTime start, DateTime end) async {
    final rows = await _db.deliveriesDao.getByDateRange(start, end);
    return rows.map(_map).toList();
  }

  @override
  Future<Delivery?> getById(String id) async {
    final row = await _db.deliveriesDao.getById(id);
    return row != null ? _map(row) : null;
  }

  @override
  Future<void> createDelivery(Delivery delivery, {double? cashReceived}) async {
    await _db.transaction(() async {
      final receiptNumber = delivery.receiptNumber ??
          await _db.nextReceiptNumber(date: delivery.deliveryDate);
      await _db.deliveriesDao.insertDelivery(
        DeliveriesTableCompanion.insert(
          id: delivery.id,
          customerId: delivery.customerId,
          quantity: delivery.quantity,
          pricePerBottle: delivery.pricePerBottle,
          totalAmount: delivery.totalAmount,
          paymentStatus:
              Value(Delivery.paymentStatusToString(delivery.paymentStatus)),
          amountPaid: Value(delivery.amountPaid),
          depositApplied: Value(delivery.depositApplied),
          remainingBalance: Value(delivery.remainingBalance),
          deliveryDate: Value(delivery.deliveryDate),
          deliveryTime: Value(delivery.deliveryTime),
          deliveryStatus:
              Value(Delivery.deliveryStatusToString(delivery.deliveryStatus)),
          collectedEmptyBottles: Value(delivery.collectedEmptyBottles),
          notes: Value(delivery.notes),
          receiptNumber: Value(receiptNumber),
        ),
      );
      await _syncBorrowTransaction(delivery);
      await _syncDepositTransactions(
        delivery,
        cashReceived: cashReceived ?? delivery.amountPaid,
      );
    });
  }

  @override
  Future<void> updateDelivery(Delivery delivery, {double? cashReceived}) async {
    await _db.transaction(() async {
      await _db.deliveriesDao.updateDelivery(_companion(delivery));
      await _syncBorrowTransaction(delivery);
      await _syncDepositTransactions(
        delivery,
        cashReceived: cashReceived ?? delivery.amountPaid,
      );
    });
  }

  @override
  Future<void> deleteDelivery(String id) async {
    await _db.transaction(() async {
      final effects = InventoryStateEffects(InventoryStateService(_db));

      final collectId = '${id}_collect';
      final existingCollect =
          await _db.bottleTransactionsDao.getById(collectId);
      if (existingCollect != null) {
        await effects.applyTransaction(
          TransactionType.ret,
          existingCollect.quantity,
          reverse: true,
        );
        await _db.bottleTransactionsDao.deleteTransaction(collectId);
      }

      final borrowId = '${id}_borrow';
      final existingBorrow = await _db.bottleTransactionsDao.getById(borrowId);
      if (existingBorrow != null) {
        await effects.applyTransaction(
          TransactionType.borrow,
          existingBorrow.quantity,
          reverse: true,
        );
        await _db.bottleTransactionsDao.deleteTransaction(borrowId);
      }

      await _db.customerDepositsDao.deleteByDelivery(id);
      await _db.paymentsDao.deleteByDelivery(id);
      await _db.deliveriesDao.deleteDelivery(id);
    });
  }

  @override
  Future<void> syncAllPaymentStatuses() async {
    final all = await _db.deliveriesDao.getAll();
    for (final row in all) {
      final newStatus = PaymentStatusUtils.computeStatus(
        totalAmount: row.totalAmount,
        amountPaid: row.amountPaid,
        depositApplied: row.depositApplied,
      );
      final newBalance = PaymentStatusUtils.computeRemainingBalance(
        totalAmount: row.totalAmount,
        amountPaid: row.amountPaid,
        depositApplied: row.depositApplied,
      );
      var deliveryStatus = row.deliveryStatus;
      if (newStatus == 'paid' && deliveryStatus != 'cancelled') {
        deliveryStatus = 'completed';
      }
      if (newStatus != row.paymentStatus ||
          newBalance != row.remainingBalance ||
          deliveryStatus != row.deliveryStatus) {
        await _db.deliveriesDao.updateDelivery(
          DeliveriesTableCompanion(
            id: Value(row.id),
            customerId: Value(row.customerId),
            quantity: Value(row.quantity),
            pricePerBottle: Value(row.pricePerBottle),
            totalAmount: Value(row.totalAmount),
            paymentStatus: Value(newStatus),
            amountPaid: Value(row.amountPaid),
            depositApplied: Value(row.depositApplied),
            remainingBalance: Value(newBalance),
            deliveryDate: Value(row.deliveryDate),
            deliveryTime: Value(row.deliveryTime),
            deliveryStatus: Value(deliveryStatus),
            collectedEmptyBottles: Value(row.collectedEmptyBottles),
            notes: Value(row.notes),
            receiptNumber: Value(row.receiptNumber),
          ),
        );
      }
    }
  }
}
