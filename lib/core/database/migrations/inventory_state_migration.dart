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

  final totals = InventoryTotals(
    initialInventory: initialInventory,
    purchasedBottles:
        await db.bottleTransactionsDao.getTotalByType('purchase'),
    donatedBottles: await db.bottleTransactionsDao.getTotalByType('donation'),
    borrowedBottles: await db.bottleTransactionsDao.getTotalByType('borrow'),
    returnedBottles: await db.bottleTransactionsDao.getTotalByType('return'),
    damagedBottles: await db.bottleTransactionsDao.getTotalByType('damaged'),
    missingBottles: await db.bottleTransactionsDao.getTotalByType('missing'),
    customerAdjustmentNet:
        await db.bottleTransactionsDao.getTotalByType('customer_adjustment'),
    refilledBottles: await db.supplyPurchasesDao.getTotalBottleQuantity(),
  );

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
