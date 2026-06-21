import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../constants/app_constants.dart';
import '../utils/receipt_number_utils.dart';
import 'tables/customers_table.dart';
import 'tables/deliveries_table.dart';
import 'tables/bottle_transactions_table.dart';
import 'tables/payments_table.dart';
import 'tables/expenses_table.dart';
import 'tables/dispenser_sales_table.dart';
import 'tables/settings_table.dart';
import 'tables/savings_contributions_table.dart';
import 'tables/supply_purchases_table.dart';
import 'tables/inventory_stock_table.dart';
import 'tables/suppliers_table.dart';
import 'tables/savings_goals_table.dart';
import 'tables/inventory_audits_table.dart';
import 'tables/inventory_adjustments_table.dart';
import 'tables/customer_deposits_table.dart';

import 'daos/customers_dao.dart';
import 'daos/deliveries_dao.dart';
import 'daos/bottle_transactions_dao.dart';
import 'daos/payments_dao.dart';
import 'daos/expenses_dao.dart';
import 'daos/dispenser_sales_dao.dart';
import 'daos/settings_dao.dart';
import 'daos/savings_dao.dart';
import 'daos/supply_purchases_dao.dart';
import 'daos/inventory_stock_dao.dart';
import 'daos/suppliers_dao.dart';
import 'daos/savings_goals_dao.dart';
import 'daos/inventory_audits_dao.dart';
import 'daos/inventory_adjustments_dao.dart';
import 'daos/customer_deposits_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    CustomersTable,
    DeliveriesTable,
    BottleTransactionsTable,
    PaymentsTable,
    ExpensesTable,
    DispenserSalesTable,
    SettingsTable,
    SavingsContributionsTable,
    SupplyPurchasesTable,
    InventoryStockTable,
    SuppliersTable,
    SavingsGoalsTable,
    InventoryAuditsTable,
    InventoryAdjustmentsTable,
    CustomerDepositsTable,
  ],
  daos: [
    CustomersDao,
    DeliveriesDao,
    BottleTransactionsDao,
    PaymentsDao,
    ExpensesDao,
    DispenserSalesDao,
    SettingsDao,
    SavingsDao,
    SupplyPurchasesDao,
    InventoryStockDao,
    SuppliersDao,
    SavingsGoalsDao,
    InventoryAuditsDao,
    InventoryAdjustmentsDao,
    CustomerDepositsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _seedDefaultSettings();
        await _seedInventoryStock();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.addColumn(deliveriesTable, deliveriesTable.deliveryTime);
          await m.addColumn(deliveriesTable, deliveriesTable.deliveryStatus);
        }
        if (from < 3) {
          final existing = await settingsDao.getValue('low_inventory_threshold');
          if (existing == null) {
            await settingsDao.setValue('low_inventory_threshold', '25');
          }
        }
        if (from < 4) {
          await m.createTable(savingsContributionsTable);
          final cost = await settingsDao.getValue('cost_per_bottle');
          if (cost == null) {
            await settingsDao.setValue('cost_per_bottle', '25');
          }
        }
        if (from < 5) {
          await m.createTable(supplyPurchasesTable);
          await m.createTable(inventoryStockTable);
          await m.addColumn(expensesTable, expensesTable.description);
          await m.addColumn(expensesTable, expensesTable.supplier);
          await m.addColumn(expensesTable, expensesTable.quantity);
          await m.addColumn(expensesTable, expensesTable.unitCost);
          await m.addColumn(expensesTable, expensesTable.supplyPurchaseId);
          await _seedInventoryStock();
        }
        if (from < 6) {
          await m.createTable(suppliersTable);
          await m.createTable(savingsGoalsTable);
          await m.addColumn(deliveriesTable, deliveriesTable.receiptNumber);
          await m.addColumn(supplyPurchasesTable, supplyPurchasesTable.supplierId);
          await _seedStockThresholds();
        }
        if (from < 7) {
          await m.addColumn(
            bottleTransactionsTable,
            bottleTransactionsTable.reason,
          );
        }
        if (from < 8) {
          await m.createTable(inventoryAuditsTable);
          await m.createTable(inventoryAdjustmentsTable);
        }
        if (from < 9) {
          await m.createTable(customerDepositsTable);
          await m.addColumn(deliveriesTable, deliveriesTable.depositApplied);
        }
      },
    );
  }

  Future<void> _seedDefaultSettings() async {
    await settingsDao.setValue('total_bottle_inventory', '100');
    await settingsDao.setValue('low_inventory_threshold', '25');
    await settingsDao.setValue('cost_per_bottle', '25');
    await settingsDao.setValue(
      AppConstants.settingMinBottles,
      '${AppConstants.defaultMinBottles}',
    );
    await settingsDao.setValue(
      AppConstants.settingMinGallons,
      '${AppConstants.defaultMinGallons}',
    );
    await settingsDao.setValue(
      AppConstants.settingMinCaps,
      '${AppConstants.defaultMinCaps}',
    );
    await settingsDao.setValue(
      AppConstants.settingMinWaterStocks,
      '${AppConstants.defaultMinWaterStocks}',
    );
  }

  Future<void> _seedStockThresholds() async {
    final legacy = await settingsDao.getValue(
      AppConstants.settingLowInventoryThreshold,
    );
    final minBottles = await settingsDao.getValue(AppConstants.settingMinBottles);
    if (minBottles == null) {
      await settingsDao.setValue(
        AppConstants.settingMinBottles,
        legacy ?? '${AppConstants.defaultMinBottles}',
      );
    }
    if (await settingsDao.getValue(AppConstants.settingMinGallons) == null) {
      await settingsDao.setValue(
        AppConstants.settingMinGallons,
        '${AppConstants.defaultMinGallons}',
      );
    }
    if (await settingsDao.getValue(AppConstants.settingMinCaps) == null) {
      await settingsDao.setValue(
        AppConstants.settingMinCaps,
        '${AppConstants.defaultMinCaps}',
      );
    }
    if (await settingsDao.getValue(AppConstants.settingMinWaterStocks) == null) {
      await settingsDao.setValue(
        AppConstants.settingMinWaterStocks,
        '${AppConstants.defaultMinWaterStocks}',
      );
    }
  }

  Future<void> _seedInventoryStock() async {
    await inventoryStockDao.ensureDefaults([
      'gallons',
      'caps',
      'water_stocks',
      'others',
    ]);
  }

  /// Generates the next receipt number for the given year (within a transaction).
  Future<String> nextReceiptNumber({DateTime? date}) async {
    final d = date ?? DateTime.now();
    final year = d.year;
    final key = ReceiptNumberUtils.settingsKeyForYear(year);
    final current = int.tryParse(await settingsDao.getValue(key) ?? '') ?? 0;
    final next = current + 1;
    await settingsDao.setValue(key, next.toString());
    return ReceiptNumberUtils.format(year, next);
  }

  /// Deletes all operational business data inside a transaction.
  /// Preserves the settings table (business configuration).
  Future<void> factoryReset() async {
    await transaction(() async {
      await delete(customersTable).go();
      await delete(deliveriesTable).go();
      await delete(paymentsTable).go();
      await delete(bottleTransactionsTable).go();
      await delete(expensesTable).go();
      await delete(dispenserSalesTable).go();
      await delete(savingsContributionsTable).go();
      await delete(supplyPurchasesTable).go();
      await delete(inventoryStockTable).go();
      await delete(suppliersTable).go();
      await delete(savingsGoalsTable).go();
      await delete(inventoryAuditsTable).go();
      await delete(inventoryAdjustmentsTable).go();
      await delete(customerDepositsTable).go();
      await _seedInventoryStock();
    });
  }

  Future<OperationalDataCounts> getOperationalDataCounts() async {
    final customers = await customersDao.getAll();
    final deliveries = await deliveriesDao.getAll();
    final payments = await paymentsDao.getAll();
    final expenses = await expensesDao.getAll();
    final purchases = await supplyPurchasesDao.getAll();
    return OperationalDataCounts(
      customers: customers.length,
      deliveries: deliveries.length,
      payments: payments.length,
      expenses: expenses.length,
      supplyPurchases: purchases.length,
    );
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'tubig_track_db');
  }
}

class OperationalDataCounts {
  final int customers;
  final int deliveries;
  final int payments;
  final int expenses;
  final int supplyPurchases;

  const OperationalDataCounts({
    required this.customers,
    required this.deliveries,
    required this.payments,
    required this.expenses,
    required this.supplyPurchases,
  });
}
