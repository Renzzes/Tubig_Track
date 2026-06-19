import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../../deliveries/presentation/providers/deliveries_provider.dart';
import '../../../deliveries/domain/repositories/delivery_repository.dart';
import '../../data/repositories/overdue_repository_impl.dart';
import '../../domain/entities/overdue_account.dart';
import '../../domain/repositories/overdue_repository.dart';

final overdueRepositoryProvider = Provider<OverdueRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return OverdueRepositoryImpl(db);
});

final overdueSummaryProvider = FutureProvider<OverdueSummary>((ref) async {
  ref.watch(deliveriesStreamProvider);
  return ref.read(overdueRepositoryProvider).getSummary();
});

class OverdueSortNotifier extends Notifier<OverdueSort> {
  @override
  OverdueSort build() => OverdueSort.highestBalance;

  void setSort(OverdueSort sort) => state = sort;
}

final overdueSortProvider =
    NotifierProvider<OverdueSortNotifier, OverdueSort>(OverdueSortNotifier.new);

final overdueAccountsProvider = FutureProvider<List<OverdueAccount>>((ref) async {
  ref.watch(deliveriesStreamProvider);
  final sort = ref.watch(overdueSortProvider);
  return ref.read(overdueRepositoryProvider).getAccounts(sort: sort);
});
