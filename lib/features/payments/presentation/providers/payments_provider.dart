import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../data/repositories/payment_repository_impl.dart';
import '../../domain/entities/payment.dart';
import '../../domain/repositories/payment_repository.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return PaymentRepositoryImpl(db);
});

final customerPaymentsProvider =
    FutureProvider.family<List<Payment>, String>((ref, customerId) {
  return ref.watch(paymentRepositoryProvider).getByCustomer(customerId);
});

final customerPaymentsStreamProvider =
    StreamProvider.family<List<Payment>, String>((ref, customerId) {
  return ref.watch(paymentRepositoryProvider).watchByCustomer(customerId);
});

final paymentsStreamProvider = StreamProvider<List<Payment>>((ref) {
  return ref.watch(paymentRepositoryProvider).watchAll();
});
