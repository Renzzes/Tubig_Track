import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/utils/inventory_calculator.dart';
import '../../domain/entities/bottle_transaction.dart';
import '../../domain/entities/inventory_adjustment.dart';
import '../../domain/entities/inventory_audit.dart';
import '../../domain/entities/inventory_audit_summary.dart';
import '../../domain/entities/inventory_summary.dart';
import '../../domain/repositories/inventory_repository.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final AppDatabase _db;

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
      adjustmentNet:
          await _db.bottleTransactionsDao.getTotalByType('adjustment'),
    );
  }

  @override
  Future<InventorySummary> getSummary() async {
    final totals = await _loadTotals();

    final totalBottlesOwned = InventoryCalculator.totalBottlesOwned(totals);
    final bottlesWithCustomers =
        InventoryCalculator.bottlesWithCustomers(totals);
    final availableBottles = InventoryCalculator.availableBottles(totals);

    final gallonsStock = await _db.inventoryStockDao.getQuantity('gallons');
    final capsStock = await _db.inventoryStockDao.getQuantity('caps');
    final waterStocks =
        await _db.inventoryStockDao.getQuantity('water_stocks');
    final othersStock = await _db.inventoryStockDao.getQuantity('others');

    return InventorySummary(
      initialInventory: totals.initialInventory,
      totalBottlesOwned: totalBottlesOwned,
      bottlesWithCustomers: bottlesWithCustomers,
      availableBottles: availableBottles,
      borrowedBottles: totals.borrowedBottles,
      returnedBottles: totals.returnedBottles,
      damagedBottles: totals.damagedBottles,
      missingBottles: totals.missingBottles,
      purchasedBottles: totals.purchasedBottles,
      donatedBottles: totals.donatedBottles,
      adjustmentNet: totals.adjustmentNet,
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

  @override
  Future<void> recordTransaction(BottleTransaction transaction) async {
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
  Future<void> updateTransaction(BottleTransaction transaction) async {
    if (transaction.isDeliveryLinked) {
      throw StateError('Delivery-linked transactions cannot be edited here.');
    }
    await _db.bottleTransactionsDao.updateTransaction(
      BottleTransactionsTableCompanion(
        id: Value(transaction.id),
        customerId: Value(transaction.customerId),
        transactionType:
            Value(BottleTransaction.typeToString(transaction.transactionType)),
        quantity: Value(transaction.quantity),
        date: Value(transaction.date),
        reason: Value(transaction.reason),
        notes: Value(transaction.notes),
      ),
    );
  }

  @override
  Future<void> deleteTransaction(String id) async {
    if (id.endsWith('_borrow')) {
      throw StateError('Delivery-linked transactions cannot be deleted here.');
    }
    await _db.bottleTransactionsDao.deleteTransaction(id);
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
    final adjustmentQuantity = await _db.inventoryAdjustmentsDao.getNetQuantity();

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

  @override
  Future<void> performAudit({
    required int physicalCount,
    required InventoryAuditAction action,
    String? adjustmentReason,
    String? notes,
  }) async {
    final summary = await getSummary();
    final systemCount = summary.availableBottles;
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
            actionTaken: InventoryAudit.actionToString(InventoryAuditAction.balanced),
            notes: Value(notes),
          ),
        );
        await _db.bottleTransactionsDao.insertTransaction(
          BottleTransactionsTableCompanion.insert(
            id: const Uuid().v4(),
            transactionType: BottleTransaction.typeToString(TransactionType.audit),
            quantity: 0,
            date: Value(now),
            reason: const Value('Inventory Audit'),
            notes: Value('Audit balanced'),
          ),
        );
        return;
      }

      if (difference < 0 && action == InventoryAuditAction.markedMissing) {
        final qty = difference.abs();
        await _db.bottleTransactionsDao.insertTransaction(
          BottleTransactionsTableCompanion.insert(
            id: const Uuid().v4(),
            transactionType: BottleTransaction.typeToString(TransactionType.missing),
            quantity: qty,
            date: Value(now),
            reason: const Value('Inventory Audit'),
            notes: const Value('Auto-generated from audit'),
          ),
        );
      } else if (action == InventoryAuditAction.adjustment) {
        final reason = (adjustmentReason == null || adjustmentReason.trim().isEmpty)
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
        await _db.bottleTransactionsDao.insertTransaction(
          BottleTransactionsTableCompanion.insert(
            id: const Uuid().v4(),
            transactionType:
                BottleTransaction.typeToString(TransactionType.adjustment),
            quantity: difference,
            date: Value(now),
            reason: Value(reason),
            notes: Value(notes),
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
            actionTaken: InventoryAudit.actionToString(InventoryAuditAction.cancelled),
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

      await _db.bottleTransactionsDao.insertTransaction(
        BottleTransactionsTableCompanion.insert(
          id: const Uuid().v4(),
          transactionType: BottleTransaction.typeToString(TransactionType.audit),
          quantity: difference,
          date: Value(now),
          reason: const Value('Inventory Audit'),
          notes: Value(
            'System $systemCount, Physical $physicalCount, Difference $difference',
          ),
        ),
      );
    });
  }
}
