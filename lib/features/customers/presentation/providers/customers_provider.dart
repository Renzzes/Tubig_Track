import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/utils/bottle_verification_utils.dart';
import '../../../deliveries/presentation/providers/deliveries_provider.dart';
import '../../../inventory/presentation/providers/inventory_provider.dart';
import '../../data/repositories/customer_repository_impl.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/customer_sort_option.dart';
import '../../domain/repositories/customer_repository.dart';
import 'customer_sort_provider.dart';

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

Future<List<Customer>> _sortCustomers(
  CustomerRepository repo,
  List<Customer> customers,
  CustomerSortOption sort,
) async {
  switch (sort) {
    case CustomerSortOption.nameAsc:
      final sorted = [...customers]
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return sorted;
    case CustomerSortOption.nameDesc:
      final sorted = [...customers]
        ..sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
      return sorted;
    case CustomerSortOption.mostBottlesHeld:
    case CustomerSortOption.highestOutstanding:
    case CustomerSortOption.mostCustomerOwned:
    case CustomerSortOption.recentlyActive:
      final stats = await Future.wait(
        customers.map((c) => repo.getCustomerStats(c.id)),
      );
      final indexed = List.generate(customers.length, (i) => (customers[i], stats[i]));
      indexed.sort((a, b) {
        final cmp = switch (sort) {
          CustomerSortOption.mostBottlesHeld =>
            b.$2.bottlesHeld.compareTo(a.$2.bottlesHeld),
          CustomerSortOption.highestOutstanding =>
            b.$2.unpaidBalance.compareTo(a.$2.unpaidBalance),
          CustomerSortOption.mostCustomerOwned => b.$2.customerOwnedBottlesHeld
              .compareTo(a.$2.customerOwnedBottlesHeld),
          CustomerSortOption.recentlyActive => _compareDates(
              b.$2.lastActivityDate,
              a.$2.lastActivityDate,
            ),
          _ => 0,
        };
        if (cmp != 0) return cmp;
        return a.$1.name.toLowerCase().compareTo(b.$1.name.toLowerCase());
      });
      return indexed.map((e) => e.$1).toList();
    case CustomerSortOption.needsReconciliationFirst:
      final sorted = [...customers]..sort((a, b) {
          final rankA = _reconciliationRank(a);
          final rankB = _reconciliationRank(b);
          if (rankA != rankB) return rankA.compareTo(rankB);
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
      return sorted;
  }
}

int _reconciliationRank(Customer customer) {
  return switch (BottleVerificationUtils.statusFor(customer)) {
    PhysicalCountStatus.needsReconciliation => 0,
    PhysicalCountStatus.notVerified => 1,
    PhysicalCountStatus.verified => 2,
  };
}

int _compareDates(DateTime? a, DateTime? b) {
  if (a == null && b == null) return 0;
  if (a == null) return -1;
  if (b == null) return 1;
  return a.compareTo(b);
}

final sortedCustomersProvider = StreamProvider<List<Customer>>((ref) async* {
  final query = ref.watch(customerSearchQueryProvider);
  final sortAsync = ref.watch(customerSortOptionProvider);
  final sort = sortAsync.value ?? CustomerSortOption.nameAsc;
  final repo = ref.watch(customerRepositoryProvider);

  ref.watch(deliveriesStreamProvider);
  ref.watch(bottleTransactionsStreamProvider);

  final stream = query.isEmpty ? repo.watchAll() : repo.watchSearch(query);
  await for (final customers in stream) {
    yield await _sortCustomers(repo, customers, sort);
  }
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
