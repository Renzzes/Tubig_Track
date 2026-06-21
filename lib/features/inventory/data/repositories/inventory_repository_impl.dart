import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/services/inventory_state_effects.dart';
import '../../../../core/services/inventory_state_service.dart';
import '../../../../core/database/migrations/inventory_state_migration.dart';
import '../../../../core/utils/inventory_calculator.dart';
import '../../domain/entities/bottle_transaction.dart';
import '../../domain/entities/inventory_adjustment.dart';
import '../../domain/entities/inventory_audit.dart';
import '../../domain/entities/inventory_audit_summary.dart';
import '../../domain/entities/inventory_summary.dart';
import '../../domain/entities/customer_bottle_balance.dart';
import '../../domain/repositories/inventory_repository.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final AppDatabase _db;
  late final InventoryStateService _state = InventoryStateService(_db);
  late final InventoryStateEffects _effects = InventoryStateEffects(_state);

  InventoryRepositoryImpl(this._db);

  BottleTransaction _map(BottleTransactionsTableData row) {
    return BottleTransaction(
      id: row.id,
      customerId: row.customerId,
      transactionType: BottleTransaction.typeFromString(row.transactionType),
      quantity: row.quantity,
      date: row.date,
      reason: row.reason,
      notes: row.notes,
    );
  }

  Future<InventoryTotals> _loadTotals() async {
    final initialStr = await _db.settingsDao.getValue(
      AppConstants.settingTotalBottleInventory,
    );
    final initialInventory = int.tryParse(initialStr ?? '') ??
        AppConstants.defaultBottleInventory;

    return InventoryTotals(
      initialInventory: initialInventory,
      borrowedBottles: await _db.bottleTransactionsDao.getTotalByType('borrow'),
      returnedBottles: await _db.bottleTransactionsDao.getTotalByType('return'),
      damagedBottles: await _db.bottleTransactionsDao.getTotalByType('damaged'),
      purchasedBottles:
          await _db.bottleTransactionsDao.getTotalByType('purchase'),
      missingBottles: await _db.bottleTransactionsDao.getTotalByType('missing'),
      donatedBottles:
          await _db.bottleTransactionsDao.getTotalByType('donation'),
      customerAdjustmentNet: await _db.bottleTransactionsDao
          .getTotalByType('customer_adjustment'),
      refilledBottles: await _db.supplyPurchasesDao.getTotalBottleQuantity(),
    );
  }

  @override
  Future<List<CustomerBottleBalance>> getCustomerBottleBalances() async {
    final balanceMap =
        await _db.bottleTransactionsDao.getCustomerBottleBalances();
    if (balanceMap.isEmpty) return [];

    final customers = await _db.customersDao.getAll();
    final nameMap = {for (final c in customers) c.id: c.name};
    final receivables = await _db.deliveriesDao.getReceivablesByCustomer();

    final balances = <CustomerBottleBalance>[];
    for (final entry in balanceMap.entries) {
      final deliveries = await _db.deliveriesDao.getByCustomer(entry.key);
      final lastDelivery =
          deliveries.isNotEmpty ? deliveries.first.deliveryDate : null;
      balances.add(
        CustomerBottleBalance(
          customerId: entry.key,
          customerName: nameMap[entry.key] ?? 'Unknown',
          bottlesHeld: entry.value,
          lastDeliveryDate: lastDelivery,
          unpaidBalance: receivables[entry.key] ?? 0,
        ),
      );
    }
    balances.sort((a, b) => b.bottlesHeld.compareTo(a.bottlesHeld));
    return balances;
  }

  @override
  Future<bool> hasInitialCustomerBottleBalance(String customerId) async {
    final row = await _db.bottleTransactionsDao.getById(
      AppConstants.initialBalanceTransactionId(customerId),
    );
    return row != null;
  }

  @override
  Future<void> setInitialCustomerBottleBalance({
    required String customerId,
    required int quantity,
    DateTime? date,
  }) async {
    if (quantity < 0) {
      throw ArgumentError('Initial balance cannot be negative.');
    }
    final txId = AppConstants.initialBalanceTransactionId(customerId);
    final when = date ?? DateTime.now();

    await _db.transaction(() async {
      final existing = await _db.bottleTransactionsDao.getById(txId);
      if (existing != null) {
        await _db.bottleTransactionsDao.updateTransaction(
          BottleTransactionsTableCompanion(
            id: Value(txId),
            customerId: Value(customerId),
            transactionType: const Value('customer_adjustment'),
            quantity: Value(quantity),
            date: Value(when),
            reason: const Value(AppConstants.initialBalanceMigrationReason),
          ),
        );
      } else {
        await _insertTransactionRow(
          BottleTransaction(
            id: txId,
            customerId: customerId,
            transactionType: TransactionType.customerAdjustment,
            quantity: quantity,
            date: when,
            reason: AppConstants.initialBalanceMigrationReason,
            notes: 'Customer Bottle Adjustment',
          ),
        );
      }
      await syncGlobalCustomerBottleSettings(_db);
    });
  }

  @override
  Future<void> adjustCustomerBottleBalance({
    required String customerId,
    required int quantityDelta,
    String? reason,
    String? notes,
    DateTime? date,
  }) async {
    if (quantityDelta == 0) return;

    final stats = await _db.customersDao.getById(customerId);
    if (stats == null) throw StateError('Customer not found.');

    final borrowed = await _db.bottleTransactionsDao.getTotalByTypeForCustomer(
      'borrow',
      customerId,
    );
    final returned = await _db.bottleTransactionsDao.getTotalByTypeForCustomer(
      'return',
      customerId,
    );
    final adjustments =
        await _db.bottleTransactionsDao.getTotalByTypeForCustomer(
      'customer_adjustment',
      customerId,
    );
    final held = InventoryCalculator.customerBottlesHeld(
      delivered: borrowed,
      collected: returned,
      manualAdjustments: adjustments + quantityDelta,
    );
    if (held < 0) {
      throw StateError('Adjustment would result in negative bottles held.');
    }

    final when = date ?? DateTime.now();
    await _db.transaction(() async {
      await _insertTransactionRow(
        BottleTransaction(
          id: const Uuid().v4(),
          customerId: customerId,
          transactionType: TransactionType.customerAdjustment,
          quantity: quantityDelta,
          date: when,
          reason: reason?.trim().isEmpty ?? true
              ? 'Customer Bottle Adjustment'
              : reason!.trim(),
          notes: notes,
        ),
      );
      await syncGlobalCustomerBottleSettings(_db);
    });
  }

  @override
  Future<InventoryConsistencyReport> validateConsistency() async {
    final summary = await getSummary();
    final balances = await getCustomerBottleBalances();
    final sumHeld = balances.fold<int>(0, (s, b) => s + b.bottlesHeld);
    return InventoryConsistencyReport(
      globalWithCustomers: summary.bottlesWithCustomers,
      sumCustomerHeld: sumHeld,
      filledBottlesAvailable: summary.filledBottlesAvailable,
      emptyBottlesReadyForRefill: summary.emptyBottlesReadyForRefill,
      totalBottlesOwned: summary.totalBottlesOwned,
      damagedBottles: summary.damagedBottles,
      missingBottles: summary.missingBottles,
    );
  }

  @override
  Future<InventorySummary> getSummary() async {
    final totals = await _loadTotals();
    final filledBottlesAvailable = await _state.getFilledBottlesAvailable();
    final emptyBottlesReadyForRefill =
        await _state.getEmptyBottlesReadyForRefill();

    final gallonsStock = await _db.inventoryStockDao.getQuantity('gallons');
    final capsStock = await _db.inventoryStockDao.getQuantity('caps');
    final waterStocks =
        await _db.inventoryStockDao.getQuantity('water_stocks');
    final othersStock = await _db.inventoryStockDao.getQuantity('others');

    return InventorySummary(
      initialInventory: totals.initialInventory,
      totalBottlesOwned: InventoryCalculator.totalBottlesOwned(totals),
      bottlesWithCustomers: InventoryCalculator.bottlesWithCustomers(totals),
      filledBottlesAvailable: filledBottlesAvailable,
      emptyBottlesReadyForRefill: emptyBottlesReadyForRefill,
      borrowedBottles: totals.borrowedBottles,
      returnedBottles: totals.returnedBottles,
      damagedBottles: totals.damagedBottles,
      missingBottles: totals.missingBottles,
      purchasedBottles: totals.purchasedBottles,
      donatedBottles: totals.donatedBottles,
      customerAdjustmentNet: totals.customerAdjustmentNet,
      refilledBottles: totals.refilledBottles,
      gallonsStock: gallonsStock,
      capsStock: capsStock,
      waterStocks: waterStocks,
      othersStock: othersStock,
    );
  }

  @override
  Stream<List<BottleTransaction>> watchAll() {
    return _db.bottleTransactionsDao.watchAll().map(
          (rows) => rows.map(_map).toList(),
        );
  }

  @override
  Future<List<BottleTransaction>> getAll() async {
    final rows = await _db.bottleTransactionsDao.getAll();
    return rows.map(_map).toList();
  }

  Future<void> _insertTransactionRow(BottleTransaction transaction) async {
    await _db.bottleTransactionsDao.insertTransaction(
      BottleTransactionsTableCompanion.insert(
        id: transaction.id,
        customerId: Value(transaction.customerId),
        transactionType:
            BottleTransaction.typeToString(transaction.transactionType),
        quantity: transaction.quantity,
        date: Value(transaction.date),
        reason: Value(transaction.reason),
        notes: Value(transaction.notes),
      ),
    );
  }

  @override
  Future<void> recordTransaction(BottleTransaction transaction) async {
    if (transaction.isDeliveryLinked) {
      throw StateError('Delivery-linked transactions are managed by deliveries.');
    }
    await _db.transaction(() async {
      await _effects.applyTransaction(
        transaction.transactionType,
        transaction.quantity,
      );
      await _insertTransactionRow(transaction);
      if (transaction.transactionType == TransactionType.customerAdjustment) {
        await syncGlobalCustomerBottleSettings(_db);
      }
    });
  }

  @override
  Future<void> updateTransaction(BottleTransaction transaction) async {
    if (transaction.isDeliveryLinked) {
      throw StateError('Delivery-linked transactions cannot be edited here.');
    }
    final existing = await _db.bottleTransactionsDao.getById(transaction.id);
    if (existing == null) return;

    await _db.transaction(() async {
      final oldType =
          BottleTransaction.typeFromString(existing.transactionType);
      await _effects.applyTransaction(oldType, existing.quantity, reverse: true);
      await _effects.applyTransaction(
        transaction.transactionType,
        transaction.quantity,
      );
      await _db.bottleTransactionsDao.updateTransaction(
        BottleTransactionsTableCompanion(
          id: Value(transaction.id),
          customerId: Value(transaction.customerId),
          transactionType: Value(
            BottleTransaction.typeToString(transaction.transactionType),
          ),
          quantity: Value(transaction.quantity),
          date: Value(transaction.date),
          reason: Value(transaction.reason),
          notes: Value(transaction.notes),
        ),
      );
      if (transaction.transactionType == TransactionType.customerAdjustment ||
          oldType == TransactionType.customerAdjustment) {
        await syncGlobalCustomerBottleSettings(_db);
      }
    });
  }

  @override
  Future<void> deleteTransaction(String id) async {
    if (id.endsWith('_borrow')) {
      throw StateError('Delivery-linked transactions cannot be deleted here.');
    }
    final existing = await _db.bottleTransactionsDao.getById(id);
    if (existing == null) return;

    await _db.transaction(() async {
      final type =
          BottleTransaction.typeFromString(existing.transactionType);
      await _effects.applyTransaction(type, existing.quantity, reverse: true);
      await _db.bottleTransactionsDao.deleteTransaction(id);
      if (type == TransactionType.customerAdjustment) {
        await syncGlobalCustomerBottleSettings(_db);
      }
    });
  }

  @override
  Future<void> updateTotalInventory(int newTotal) async {
    await _db.settingsDao.setValue(
      AppConstants.settingTotalBottleInventory,
      newTotal.toString(),
    );
  }

  InventoryAudit _mapAudit(InventoryAuditsTableData row) {
    return InventoryAudit(
      id: row.id,
      auditDate: row.auditDate,
      systemCount: row.systemCount,
      physicalCount: row.physicalCount,
      difference: row.difference,
      actionTaken: InventoryAudit.actionFromString(row.actionTaken),
      notes: row.notes,
    );
  }

  InventoryAdjustment _mapAdjustment(InventoryAdjustmentsTableData row) {
    return InventoryAdjustment(
      id: row.id,
      adjustmentDate: row.adjustmentDate,
      quantity: row.quantity,
      reason: row.reason,
      notes: row.notes,
    );
  }

  @override
  Stream<List<InventoryAudit>> watchAudits() {
    return _db.inventoryAuditsDao.watchAll().map(
          (rows) => rows.map(_mapAudit).toList(),
        );
  }

  @override
  Stream<List<InventoryAdjustment>> watchAdjustments() {
    return _db.inventoryAdjustmentsDao.watchAll().map(
          (rows) => rows.map(_mapAdjustment).toList(),
        );
  }

  @override
  Future<InventoryAuditSummary> getAuditSummary() async {
    final count = await _db.inventoryAuditsDao.getCount();
    final latest = await _db.inventoryAuditsDao.getLatest();
    final missingFromAudits = await _sumAuditMissing();
    final adjustmentQuantity =
        await _db.inventoryAdjustmentsDao.getNetQuantity();

    return InventoryAuditSummary(
      totalAudits: count,
      lastAuditDate: latest?.auditDate,
      missingBottlesFound: missingFromAudits,
      adjustmentQuantity: adjustmentQuantity,
    );
  }

  Future<int> _sumAuditMissing() async {
    final audits = await _db.inventoryAuditsDao.getAll();
    var total = 0;
    for (final a in audits) {
      if (a.actionTaken == 'marked_missing' && a.difference < 0) {
        total += a.difference.abs();
      }
    }
    return total;
  }

  Future<void> _applyAuditSideEffects({
    required TransactionType type,
    required int quantity,
  }) async {
    await _effects.applyTransaction(type, quantity);
  }

  @override
  Future<void> performAudit({
    required int physicalCount,
    required InventoryAuditAction action,
    String? adjustmentReason,
    String? notes,
  }) async {
    final summary = await getSummary();
    final systemCount = summary.totalBottlesOwned;
    final difference = physicalCount - systemCount;
    final now = DateTime.now();
    final auditId = const Uuid().v4();

    await _db.transaction(() async {
      if (difference == 0 || action == InventoryAuditAction.balanced) {
        await _db.inventoryAuditsDao.insertAudit(
          InventoryAuditsTableCompanion.insert(
            id: auditId,
            auditDate: Value(now),
            systemCount: systemCount,
            physicalCount: physicalCount,
            difference: difference,
            actionTaken: InventoryAudit.actionToString(
              InventoryAuditAction.balanced,
            ),
            notes: Value(notes),
          ),
        );
        await _insertTransactionRow(
          BottleTransaction(
            id: const Uuid().v4(),
            transactionType: TransactionType.audit,
            quantity: 0,
            date: now,
            reason: 'Inventory Audit',
            notes: 'Audit balanced',
          ),
        );
        return;
      }

      if (difference < 0 && action == InventoryAuditAction.markedMissing) {
        final qty = difference.abs();
        await _applyAuditSideEffects(
          type: TransactionType.missing,
          quantity: qty,
        );
        await _insertTransactionRow(
          BottleTransaction(
            id: const Uuid().v4(),
            transactionType: TransactionType.missing,
            quantity: qty,
            date: now,
            reason: 'Inventory Audit',
            notes: 'Auto-generated from audit',
          ),
        );
      } else if (action == InventoryAuditAction.adjustment) {
        final reason =
            (adjustmentReason == null || adjustmentReason.trim().isEmpty)
                ? 'Inventory Reconciliation'
                : adjustmentReason.trim();
        await _db.inventoryAdjustmentsDao.insertAdjustment(
          InventoryAdjustmentsTableCompanion.insert(
            id: const Uuid().v4(),
            adjustmentDate: Value(now),
            quantity: difference,
            reason: reason,
            notes: Value(notes),
          ),
        );
        await _applyAuditSideEffects(
          type: TransactionType.adjustment,
          quantity: difference,
        );
        await _insertTransactionRow(
          BottleTransaction(
            id: const Uuid().v4(),
            transactionType: TransactionType.adjustment,
            quantity: difference,
            date: now,
            reason: reason,
            notes: notes,
          ),
        );
      } else if (action == InventoryAuditAction.cancelled) {
        await _db.inventoryAuditsDao.insertAudit(
          InventoryAuditsTableCompanion.insert(
            id: auditId,
            auditDate: Value(now),
            systemCount: systemCount,
            physicalCount: physicalCount,
            difference: difference,
            actionTaken: InventoryAudit.actionToString(
              InventoryAuditAction.cancelled,
            ),
            notes: Value(notes),
          ),
        );
        return;
      } else {
        throw StateError('Invalid audit action for difference.');
      }

      await _db.inventoryAuditsDao.insertAudit(
        InventoryAuditsTableCompanion.insert(
          id: auditId,
          auditDate: Value(now),
          systemCount: systemCount,
          physicalCount: physicalCount,
          difference: difference,
          actionTaken: InventoryAudit.actionToString(action),
          notes: Value(notes),
        ),
      );

      await _insertTransactionRow(
        BottleTransaction(
          id: const Uuid().v4(),
          transactionType: TransactionType.audit,
          quantity: difference,
          date: now,
          reason: 'Inventory Audit',
          notes:
              'System $systemCount, Physical $physicalCount, Difference $difference',
        ),
      );
    });
  }
}
