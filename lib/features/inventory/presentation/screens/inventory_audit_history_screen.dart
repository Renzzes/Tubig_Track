import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/inventory_audit.dart';
import '../providers/inventory_provider.dart';

class InventoryAuditHistoryScreen extends ConsumerWidget {
  const InventoryAuditHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auditsAsync = ref.watch(inventoryAuditsStreamProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Audit History')),
      body: auditsAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No audits recorded.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = items[index];
              final sign = item.difference >= 0 ? '+' : '';
              return Card(
                child: ListTile(
                  title: Text(DateFormatter.formatDateTime(item.auditDate)),
                  subtitle: Text(
                    'System: ${item.systemCount} • Physical: ${item.physicalCount}\n'
                    'Difference: $sign${item.difference}\n'
                    'Action: ${InventoryAudit.actionLabel(item.actionTaken)}'
                    '${item.notes != null ? '\n${item.notes}' : ''}',
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
