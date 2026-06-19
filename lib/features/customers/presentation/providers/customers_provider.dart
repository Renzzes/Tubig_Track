import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../../deliveries/presentation/providers/deliveries_provider.dart';
import '../../../inventory/presentation/providers/inventory_provider.dart';
import '../../data/repositories/customer_repository_impl.dart';
import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return CustomerRepositoryImpl(db);
});

final customersStreamProvider = StreamProvider<List<Customer>>((ref) {
  return ref.watch(customerRepositoryProvider).watchAll();
});

class _SearchQuery extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query;
}

final customerSearchQueryProvider =
    NotifierProvider<_SearchQuery, String>(_SearchQuery.new);

final filteredCustomersProvider = StreamProvider<List<Customer>>((ref) {
  final query = ref.watch(customerSearchQueryProvider);
  final repo = ref.watch(customerRepositoryProvider);
  if (query.isEmpty) {
    return repo.watchAll();
  }
  return repo.watchSearch(query);
});

final customerByIdProvider =
    FutureProvider.family<Customer?, String>((ref, id) async {
  return ref.watch(customerRepositoryProvider).getById(id);
});

// Reactive stats: recomputes when deliveries or bottle transactions change
final customerStatsProvider = FutureProvider.family(
  (ref, String customerId) async {
    ref.watch(deliveriesStreamProvider);
    ref.watch(bottleTransactionsStreamProvider);
    return ref.read(customerRepositoryProvider).getCustomerStats(customerId);
  },
);
