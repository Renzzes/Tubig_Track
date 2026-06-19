import '../entities/overdue_account.dart';
import '../../../deliveries/domain/repositories/delivery_repository.dart';

abstract class OverdueRepository {
  Future<OverdueSummary> getSummary();
  Future<List<OverdueAccount>> getAccounts({OverdueSort sort});
}
