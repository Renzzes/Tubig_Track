import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../../deliveries/presentation/providers/deliveries_provider.dart';
import '../../../expenses/presentation/providers/expenses_provider.dart';
import '../../../dispenser_sales/presentation/providers/dispenser_sales_provider.dart';
import '../../../inventory/presentation/providers/inventory_provider.dart';
import '../../data/repositories/recent_transactions_repository_impl.dart';
import '../../domain/entities/recent_transaction.dart';
import '../../domain/repositories/recent_transactions_repository.dart';

final recentTransactionsRepositoryProvider =
    Provider<RecentTransactionsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return RecentTransactionsRepositoryImpl(db);
});

final recentTransactionsProvider =
    FutureProvider<List<RecentTransaction>>((ref) async {
  ref.watch(deliveriesStreamProvider);
  ref.watch(bottleTransactionsStreamProvider);
  ref.watch(expensesStreamProvider);
  ref.watch(dispenserSalesStreamProvider);
  return ref.read(recentTransactionsRepositoryProvider).getRecent(limit: 50);
});
