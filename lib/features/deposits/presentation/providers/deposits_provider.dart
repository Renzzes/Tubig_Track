import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../data/repositories/customer_deposit_repository_impl.dart';
import '../../domain/entities/customer_deposit.dart';
import '../../domain/repositories/customer_deposit_repository.dart';

final customerDepositRepositoryProvider =
    Provider<CustomerDepositRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return CustomerDepositRepositoryImpl(db);
});

final customerDepositBalanceProvider =
    FutureProvider.family<double, String>((ref, customerId) async {
  ref.watch(customerDepositsStreamProvider(customerId));
  return ref.read(customerDepositRepositoryProvider).getBalanceForCustomer(
        customerId,
      );
});

final customerDepositsStreamProvider =
    StreamProvider.family<List<CustomerDeposit>, String>((ref, customerId) {
  return ref.watch(customerDepositRepositoryProvider).watchByCustomer(
        customerId,
      );
});

final depositSummaryProvider = FutureProvider<DepositSummary>((ref) async {
  ref.watch(allCustomerDepositsStreamProvider);
  return ref.read(customerDepositRepositoryProvider).getSummary();
});

final allCustomerDepositsStreamProvider =
    StreamProvider<List<CustomerDeposit>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.customerDepositsDao.watchAll().map(
        (rows) => rows
            .map(
              (row) => CustomerDeposit(
                id: row.id,
                customerId: row.customerId,
                amount: row.amount,
                transactionType:
                    CustomerDeposit.typeFromString(row.transactionType),
                createdAt: row.createdAt,
                notes: row.notes,
                deliveryId: row.deliveryId,
              ),
            )
            .toList(),
      );
});
