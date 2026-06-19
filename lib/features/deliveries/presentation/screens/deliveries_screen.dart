import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../../customers/presentation/providers/customers_provider.dart';
import '../../domain/repositories/delivery_repository.dart';
import '../providers/deliveries_provider.dart';
import '../widgets/delivery_list_tile.dart';

class DeliveriesScreen extends ConsumerWidget {
  const DeliveriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deliveriesAsync = ref.watch(filteredDeliveriesProvider);
    final customersAsync = ref.watch(customersStreamProvider);
    final activeFilter = ref.watch(deliveryFilterProvider);
    final dateRange = ref.watch(deliveryDateRangeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deliveries'),
        actions: [
          if (activeFilter == DeliveryFilter.all ||
              activeFilter == DeliveryFilter.completed)
            IconButton(
              icon: const Icon(Icons.filter_list),
              tooltip: 'Date filter',
              onPressed: () => _showDateFilter(context, ref, activeFilter),
            ),
        ],
      ),
      body: Column(
        children: [
          _FilterBar(activeFilter: activeFilter, ref: ref),
          if (dateRange != DeliveryDateRangeFilter.none &&
              (activeFilter == DeliveryFilter.all ||
                  activeFilter == DeliveryFilter.completed))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  label: Text(_dateRangeLabel(dateRange)),
                  onDeleted: () {
                    ref
                        .read(deliveryDateRangeProvider.notifier)
                        .setRange(DeliveryDateRangeFilter.none);
                  },
                ),
              ),
            ),
          const Divider(height: 1),
          Expanded(
            child: deliveriesAsync.when(
              data: (deliveries) {
                if (deliveries.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.local_shipping_outlined,
                    message: 'No deliveries found',
                    subMessage: 'Tap + to schedule a new delivery',
                  );
                }

                final customerMap = customersAsync.when(
                  data: (customers) =>
                      {for (final c in customers) c.id: c.name},
                  loading: () => <String, String>{},
                  error: (_, __) => <String, String>{},
                );

                return ListView.builder(
                  padding: EdgeInsets.only(
                    top: 8,
                    bottom: context.fabListBottomPadding,
                  ),
                  itemCount: deliveries.length,
                  itemBuilder: (context, index) {
                    final d = deliveries[index];
                    return DeliveryListTile(
                      delivery: d,
                      customerName: customerMap[d.customerId] ?? 'Unknown',
                    );
                  },
                );
              },
              loading: () => const LoadingOverlay(),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/deliveries/add'),
        icon: const Icon(Icons.add),
        label: const Text('New Delivery'),
      ),
    );
  }

  String _dateRangeLabel(DeliveryDateRangeFilter range) {
    switch (range) {
      case DeliveryDateRangeFilter.today:
        return 'Today';
      case DeliveryDateRangeFilter.thisWeek:
        return 'This Week';
      case DeliveryDateRangeFilter.thisMonth:
        return 'This Month';
      case DeliveryDateRangeFilter.custom:
        return 'Custom Range';
      case DeliveryDateRangeFilter.none:
        return '';
    }
  }

  Future<void> _showDateFilter(
    BuildContext context,
    WidgetRef ref,
    DeliveryFilter filter,
  ) async {
    final result = await showModalBottomSheet<DeliveryDateRangeFilter>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Today'),
              onTap: () =>
                  Navigator.pop(ctx, DeliveryDateRangeFilter.today),
            ),
            ListTile(
              title: const Text('This Week'),
              onTap: () =>
                  Navigator.pop(ctx, DeliveryDateRangeFilter.thisWeek),
            ),
            ListTile(
              title: const Text('This Month'),
              onTap: () =>
                  Navigator.pop(ctx, DeliveryDateRangeFilter.thisMonth),
            ),
            ListTile(
              title: const Text('Custom Range'),
              onTap: () async {
                Navigator.pop(ctx);
                final now = DateTime.now();
                final start = await showDatePicker(
                  context: context,
                  initialDate: now,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (start == null || !context.mounted) return;
                final end = await showDatePicker(
                  context: context,
                  initialDate: start,
                  firstDate: start,
                  lastDate: DateTime(2100),
                );
                if (end != null) {
                  ref
                      .read(customDateRangeProvider.notifier)
                      .setRange(start, end);
                  ref
                      .read(deliveryDateRangeProvider.notifier)
                      .setRange(DeliveryDateRangeFilter.custom);
                }
              },
            ),
          ],
        ),
      ),
    );
    if (result != null) {
      ref.read(deliveryDateRangeProvider.notifier).setRange(result);
    }
  }
}

class _FilterBar extends StatelessWidget {
  final DeliveryFilter activeFilter;
  final WidgetRef ref;

  const _FilterBar({required this.activeFilter, required this.ref});

  @override
  Widget build(BuildContext context) {
    final filters = [
      (DeliveryFilter.today, 'Today'),
      (DeliveryFilter.completed, 'Completed'),
      (DeliveryFilter.all, 'All'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: filters.map((entry) {
          final (filter, label) = entry;
          final isActive = activeFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(label),
              selected: isActive,
              onSelected: (_) {
                ref.read(deliveryFilterProvider.notifier).setFilter(filter);
                if (filter == DeliveryFilter.today) {
                  ref
                      .read(deliveryDateRangeProvider.notifier)
                      .setRange(DeliveryDateRangeFilter.none);
                }
              },
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }
}
