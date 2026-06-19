import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/customers_table.dart';
import 'tables/deliveries_table.dart';
import 'tables/bottle_transactions_table.dart';
import 'tables/payments_table.dart';
import 'tables/expenses_table.dart';
import 'tables/dispenser_sales_table.dart';
import 'tables/settings_table.dart';

import 'daos/customers_dao.dart';
import 'daos/deliveries_dao.dart';
import 'daos/bottle_transactions_dao.dart';
import 'daos/payments_dao.dart';
import 'daos/expenses_dao.dart';
import 'daos/dispenser_sales_dao.dart';
import 'daos/settings_dao.dart';

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
  ],
  daos: [
    CustomersDao,
    DeliveriesDao,
    BottleTransactionsDao,
    PaymentsDao,
    ExpensesDao,
    DispenserSalesDao,
    SettingsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await settingsDao.setValue('total_bottle_inventory', '100');
        await settingsDao.setValue('low_inventory_threshold', '25');
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
      },
    );
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'tubig_track_db');
  }
}
