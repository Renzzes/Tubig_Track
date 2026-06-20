import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

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
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await settingsDao.setValue('total_bottle_inventory', '100');
        await settingsDao.setValue('low_inventory_threshold', '25');
        await settingsDao.setValue('cost_per_bottle', '25');
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
      },
    );
  }

  Future<void> _seedInventoryStock() async {
    await inventoryStockDao.ensureDefaults([
      'gallons',
      'caps',
      'water_stocks',
      'others',
    ]);
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'tubig_track_db');
  }
}
