import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../data/repositories/delivery_repository_impl.dart';
import '../../domain/entities/delivery.dart';
import '../../domain/repositories/delivery_repository.dart';

final deliveryRepositoryProvider = Provider<DeliveryRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return DeliveryRepositoryImpl(db);
});

final deliveriesStreamProvider = StreamProvider<List<Delivery>>((ref) {
  return ref.watch(deliveryRepositoryProvider).watchAll();
});

class DeliveryFilterNotifier extends Notifier<DeliveryFilter> {
  @override
  DeliveryFilter build() => DeliveryFilter.today;

  void setFilter(DeliveryFilter filter) => state = filter;
}

final deliveryFilterProvider =
    NotifierProvider<DeliveryFilterNotifier, DeliveryFilter>(
  DeliveryFilterNotifier.new,
);

class DeliveryDateRangeNotifier extends Notifier<DeliveryDateRangeFilter> {
  @override
  DeliveryDateRangeFilter build() => DeliveryDateRangeFilter.none;

  void setRange(DeliveryDateRangeFilter range) => state = range;
}

final deliveryDateRangeProvider =
    NotifierProvider<DeliveryDateRangeNotifier, DeliveryDateRangeFilter>(
  DeliveryDateRangeNotifier.new,
);

class CustomDateRangeNotifier extends Notifier<(DateTime?, DateTime?)> {
  @override
  (DateTime?, DateTime?) build() => (null, null);

  void setRange(DateTime start, DateTime end) => state = (start, end);
}

final customDateRangeProvider =
    NotifierProvider<CustomDateRangeNotifier, (DateTime?, DateTime?)>(
  CustomDateRangeNotifier.new,
);

final filteredDeliveriesProvider = StreamProvider<List<Delivery>>((ref) {
  final filter = ref.watch(deliveryFilterProvider);
  final dateRange = ref.watch(deliveryDateRangeProvider);
  final custom = ref.watch(customDateRangeProvider);
  final repo = ref.watch(deliveryRepositoryProvider);

  if (filter == DeliveryFilter.all || filter == DeliveryFilter.completed) {
    return repo.watchByFilter(
      filter,
      dateRange: dateRange,
      customStart: custom.$1,
      customEnd: custom.$2,
    );
  }
  return repo.watchByFilter(filter);
});

final customerDeliveriesProvider =
    FutureProvider.family<List<Delivery>, String>((ref, customerId) {
  return ref.watch(deliveryRepositoryProvider).getByCustomer(customerId);
});

final customerDeliveriesStreamProvider =
    StreamProvider.family<List<Delivery>, String>((ref, customerId) {
  return ref.watch(deliveryRepositoryProvider).watchByCustomer(customerId);
});
