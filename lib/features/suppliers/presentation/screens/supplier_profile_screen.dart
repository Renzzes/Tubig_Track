import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../providers/suppliers_provider.dart';

class SupplierProfileScreen extends ConsumerWidget {
  final String supplierId;

  const SupplierProfileScreen({super.key, required this.supplierId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supplierAsync = ref.watch(suppliersStreamProvider);
    final analyticsAsync = ref.watch(supplierAnalyticsProvider(supplierId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Supplier Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () =>
                context.push('/inventory/suppliers/$supplierId/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _delete(context, ref),
          ),
        ],
      ),
      body: supplierAsync.when(
        data: (all) {
          final supplier = all.where((s) => s.id == supplierId).firstOrNull;
          if (supplier == null) {
            return const Center(child: Text('Supplier not found'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(supplier.name,
                  style: Theme.of(context).textTheme.headlineSmall),
              if (supplier.contactPerson != null) ...[
                const SizedBox(height: 8),
                Text(supplier.contactPerson!),
              ],
              if (supplier.mobile != null) Text(supplier.mobile!),
              if (supplier.address != null) Text(supplier.address!),
              if (supplier.notes != null) ...[
                const SizedBox(height: 8),
                Text(supplier.notes!,
                    style: TextStyle(color: Colors.grey[600])),
              ],
              const Divider(height: 32),
              Text('Analytics',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              analyticsAsync.when(
                data: (a) => Column(
                  children: [
                    _StatRow('Total Purchases', '${a.totalPurchases}'),
                    _StatRow(
                      'Total Amount Purchased',
                      CurrencyFormatter.format(a.totalAmount),
                    ),
                    _StatRow(
                      'Last Purchase Date',
                      a.lastPurchaseDate != null
                          ? DateFormatter.format(a.lastPurchaseDate!)
                          : '—',
                    ),
                    _StatRow(
                      'Most Purchased Item',
                      a.mostPurchasedItem ?? '—',
                    ),
                  ],
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('Error: $e'),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Supplier'),
        content: const Text('Delete this supplier? Purchase records are kept.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(supplierRepositoryProvider).deleteSupplier(supplierId);
      if (context.mounted) context.pop();
    }
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(color: Colors.grey[700]))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
