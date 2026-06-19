import '../../domain/entities/recent_transaction.dart';

abstract class RecentTransactionsRepository {
  Future<List<RecentTransaction>> getRecent({int limit = 50});
}
