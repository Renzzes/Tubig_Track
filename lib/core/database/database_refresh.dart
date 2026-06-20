import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database_provider.dart';
import '../../features/customers/presentation/providers/customers_provider.dart';
import '../../features/dashboard/presentation/providers/dashboard_provider.dart';
import '../../features/deliveries/presentation/providers/deliveries_provider.dart';
import '../../features/dispenser_sales/presentation/providers/dispenser_sales_provider.dart';
import '../../features/expenses/presentation/providers/expenses_provider.dart';
import '../../features/inventory/presentation/providers/inventory_provider.dart';
import '../../features/overdue/presentation/providers/overdue_provider.dart';
import '../../features/reports/presentation/providers/reports_provider.dart';
import '../../features/settings/presentation/providers/settings_provider.dart';
import '../../features/transactions/presentation/providers/recent_transactions_provider.dart';
import '../../features/savings/presentation/providers/savings_provider.dart';

/// Invalidates all data providers after a database restore.
void invalidateAllDataProviders(WidgetRef ref) {
  ref.invalidate(databaseProvider);
  ref.invalidate(customersStreamProvider);
  ref.invalidate(filteredCustomersProvider);
  ref.invalidate(deliveriesStreamProvider);
  ref.invalidate(filteredDeliveriesProvider);
  ref.invalidate(bottleTransactionsStreamProvider);
  ref.invalidate(inventorySummaryProvider);
  ref.invalidate(expensesStreamProvider);
  ref.invalidate(dispenserSalesStreamProvider);
  ref.invalidate(dashboardSummaryProvider);
  ref.invalidate(appSettingsProvider);
  ref.invalidate(reportSummaryProvider);
  ref.invalidate(overdueSummaryProvider);
  ref.invalidate(overdueAccountsProvider);
  ref.invalidate(recentTransactionsProvider);
  ref.invalidate(allTransactionsProvider);
  ref.invalidate(savingsSummaryProvider);
  ref.invalidate(savingsLedgerProvider);
}
