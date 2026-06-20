import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/utils/expense_category_utils.dart';
import '../../domain/entities/supply_purchase.dart';
import '../../domain/repositories/supply_purchase_repository.dart';

class SupplyPurchaseRepositoryImpl implements SupplyPurchaseRepository {
  final AppDatabase _db;

  SupplyPurchaseRepositoryImpl(this._db);

  SupplyPurchase _map(SupplyPurchasesTableData row) {
    return SupplyPurchase(
      id: row.id,
      purchaseDate: row.purchaseDate,
      supplierName: row.supplierName,
      itemType: row.itemType,
      quantity: row.quantity,
      unitCost: row.unitCost,
      totalCost: row.totalCost,
      notes: row.notes,
      expenseId: row.expenseId,
      bottleTransactionId: row.bottleTransactionId,
    );
  }

  @override
  Stream<List<SupplyPurchase>> watchAll() {
    return _db.supplyPurchasesDao.watchAll().map(
          (rows) => rows.map(_map).toList(),
        );
  }

  @override
  Future<List<SupplyPurchase>> getAll() async {
    final rows = await _db.supplyPurchasesDao.getAll();
    return rows.map(_map).toList();
  }

  @override
  Future<List<SupplyPurchase>> getByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final rows = await _db.supplyPurchasesDao.getByDateRange(start, end);
    return rows.map(_map).toList();
  }

  @override
  Future<SupplyPurchase?> getById(String id) async {
    final row = await _db.supplyPurchasesDao.getById(id);
    return row == null ? null : _map(row);
  }

  @override
  Future<List<SupplierSummaryEntry>> getSupplierSummary(
    DateTime start,
    DateTime end,
  ) async {
    final purchases = await getByDateRange(start, end);
    final map = <String, ({int count, double total})>{};
    for (final p in purchases) {
      final key = p.supplierName.trim().isEmpty ? 'Unknown' : p.supplierName;
      final current = map[key];
      map[key] = (
        count: (current?.count ?? 0) + 1,
        total: (current?.total ?? 0) + p.totalCost,
      );
    }
    return map.entries
        .map(
          (e) => SupplierSummaryEntry(
            supplierName: e.key,
            purchaseCount: e.value.count,
            totalCost: e.value.total,
          ),
        )
        .toList()
      ..sort((a, b) => b.totalCost.compareTo(a.totalCost));
  }

  @override
  Future<void> createPurchase(SupplyPurchase purchase) async {
    await _db.transaction(() async {
      final expenseId = purchase.expenseId;
      final description = purchase.description;

      await _db.expensesDao.insertExpense(
        ExpensesTableCompanion.insert(
          id: expenseId,
          category: ExpenseCategoryUtils.otherSupplies,
          amount: purchase.totalCost,
          date: Value(purchase.purchaseDate),
          notes: Value(purchase.notes),
          description: Value(description),
          supplier: Value(purchase.supplierName),
          quantity: Value(purchase.quantity),
          unitCost: Value(purchase.unitCost),
          supplyPurchaseId: Value(purchase.id),
        ),
      );

      String? bottleTxId;
      if (SupplyPurchase.affectsBottleInventory(purchase.itemType)) {
        bottleTxId = purchase.bottleTransactionId ?? const Uuid().v4();
        await _db.bottleTransactionsDao.insertTransaction(
          BottleTransactionsTableCompanion.insert(
            id: bottleTxId,
            transactionType: AppConstants.transactionPurchase,
            quantity: purchase.quantity,
            date: Value(purchase.purchaseDate),
            notes: Value(
              'Supply: ${purchase.supplierName} — $description',
            ),
          ),
        );
      } else {
        final stockKey = SupplyPurchase.stockKeyForItemType(purchase.itemType);
        await _db.inventoryStockDao.addQuantity(stockKey, purchase.quantity);
      }

      await _db.supplyPurchasesDao.insertPurchase(
        SupplyPurchasesTableCompanion.insert(
          id: purchase.id,
          purchaseDate: Value(purchase.purchaseDate),
          supplierName: purchase.supplierName,
          itemType: purchase.itemType,
          quantity: purchase.quantity,
          unitCost: purchase.unitCost,
          totalCost: purchase.totalCost,
          notes: Value(purchase.notes),
          expenseId: expenseId,
          bottleTransactionId: Value(bottleTxId),
        ),
      );
    });
  }

  @override
  Future<void> deletePurchase(String id) async {
    await _db.transaction(() async {
      final row = await _db.supplyPurchasesDao.getById(id);
      if (row == null) return;

      await _db.expensesDao.deleteExpense(row.expenseId);

      if (row.bottleTransactionId != null) {
        await _db.bottleTransactionsDao.deleteTransaction(
          row.bottleTransactionId!,
        );
      } else {
        final stockKey = SupplyPurchase.stockKeyForItemType(row.itemType);
        await _db.inventoryStockDao.subtractQuantity(stockKey, row.quantity);
      }

      await _db.supplyPurchasesDao.deletePurchase(id);
    });
  }
}
