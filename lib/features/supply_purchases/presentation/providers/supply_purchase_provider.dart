import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../data/repositories/supply_purchase_repository_impl.dart';
import '../../domain/entities/supply_purchase.dart';
import '../../domain/repositories/supply_purchase_repository.dart';

final supplyPurchaseRepositoryProvider =
    Provider<SupplyPurchaseRepository>((ref) {
  return SupplyPurchaseRepositoryImpl(ref.watch(databaseProvider));
});

final supplyPurchasesStreamProvider =
    StreamProvider<List<SupplyPurchase>>((ref) {
  return ref.watch(supplyPurchaseRepositoryProvider).watchAll();
});

final supplierSummaryProvider =
    FutureProvider.family<List<SupplierSummaryEntry>, (DateTime, DateTime)>(
  (ref, range) async {
    ref.watch(supplyPurchasesStreamProvider);
    return ref
        .watch(supplyPurchaseRepositoryProvider)
        .getSupplierSummary(range.$1, range.$2);
  },
);
