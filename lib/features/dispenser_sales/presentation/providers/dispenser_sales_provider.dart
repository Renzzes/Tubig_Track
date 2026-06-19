import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../data/repositories/dispenser_sale_repository_impl.dart';
import '../../domain/entities/dispenser_sale.dart';
import '../../domain/repositories/dispenser_sale_repository.dart';

final dispenserSaleRepositoryProvider =
    Provider<DispenserSaleRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return DispenserSaleRepositoryImpl(db);
});

final dispenserSalesStreamProvider =
    StreamProvider<List<DispenserSale>>((ref) {
  return ref.watch(dispenserSaleRepositoryProvider).watchAll();
});
