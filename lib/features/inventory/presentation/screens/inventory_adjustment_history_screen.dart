import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/inventory_activity_utils.dart';
import '../../../supply_purchases/presentation/providers/supply_purchase_provider.dart';
import '../providers/inventory_provider.dart';

class InventoryAdjustmentHistoryScreen extends ConsumerWidget {
  const InventoryAdjustmentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(bottleTransactionsStreamProvider);
    final adjustmentsAsync = ref.watch(inventoryAdjustmentsStreamProvider);
    final auditsAsync = ref.watch(inventoryAuditsStreamProvider);
    final supplyAsync = ref.watch(supplyPurchasesStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Adjustment History')),
      body: transactionsAsync.when(
        data: (transactions) => adjustmentsAsync.when(
          data: (adjustments) => auditsAsync.when(
            data: (audits) => supplyAsync.when(
              data: (supplyPurchases) {
                final items = buildInventoryActivityHistory(
                  transactions: transactions,
                  adjustments: adjustments,
                  audits: audits,
                  supplyPurchases: supplyPurchases,
                );
                if (items.isEmpty) {
                  return const Center(child: Text('No inventory activity recorded.'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      child: ListTile(
                        title: Text(item.categoryLabel),
                        subtitle: Text(
                          '${DateFormatter.formatDateTime(item.date)}\n'
                          '${item.title}'
                          '${item.detail != null ? '\n${item.detail}' : ''}',
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
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
