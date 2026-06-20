import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../data/repositories/supplier_repository_impl.dart';
import '../../domain/entities/supplier.dart';
import '../../domain/repositories/supplier_repository.dart';

final supplierRepositoryProvider = Provider<SupplierRepository>((ref) {
  return SupplierRepositoryImpl(ref.watch(databaseProvider));
});

final suppliersStreamProvider = StreamProvider<List<Supplier>>((ref) {
  return ref.watch(supplierRepositoryProvider).watchAll();
});

final supplierAnalyticsProvider =
    FutureProvider.family<SupplierAnalytics, String>((ref, id) async {
  ref.watch(suppliersStreamProvider);
  return ref.watch(supplierRepositoryProvider).getAnalytics(id);
});
