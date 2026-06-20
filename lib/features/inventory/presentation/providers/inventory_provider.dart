import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../data/repositories/inventory_repository_impl.dart';
import '../../domain/entities/bottle_transaction.dart';
import '../../domain/entities/inventory_summary.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../../supply_purchases/presentation/providers/supply_purchase_provider.dart';

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return InventoryRepositoryImpl(db);
});

final bottleTransactionsStreamProvider =
    StreamProvider<List<BottleTransaction>>((ref) {
  return ref.watch(inventoryRepositoryProvider).watchAll();
});

final inventorySummaryProvider = FutureProvider<InventorySummary>((ref) async {
  ref.watch(bottleTransactionsStreamProvider);
  ref.watch(supplyPurchasesStreamProvider);
  return ref.read(inventoryRepositoryProvider).getSummary();
});
