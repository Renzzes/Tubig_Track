import 'package:drift/drift.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/bottle_transaction.dart';
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
      notes: row.notes,
    );
  }

  @override
  Future<InventorySummary> getSummary() async {
    final initialStr = await _db.settingsDao.getValue(
      AppConstants.settingTotalBottleInventory,
    );
    final initialInventory = int.tryParse(initialStr ?? '') ??
        AppConstants.defaultBottleInventory;

    final borrowed =
        await _db.bottleTransactionsDao.getTotalByType('borrow');
    final returned =
        await _db.bottleTransactionsDao.getTotalByType('return');
    final damaged =
        await _db.bottleTransactionsDao.getTotalByType('damaged');
    final purchased =
        await _db.bottleTransactionsDao.getTotalByType('purchase');

    // totalInventory = initialInventory + purchased − damaged
    final totalBottles = (initialInventory + purchased - damaged)
        .clamp(0, 999999);

    // borrowedOutstanding = borrowed − returned (bottles with customers)
    final borrowedOutstanding = (borrowed - returned).clamp(0, 999999);

    // availableInventory = totalInventory − borrowedOutstanding
    final availableBottles =
        (totalBottles - borrowedOutstanding).clamp(0, 999999);

    final gallonsStock = await _db.inventoryStockDao.getQuantity('gallons');
    final capsStock = await _db.inventoryStockDao.getQuantity('caps');
    final waterStocks = await _db.inventoryStockDao.getQuantity('water_stocks');
    final othersStock = await _db.inventoryStockDao.getQuantity('others');

    return InventorySummary(
      initialInventory: initialInventory,
      totalBottles: totalBottles,
      borrowedOutstanding: borrowedOutstanding,
      availableBottles: availableBottles,
      borrowedBottles: borrowed,
      returnedBottles: returned,
      damagedBottles: damaged,
      purchasedBottles: purchased,
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
        notes: Value(transaction.notes),
      ),
    );
  }

  @override
  Future<void> updateTransaction(BottleTransaction transaction) async {
    await _db.bottleTransactionsDao.updateTransaction(
      BottleTransactionsTableCompanion(
        id: Value(transaction.id),
        customerId: Value(transaction.customerId),
        transactionType:
            Value(BottleTransaction.typeToString(transaction.transactionType)),
        quantity: Value(transaction.quantity),
        date: Value(transaction.date),
        notes: Value(transaction.notes),
      ),
    );
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await _db.bottleTransactionsDao.deleteTransaction(id);
  }

  @override
  Future<void> updateTotalInventory(int newTotal) async {
    await _db.settingsDao.setValue(
      AppConstants.settingTotalBottleInventory,
      newTotal.toString(),
    );
  }
}
