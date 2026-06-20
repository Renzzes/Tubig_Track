import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/date_formatter.dart';
import '../providers/inventory_provider.dart';

class InventoryAdjustmentHistoryScreen extends ConsumerWidget {
  const InventoryAdjustmentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adjustmentsAsync = ref.watch(inventoryAdjustmentsStreamProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Adjustment History')),
      body: adjustmentsAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No adjustments recorded.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = items[index];
              final sign = item.quantity >= 0 ? '+' : '';
              final color = item.quantity >= 0 ? Colors.green : Colors.red;
              return Card(
                child: ListTile(
                  title: Text(
                    '$sign${item.quantity}',
                    style: TextStyle(color: color, fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    '${DateFormatter.formatDateTime(item.adjustmentDate)}\n${item.reason}${item.notes != null ? '\n${item.notes}' : ''}',
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
