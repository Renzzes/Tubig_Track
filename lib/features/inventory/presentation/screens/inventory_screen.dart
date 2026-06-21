import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../../customers/presentation/providers/customers_provider.dart';
import '../../domain/entities/bottle_transaction.dart';
import '../providers/inventory_provider.dart';
import '../widgets/inventory_stat_card.dart';
import '../widgets/transaction_bottom_sheet.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  void _openTransactionSheet(
    BuildContext context,
    WidgetRef ref,
    TransactionType type,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TransactionBottomSheet(transactionType: type),
    );
  }

  void _openEditSheet(
    BuildContext context,
    WidgetRef ref,
    BottleTransaction transaction,
  ) {
    if (transaction.isDeliveryLinked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Delivery-linked transactions must be edited from the delivery record.',
          ),
        ),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TransactionBottomSheet(
        transactionType: transaction.transactionType,
        existingTransaction: transaction,
      ),
    );
  }

  Future<void> _deleteTransaction(
    BuildContext context,
    WidgetRef ref,
    BottleTransaction tx,
  ) async {
    if (tx.isDeliveryLinked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Delivery-linked transactions must be deleted from the delivery record.',
          ),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: Text(
          'Delete ${BottleTransaction.typeLabel(tx.transactionType)} of ${tx.quantity} bottles?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await ref.read(inventoryRepositoryProvider).deleteTransaction(tx.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaction deleted')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(inventorySummaryProvider);
    final transactionsAsync = ref.watch(bottleTransactionsStreamProvider);
    final customersAsync = ref.watch(customersStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              refreshInventoryProviders(ref);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Inventory refreshed')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showSetInventoryDialog(context, ref),
            tooltip: 'Set Initial Inventory',
          ),
        ],
      ),
      body: ResponsiveContent(
        padding: EdgeInsets.all(context.pageHorizontalPadding),
        child: ListView(
          children: [
            summaryAsync.when(
              data: (s) => Column(
                children: [
                  ResponsiveStatGrid(
                    children: [
                      InventoryStatCard(
                        label: 'Total Bottles Owned',
                        value: '${s.totalBottlesOwned}',
                        icon: Icons.inventory_2,
                        color: AppColors.primary,
                        subtitle: 'Lifetime bottles owned',
                      ),
                      InventoryStatCard(
                        label: 'Available Stock',
                        value: '${s.availableBottles}',
                        icon: Icons.check_circle_outline,
                        color: AppColors.success,
                        subtitle: 'Ready in warehouse',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ResponsiveStatGrid(
                    children: [
                      InventoryStatCard(
                        label: 'Bottles With Customers',
                        value: '${s.bottlesWithCustomers}',
                        icon: Icons.people_outline,
                        color: AppColors.warning,
                        subtitle: 'Delivered − Collected • Tap for details',
                        onTap: () =>
                            context.push('/inventory/customer-balances'),
                      ),
                      InventoryStatCard(
                        label: 'Damaged Bottles',
                        value: '${s.damagedBottles}',
                        icon: Icons.broken_image_outlined,
                        color: AppColors.error,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  InventoryStatCard(
                    label: 'Missing Bottles',
                    value: '${s.missingBottles}',
                    icon: Icons.help_outline,
                    color: AppColors.missing,
                    subtitle: 'Unaccounted for',
                  ),
                ],
              ),
              loading: () => const LoadingOverlay(),
              error: (e, _) => Text('Error: $e'),
            ),
            const SizedBox(height: 20),

            Text(
              'Supply Management',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final useColumn = constraints.maxWidth < 400;
                if (useColumn) {
                  return Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              context.push('/inventory/purchase-stock'),
                          icon: const Icon(Icons.add_shopping_cart, size: 18),
                          label: const Text('Purchase Stock'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              context.push('/inventory/supply-purchases'),
                          icon: const Icon(Icons.history, size: 18),
                          label: const Text('Supply Purchases'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => context.push('/inventory/suppliers'),
                          icon: const Icon(Icons.store_outlined, size: 18),
                          label: const Text('Suppliers'),
                        ),
                      ),
                    ],
                  );
                }
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => context.push('/inventory/purchase-stock'),
                      icon: const Icon(Icons.add_shopping_cart, size: 18),
                      label: const Text('Purchase Stock'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () =>
                          context.push('/inventory/supply-purchases'),
                      icon: const Icon(Icons.history, size: 18),
                      label: const Text('Supply Purchases'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => context.push('/inventory/suppliers'),
                      icon: const Icon(Icons.store_outlined, size: 18),
                      label: const Text('Suppliers'),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),

            Text(
              'Audit & Reconciliation',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => context.push('/inventory/audit'),
                  icon: const Icon(Icons.fact_check_outlined, size: 18),
                  label: const Text('Audit Inventory'),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.push('/inventory/audit-history'),
                  icon: const Icon(Icons.history_toggle_off, size: 18),
                  label: const Text('Audit History'),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.push('/inventory/adjustments'),
                  icon: const Icon(Icons.tune_outlined, size: 18),
                  label: const Text('Adjustment History'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Text(
              'Record Transaction',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = context.actionGridColumns;
                final aspectRatio = context.isSmallPhone ? 2.0 : 2.3;
                return GridView.count(
                  crossAxisCount: columns,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: aspectRatio,
                  children: [
                    _ActionButton(
                      label: 'Collect Bottles',
                      icon: Icons.arrow_downward,
                      color: AppColors.success,
                      onTap: () => _openTransactionSheet(
                        context,
                        ref,
                        TransactionType.ret,
                      ),
                    ),
                    _ActionButton(
                      label: 'Damaged',
                      icon: Icons.broken_image_outlined,
                      color: AppColors.error,
                      onTap: () => _openTransactionSheet(
                        context,
                        ref,
                        TransactionType.damaged,
                      ),
                    ),
                    _ActionButton(
                      label: 'Purchase Bottles',
                      icon: Icons.shopping_cart_outlined,
                      color: AppColors.primary,
                      onTap: () => _openTransactionSheet(
                        context,
                        ref,
                        TransactionType.purchase,
                      ),
                    ),
                    _ActionButton(
                      label: 'Add Bottles',
                      icon: Icons.add_circle_outline,
                      color: Colors.teal,
                      onTap: () => _openTransactionSheet(
                        context,
                        ref,
                        TransactionType.added,
                      ),
                    ),
                    _ActionButton(
                      label: 'Manual Borrow',
                      icon: Icons.arrow_upward,
                      color: AppColors.warning,
                      onTap: () => _openTransactionSheet(
                        context,
                        ref,
                        TransactionType.borrow,
                      ),
                    ),
                    _ActionButton(
                      label: 'Inventory Adjustment',
                      icon: Icons.tune_outlined,
                      color: Colors.indigo,
                      onTap: () => _openTransactionSheet(
                        context,
                        ref,
                        TransactionType.adjustment,
                      ),
                    ),
                    _ActionButton(
                      label: 'Missing Bottles',
                      icon: Icons.help_outline,
                      color: AppColors.missing,
                      onTap: () => _openTransactionSheet(
                        context,
                        ref,
                        TransactionType.missing,
                      ),
                    ),
                    _ActionButton(
                      label: 'Donate Bottles',
                      icon: Icons.volunteer_activism_outlined,
                      color: Colors.deepPurple,
                      onTap: () => _openTransactionSheet(
                        context,
                        ref,
                        TransactionType.donation,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: Text(
                    'Transaction History',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/inventory/history'),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Swipe left to delete • Tap to edit',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
            const SizedBox(height: 8),
            transactionsAsync.when(
              data: (transactions) {
                if (transactions.isEmpty) {
                  return const EmptyStateWidget(
                    message: 'No transactions yet',
                    icon: Icons.swap_horiz,
                  );
                }
                final customerMap = customersAsync.when(
                  data: (customers) =>
                      {for (final c in customers) c.id: c.name},
                  loading: () => <String, String>{},
                  error: (_, __) => <String, String>{},
                );
                final preview = transactions.take(10).toList();
                return Column(
                  children: preview.map((tx) {
                    final color = _colorForType(tx.transactionType);
                    final icon = _iconForType(tx.transactionType);
                    final label =
                        BottleTransaction.typeLabel(tx.transactionType);
                    final customerName = tx.customerId != null
                        ? customerMap[tx.customerId] ?? 'Unknown'
                        : null;

                    return Dismissible(
                      key: Key(tx.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          color: AppColors.error,
                        ),
                      ),
                      confirmDismiss: (_) async {
                        await _deleteTransaction(context, ref, tx);
                        return false;
                      },
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 6),
                        child: ListTile(
                          onTap: () => _openEditSheet(context, ref, tx),
                          leading: CircleAvatar(
                            backgroundColor: color.withValues(alpha: 0.1),
                            child: Icon(icon, color: color, size: 20),
                          ),
                          title: Text(
                            '$label${customerName != null ? ' — $customerName' : ''}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(DateFormatter.format(tx.date)),
                              if (tx.reason != null && tx.reason!.isNotEmpty)
                                Text(tx.reason!),
                              if (tx.notes != null) Text(tx.notes!),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${tx.quantity} btl',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: color,
                                ),
                              ),
                              if (!tx.isDeliveryLinked) ...[
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.edit_outlined,
                                  size: 16,
                                  color: Colors.grey[400],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const LoadingOverlay(),
              error: (e, _) => Text('Error: $e'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSetInventoryDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set Initial Inventory'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter the initial number of bottles owned before transactions.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Initial Bottles',
                hintText: 'e.g. 200',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final n = int.tryParse(controller.text);
              if (n != null && n >= 0) {
                await ref
                    .read(inventoryRepositoryProvider)
                    .updateTotalInventory(n);
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  static Color _colorForType(TransactionType type) {
    switch (type) {
      case TransactionType.borrow:
        return AppColors.warning;
      case TransactionType.ret:
        return AppColors.success;
      case TransactionType.damaged:
        return AppColors.error;
      case TransactionType.purchase:
        return AppColors.primary;
      case TransactionType.added:
        return Colors.teal;
      case TransactionType.missing:
        return AppColors.missing;
      case TransactionType.donation:
        return Colors.deepPurple;
      case TransactionType.adjustment:
        return Colors.indigo;
      case TransactionType.audit:
        return Colors.blueGrey;
    }
  }

  static IconData _iconForType(TransactionType type) {
    switch (type) {
      case TransactionType.borrow:
        return Icons.arrow_upward;
      case TransactionType.ret:
        return Icons.arrow_downward;
      case TransactionType.damaged:
        return Icons.broken_image_outlined;
      case TransactionType.purchase:
        return Icons.shopping_cart_outlined;
      case TransactionType.added:
        return Icons.add_circle_outline;
      case TransactionType.missing:
        return Icons.help_outline;
      case TransactionType.donation:
        return Icons.volunteer_activism_outlined;
      case TransactionType.adjustment:
        return Icons.tune_outlined;
      case TransactionType.audit:
        return Icons.fact_check_outlined;
    }
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
