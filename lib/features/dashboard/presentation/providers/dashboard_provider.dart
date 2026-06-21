import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../../deliveries/presentation/providers/deliveries_provider.dart';
import '../../../inventory/presentation/providers/inventory_provider.dart';
import '../../../expenses/presentation/providers/expenses_provider.dart';
import '../../../dispenser_sales/presentation/providers/dispenser_sales_provider.dart';
import '../../../overdue/presentation/providers/overdue_provider.dart';
import '../../../transactions/presentation/providers/recent_transactions_provider.dart';
import '../../../deposits/presentation/providers/deposits_provider.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return DashboardRepositoryImpl(db);
});

// Reactive dashboard: recomputes whenever any relevant stream emits a new value.
final dashboardSummaryProvider = FutureProvider<DashboardSummary>((ref) async {
  // Watch live streams — when any of these change, this provider re-evaluates.
  ref.watch(deliveriesStreamProvider);
  ref.watch(bottleTransactionsStreamProvider);
  ref.watch(inventoryAuditsStreamProvider);
  ref.watch(inventoryAdjustmentsStreamProvider);
  ref.watch(expensesStreamProvider);
  ref.watch(dispenserSalesStreamProvider);
  ref.watch(overdueSummaryProvider);
  ref.watch(recentTransactionsProvider);
  ref.watch(allCustomerDepositsStreamProvider);

  return ref.read(dashboardRepositoryProvider).getSummary();
});
