import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../../deliveries/presentation/providers/deliveries_provider.dart';
import '../../../dispenser_sales/presentation/providers/dispenser_sales_provider.dart';
import '../../../expenses/presentation/providers/expenses_provider.dart';
import '../../../inventory/presentation/providers/inventory_provider.dart';
import '../../data/repositories/savings_repository_impl.dart';
import '../../domain/entities/savings_entities.dart';
import '../../domain/repositories/savings_repository.dart';

final savingsRepositoryProvider = Provider<SavingsRepository>((ref) {
  return SavingsRepositoryImpl(ref.watch(databaseProvider));
});

final savingsSummaryProvider = FutureProvider<SavingsSummary>((ref) async {
  ref.watch(deliveriesStreamProvider);
  ref.watch(expensesStreamProvider);
  ref.watch(dispenserSalesStreamProvider);
  ref.watch(bottleTransactionsStreamProvider);
  return ref.watch(savingsRepositoryProvider).getSummary();
});

final savingsLedgerProvider =
    FutureProvider<List<SavingsLedgerEntry>>((ref) async {
  ref.watch(deliveriesStreamProvider);
  ref.watch(expensesStreamProvider);
  ref.watch(dispenserSalesStreamProvider);
  ref.watch(bottleTransactionsStreamProvider);
  return ref.watch(savingsRepositoryProvider).getLedgerHistory();
});
