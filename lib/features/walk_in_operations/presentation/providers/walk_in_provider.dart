import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../data/repositories/walk_in_repository_impl.dart';
import '../../domain/repositories/walk_in_repository.dart';

final walkInRepositoryProvider = Provider<WalkInRepository>((ref) {
  return WalkInRepositoryImpl(ref.watch(databaseProvider));
});

final walkInSalesStreamProvider = StreamProvider((ref) {
  return ref.watch(walkInRepositoryProvider).watchAll();
});
