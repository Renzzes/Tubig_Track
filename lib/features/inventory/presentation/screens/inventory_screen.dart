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

  void _openEditSheet(BuildContext context, WidgetRef ref,
      BottleTransaction transaction) {
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

  Future<void> _deleteTransaction(BuildContext context, WidgetRef ref,
      BottleTransaction tx) async {
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
      await ref.read(inventoryRepositoryProvider).deleteTransaction(tx.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction deleted')),
        );
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
          // Stats grid
          summaryAsync.when(
            data: (s) => ResponsiveStatGrid(
              children: [
                InventoryStatCard(
                  label: 'Total Bottles',
                  value: '${s.totalBottles}',
                  icon: Icons.inventory_2,
                  color: AppColors.primary,
                  subtitle: 'Initial + Purchased − Damaged',
                ),
                InventoryStatCard(
                  label: 'Available',
                  value: '${s.availableBottles}',
                  icon: Icons.check_circle_outline,
                  color: AppColors.success,
                  subtitle: 'Total − Borrowed',
                ),
                InventoryStatCard(
                  label: 'Borrowed',
                  value: '${s.borrowedOutstanding}',
                  icon: Icons.arrow_upward,
                  color: AppColors.warning,
                  subtitle: 'with customers',
                ),
                InventoryStatCard(
                  label: 'Damaged',
                  value: '${s.damagedBottles}',
                  icon: Icons.broken_image_outlined,
                  color: AppColors.error,
                ),
              ],
            ),
            loading: () => const LoadingOverlay(),
            error: (e, _) => Text('Error: $e'),
          ),
          const SizedBox(height: 20),

          // Supply management
          Text(
            'Supply Management',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final useColumn = constraints.maxWidth < 400;
              final children = [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.push('/inventory/purchase-stock'),
                    icon: const Icon(Icons.add_shopping_cart, size: 18),
                    label: const Text('Purchase Stock'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        context.push('/inventory/supply-purchases'),
                    icon: const Icon(Icons.history, size: 18),
                    label: const Text('Supply Purchases'),
                  ),
                ),
              ];
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
                  ],
                );
              }
              return Row(children: children);
            },
          ),
          summaryAsync.when(
            data: (s) {
              if (s.gallonsStock == 0 &&
                  s.capsStock == 0 &&
                  s.waterStocks == 0 &&
                  s.othersStock == 0) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (s.gallonsStock > 0)
                      Chip(label: Text('Gallons: ${s.gallonsStock}')),
                    if (s.capsStock > 0)
                      Chip(label: Text('Caps: ${s.capsStock}')),
                    if (s.waterStocks > 0)
                      Chip(label: Text('Water Stocks: ${s.waterStocks}')),
                    if (s.othersStock > 0)
                      Chip(label: Text('Others: ${s.othersStock}')),
                  ],
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 20),

          // Action buttons
          Text(
            'Record Transaction',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = context.actionGridColumns;
              final aspectRatio = context.isSmallPhone ? 2.2 : 2.5;
              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: aspectRatio,
                children: [
              _ActionButton(
                label: 'Return Bottles',
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
                label: 'Manual Borrow',
                icon: Icons.arrow_upward,
                color: AppColors.warning,
                onTap: () => _openTransactionSheet(
                  context,
                  ref,
                  TransactionType.borrow,
                ),
              ),
            ],
          );
            },
          ),
          const SizedBox(height: 24),

          // Transaction history
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
              return Column(
                children: transactions.map((tx) {
                  Color color;
                  IconData icon;
                  switch (tx.transactionType) {
                    case TransactionType.borrow:
                      color = AppColors.warning;
                      icon = Icons.arrow_upward;
                    case TransactionType.ret:
                      color = AppColors.success;
                      icon = Icons.arrow_downward;
                    case TransactionType.damaged:
                      color = AppColors.error;
                      icon = Icons.broken_image_outlined;
                    case TransactionType.purchase:
                      color = AppColors.primary;
                      icon = Icons.shopping_cart_outlined;
                  }
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
                      child: const Icon(Icons.delete_outline,
                          color: AppColors.error),
                    ),
                    confirmDismiss: (_) async {
                      await _deleteTransaction(context, ref, tx);
                      return false; // Stream handles the removal
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
                            const SizedBox(width: 4),
                            Icon(Icons.edit_outlined,
                                size: 16, color: Colors.grey[400]),
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
              'Enter the initial number of bottles owned (before transactions).',
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
