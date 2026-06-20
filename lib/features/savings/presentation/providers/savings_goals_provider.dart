import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/utils/low_stock_utils.dart';
import '../../../inventory/presentation/providers/inventory_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../data/repositories/savings_goals_repository_impl.dart';
import '../../domain/entities/savings_goal.dart';
import '../../domain/repositories/savings_goals_repository.dart';
import 'savings_provider.dart';

final savingsGoalsRepositoryProvider = Provider<SavingsGoalsRepository>((ref) {
  return SavingsGoalsRepositoryImpl(
    ref.watch(databaseProvider),
    ref.watch(savingsRepositoryProvider),
  );
});

final savingsGoalsStreamProvider = StreamProvider<List<SavingsGoal>>((ref) {
  return ref.watch(savingsGoalsRepositoryProvider).watchAll();
});

final activeSavingsGoalProvider = FutureProvider<SavingsGoal?>((ref) async {
  ref.watch(savingsGoalsStreamProvider);
  ref.watch(savingsSummaryProvider);
  return ref.watch(savingsGoalsRepositoryProvider).getActiveGoal();
});

final savingsInsightsProvider = FutureProvider<SavingsInsights>((ref) async {
  ref.watch(savingsSummaryProvider);
  ref.watch(savingsLedgerProvider);
  return ref.watch(savingsGoalsRepositoryProvider).getInsights();
});

final lowStockItemsProvider = FutureProvider<List<LowStockItem>>((ref) async {
  ref.watch(inventorySummaryProvider);
  ref.watch(appSettingsProvider);
  final settings = await ref.watch(appSettingsProvider.future);
  final inventory = await ref.watch(inventorySummaryProvider.future);
  return LowStockUtils.check(inventory, settings);
});
