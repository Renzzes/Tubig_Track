import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../data/repositories/inventory_repository_impl.dart';
import '../../domain/entities/bottle_transaction.dart';
import '../../domain/entities/inventory_summary.dart';
import '../../domain/repositories/inventory_repository.dart';

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return InventoryRepositoryImpl(db);
});

final bottleTransactionsStreamProvider =
    StreamProvider<List<BottleTransaction>>((ref) {
  return ref.watch(inventoryRepositoryProvider).watchAll();
});

// Reactive inventory summary: recomputes when transactions change.
final inventorySummaryProvider = FutureProvider<InventorySummary>((ref) async {
  ref.watch(bottleTransactionsStreamProvider);
  return ref.read(inventoryRepositoryProvider).getSummary();
});
