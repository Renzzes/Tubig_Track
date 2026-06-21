import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../constants/app_constants.dart';
import '../../services/inventory_state_effects.dart';
import '../../services/inventory_state_service.dart';
import '../../utils/inventory_calculator.dart';
import '../../../features/inventory/domain/entities/bottle_transaction.dart';
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

  if (!await hasOperationalInventoryHistory(db)) {
    if (filledExists == null) {
      await db.settingsDao.setValue(
        AppConstants.settingFilledBottlesAvailable,
        '0',
      );
    }
    if (emptyExists == null) {
      await db.settingsDao.setValue(
        AppConstants.settingEmptyBottlesReadyForRefill,
        '0',
      );
    }
    return;
  }

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

/// True when bottle/delivery/supplier history exists (used to avoid rebuilding
/// counters from defaults on an empty database).
Future<bool> hasOperationalInventoryHistory(AppDatabase db) async {
  if ((await db.bottleTransactionsDao.getAll()).isNotEmpty) return true;
  if ((await db.deliveriesDao.getAll()).isNotEmpty) return true;
  final purchases = await db.supplyPurchasesDao.getAll();
  return purchases.any((p) => p.itemType == 'Bottles' && p.quantity > 0);
}

/// Zeros persisted bottle stock counters after a full factory reset.
Future<void> resetInventoryStateSettings(AppDatabase db) async {
  await db.settingsDao.setValue(
    AppConstants.settingFilledBottlesAvailable,
    '0',
  );
  await db.settingsDao.setValue(
    AppConstants.settingEmptyBottlesReadyForRefill,
    '0',
  );
  await db.settingsDao.setValue(
    AppConstants.settingInitialCustomerBottleBalance,
    '0',
  );
  await db.settingsDao.setValue(
    AppConstants.settingCustomerBottleAdjustments,
    '0',
  );
  await db.settingsDao.setValue(
    AppConstants.settingTotalBottleInventory,
    '0',
  );
}

/// v1.4.5 migration: converts delivery-linked `_collect` ret transactions
/// (introduced in v1.4.4 as part of a combined collection+delivery workflow)
/// into standalone ret transactions so they are independently editable and
/// visible in the transaction history.
Future<void> migrateV14SeparateCollections(AppDatabase db) async {
  final allTransactions = await db.bottleTransactionsDao.getAll();
  final collectLinked =
      allTransactions.where((t) => t.id.endsWith('_collect')).toList();

  if (collectLinked.isEmpty) return;

  for (final old in collectLinked) {
    final newId = const Uuid().v4();
    await db.bottleTransactionsDao.insertTransaction(
      BottleTransactionsTableCompanion.insert(
        id: newId,
        customerId: Value(old.customerId),
        transactionType: old.transactionType,
        quantity: old.quantity,
        date: Value(old.date),
        reason: Value(old.reason),
        notes: Value(old.notes),
      ),
    );
    await db.bottleTransactionsDao.deleteTransaction(old.id);
  }
}

/// v1.4.4 migration: removes borrow transactions that were created for
/// in-progress deliveries (old behavior). Under the new rules only
/// completed deliveries create borrow rows.
Future<void> migrateV13RemoveInProgressBorrows(AppDatabase db) async {
  final allDeliveries = await db.deliveriesDao.getAll();
  final inProgressDeliveries = allDeliveries
      .where((d) => d.deliveryStatus == 'in_progress')
      .toList();

  if (inProgressDeliveries.isEmpty) return;

  final effects = InventoryStateEffects(InventoryStateService(db));

  for (final d in inProgressDeliveries) {
    final borrowId = '${d.id}_borrow';
    final existing = await db.bottleTransactionsDao.getById(borrowId);
    if (existing != null) {
      await effects.applyTransaction(
        TransactionType.borrow,
        existing.quantity,
        reverse: true,
      );
      await db.bottleTransactionsDao.deleteTransaction(borrowId);
    }
  }
}
