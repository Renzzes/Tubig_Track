import '../../constants/app_constants.dart';
import '../../utils/inventory_calculator.dart';
import '../app_database.dart';

/// Seeds direct inventory state settings from historical transaction data.
Future<void> migrateInventoryStateV11(AppDatabase db) async {
  final filledExists = await db.settingsDao.getValue(
    AppConstants.settingFilledBottlesAvailable,
  );
  final emptyExists = await db.settingsDao.getValue(
    AppConstants.settingEmptyBottlesReadyForRefill,
  );
  if (filledExists != null && emptyExists != null) return;

  final initialStr = await db.settingsDao.getValue(
    AppConstants.settingTotalBottleInventory,
  );
  final initialInventory =
      int.tryParse(initialStr ?? '') ?? AppConstants.defaultBottleInventory;

  final totals = await _loadTotals(db, initialInventory);

  final empty = InventoryCalculator.emptyBottlesReadyForRefill(totals);
  final owned = InventoryCalculator.totalBottlesOwned(totals);
  final withCustomers = InventoryCalculator.bottlesWithCustomers(totals);
  final adjustmentNet =
      await db.bottleTransactionsDao.getTotalByType('adjustment');
  final filled =
      (owned - withCustomers - empty + adjustmentNet).clamp(0, 999999);

  if (filledExists == null) {
    await db.settingsDao.setValue(
      AppConstants.settingFilledBottlesAvailable,
      '$filled',
    );
  }
  if (emptyExists == null) {
    await db.settingsDao.setValue(
      AppConstants.settingEmptyBottlesReadyForRefill,
      '$empty',
    );
  }
}

/// Fixes filled stock that incorrectly mirrors bottle ownership (v1.4.3).
Future<void> migrateInventoryStateV12(AppDatabase db) async {
  final filledStr = await db.settingsDao.getValue(
    AppConstants.settingFilledBottlesAvailable,
  );
  final filled = int.tryParse(filledStr ?? '') ?? 0;

  final initialStr = await db.settingsDao.getValue(
    AppConstants.settingTotalBottleInventory,
  );
  final initialInventory =
      int.tryParse(initialStr ?? '') ?? AppConstants.defaultBottleInventory;

  final totals = await _loadTotals(db, initialInventory);
  final owned = InventoryCalculator.totalBottlesOwned(totals);
  final recomputed = await _recomputeFilledStockFromHistory(db);

  if (filled == owned || filled == initialInventory) {
    await db.settingsDao.setValue(
      AppConstants.settingFilledBottlesAvailable,
      '$recomputed',
    );
  }

  await _syncGlobalCustomerBottleSettings(db);
}

Future<int> _recomputeFilledStockFromHistory(AppDatabase db) async {
  final supplierBottles = await db.supplyPurchasesDao.getTotalBottleQuantity();
  final added = await db.bottleTransactionsDao.getTotalByType('added');
  final adjustment =
      await db.bottleTransactionsDao.getTotalByType('adjustment');
  final borrowed = await db.bottleTransactionsDao.getTotalByType('borrow');
  final damaged = await db.bottleTransactionsDao.getTotalByType('damaged');
  final missing = await db.bottleTransactionsDao.getTotalByType('missing');
  final donated = await db.bottleTransactionsDao.getTotalByType('donation');

  return (supplierBottles +
          added +
          adjustment -
          borrowed -
          damaged -
          missing -
          donated)
      .clamp(0, 999999);
}

Future<void> _syncGlobalCustomerBottleSettings(AppDatabase db) async {
  final rows = await db.bottleTransactionsDao.getAll();
  var initialTotal = 0;
  var manualTotal = 0;
  for (final row in rows) {
    if (row.transactionType != 'customer_adjustment') continue;
    if (row.reason == AppConstants.initialBalanceMigrationReason) {
      initialTotal += row.quantity;
    } else {
      manualTotal += row.quantity;
    }
  }
  await db.settingsDao.setValue(
    AppConstants.settingInitialCustomerBottleBalance,
    '$initialTotal',
  );
  await db.settingsDao.setValue(
    AppConstants.settingCustomerBottleAdjustments,
    '$manualTotal',
  );
}

Future<InventoryTotals> _loadTotals(
  AppDatabase db,
  int initialInventory,
) async {
  return InventoryTotals(
    initialInventory: initialInventory,
    purchasedBottles:
        await db.bottleTransactionsDao.getTotalByType('purchase'),
    donatedBottles: await db.bottleTransactionsDao.getTotalByType('donation'),
    borrowedBottles: await db.bottleTransactionsDao.getTotalByType('borrow'),
    returnedBottles: await db.bottleTransactionsDao.getTotalByType('return'),
    damagedBottles: await db.bottleTransactionsDao.getTotalByType('damaged'),
    missingBottles: await db.bottleTransactionsDao.getTotalByType('missing'),
    customerAdjustmentNet: await db.bottleTransactionsDao
        .getTotalByType('customer_adjustment'),
    refilledBottles: await db.supplyPurchasesDao.getTotalBottleQuantity(),
  );
}

Future<void> syncGlobalCustomerBottleSettings(AppDatabase db) =>
    _syncGlobalCustomerBottleSettings(db);
