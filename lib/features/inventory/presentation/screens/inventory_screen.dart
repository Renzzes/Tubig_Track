import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/inventory_health_utils.dart';
import '../../../../core/utils/business_timeline_utils.dart';
import '../../../../core/utils/responsive.dart';
import '../../../deliveries/presentation/providers/deliveries_provider.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../../customers/presentation/providers/customers_provider.dart';
import '../../../supply_purchases/presentation/providers/supply_purchase_provider.dart';
import '../../../deliveries/domain/entities/delivery.dart';
import '../../../deposits/domain/entities/customer_deposit.dart';
import '../../../deposits/presentation/providers/deposits_provider.dart';
import '../../../payments/presentation/providers/payments_provider.dart';
import '../../domain/entities/customer_bottle_reconciliation.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(inventorySummaryProvider);
    final consistencyAsync = ref.watch(inventoryConsistencyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () async {
              refreshInventoryProviders(ref);
              final report = await ref.read(
                inventoryRepositoryProvider,
              ).validateConsistency();
              if (context.mounted) {
                if (!report.isCustomerBalanceConsistent) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Balance check: customer totals differ by '
                        '${report.customerBalanceDelta.abs()} bottles',
                      ),
                      backgroundColor: AppColors.warning,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Inventory refreshed')),
                  );
                }
              }
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
            consistencyAsync.when(
              data: (report) {
                final health = InventoryHealthUtils.compute(report);
                final overflow = InventoryHealthUtils.isInventoryOverflow(report);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InventoryHealthBanner(health: health),
                    if (overflow) ...[
                      const SizedBox(height: 8),
                      _InventoryWarningBanner(
                        message:
                            'Inventory Mismatch Detected\n'
                            'Current inventory exceeds Total Bottles Owned.\n'
                            'Run Inventory Audit or Purchase New Bottles.',
                        color: AppColors.error,
                      ),
                    ] else if (!report.isCustomerBalanceConsistent) ...[
                      const SizedBox(height: 8),
                      _InventoryWarningBanner(
                        message:
                            'Customer bottle balances do not match '
                            'inventory totals.\n'
                            'Difference: ${report.customerBalanceDelta.abs()} '
                            'bottles. Run reconciliation.',
                        color: AppColors.warning,
                      ),
                    ],
                    const SizedBox(height: 12),
                  ],
                );
              },
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),
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
                        tooltip: 'All bottles ever owned.',
                      ),
                      InventoryStatCard(
                        label: 'Filled Bottles Available',
                        value: '${s.filledBottlesAvailable}',
                        icon: Icons.check_circle_outline,
                        color: AppColors.success,
                        tooltip:
                            'Filled bottles ready for delivery.',
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
                        tooltip:
                            'Bottles currently held by customers.',
                        onTap: () =>
                            context.push('/inventory/customer-balances'),
                      ),
                      InventoryStatCard(
                        label: 'Empty Bottles Ready For Refill',
                        value: '${s.emptyBottlesReadyForRefill}',
                        icon: Icons.inbox_outlined,
                        color: Colors.teal,
                        tooltip:
                            'Collected bottles waiting for refill.',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ResponsiveStatGrid(
                    children: [
                      InventoryStatCard(
                        label: 'Damaged Bottles',
                        value: '${s.damagedBottles}',
                        icon: Icons.broken_image_outlined,
                        color: AppColors.error,
                        tooltip: 'Permanently damaged bottles.',
                      ),
                      InventoryStatCard(
                        label: 'Missing Bottles',
                        value: '${s.missingBottles}',
                        icon: Icons.help_outline,
                        color: AppColors.missing,
                        tooltip: 'Unaccounted bottles.',
                      ),
                    ],
                  ),
                ],
              ),
              loading: () => const LoadingOverlay(),
              error: (e, _) => Text('Error: $e'),
            ),
            const SizedBox(height: 20),

            Text(
              'Daily Operations',
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
                        child: _ActionButton(
                          label: 'Collect Bottles',
                          icon: Icons.arrow_downward,
                          color: AppColors.success,
                          onTap: () => _openTransactionSheet(
                            context,
                            ref,
                            TransactionType.ret,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: _ActionButton(
                          label: 'Supplier Delivery',
                          icon: Icons.local_shipping_outlined,
                          color: AppColors.primary,
                          onTap: () =>
                              context.push('/inventory/purchase-stock'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: _ActionButton(
                          label: 'Purchase New Bottles',
                          icon: Icons.shopping_cart_outlined,
                          color: AppColors.primary,
                          onTap: () => _openTransactionSheet(
                            context,
                            ref,
                            TransactionType.purchase,
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return GridView.count(
                  crossAxisCount: context.actionGridColumns.clamp(1, 3),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: context.isSmallPhone ? 2.0 : 2.3,
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
                      label: 'Supplier Delivery',
                      icon: Icons.local_shipping_outlined,
                      color: AppColors.primary,
                      onTap: () => context.push('/inventory/purchase-stock'),
                    ),
                    _ActionButton(
                      label: 'Purchase New Bottles',
                      icon: Icons.shopping_cart_outlined,
                      color: AppColors.primary,
                      onTap: () => _openTransactionSheet(
                        context,
                        ref,
                        TransactionType.purchase,
                      ),
                    ),
                  ],
                );
              },
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
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              context.push('/inventory/supply-purchases'),
                          icon: const Icon(Icons.history, size: 18),
                          label: const Text('Supplier Delivery History'),
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
                    OutlinedButton.icon(
                      onPressed: () =>
                          context.push('/inventory/supply-purchases'),
                      icon: const Icon(Icons.history, size: 18),
                      label: const Text('Supplier Delivery History'),
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

            OutlinedButton.icon(
              onPressed: () => context.push('/inventory/tools'),
              icon: const Icon(Icons.build_outlined, size: 18),
              label: const Text('Inventory Tools'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: Text(
                    'Business Timeline',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/inventory/business-timeline'),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _BusinessTimelinePreview(),
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
}

class _BusinessTimelinePreview extends ConsumerWidget {
  const _BusinessTimelinePreview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(bottleTransactionsStreamProvider);
    final supplyAsync = ref.watch(supplyPurchasesStreamProvider);
    final deliveriesAsync = ref.watch(deliveriesStreamProvider);
    final paymentsAsync = ref.watch(paymentsStreamProvider);
    final depositsAsync = ref.watch(allCustomerDepositsStreamProvider);
    final customersAsync = ref.watch(customersStreamProvider);
    final reconciliationsAsync = ref.watch(bottleReconciliationsStreamProvider);

    return transactionsAsync.when(
      data: (transactions) => supplyAsync.when(
        data: (purchases) => deliveriesAsync.when(
          data: (deliveries) => paymentsAsync.when(
            data: (payments) => depositsAsync.when(
              data: (deposits) {
                final reconciliations = reconciliationsAsync.when(
                  data: (r) => r,
                  loading: () => <CustomerBottleReconciliation>[],
                  error: (_, __) => <CustomerBottleReconciliation>[],
                );
                final customerMap = customersAsync.when(
                  data: (c) => {for (final x in c) x.id: x.name},
                  loading: () => <String, String>{},
                  error: (_, __) => <String, String>{},
                );
                final linkedIds = purchases
                    .map((p) => p.bottleTransactionId)
                    .whereType<String>()
                    .toSet();
                final timeline = buildBusinessTimeline(
                  transactions: transactions,
                  supplyPurchases: purchases,
                  supplyLinkedTxIds: linkedIds,
                  customerNames: customerMap,
                  deliveries: deliveries
                      .where(
                        (d) =>
                            d.deliveryStatus == DeliveryStatus.completed,
                      )
                      .map(
                        (d) => (
                          id: d.id,
                          customerId: d.customerId,
                          quantity: d.quantity,
                          date: d.deliveryDate,
                        ),
                      )
                      .toList(),
                  payments: payments
                      .map(
                        (p) => (
                          amount: p.amount,
                          date: p.paymentDate,
                          customerName: customerMap[p.customerId],
                        ),
                      )
                      .toList(),
                  deposits: deposits
                      .map(
                        (d) => (
                          label:
                              CustomerDeposit.typeLabel(d.transactionType),
                          amount: d.amount,
                          date: d.createdAt,
                          customerName: customerMap[d.customerId],
                        ),
                      )
                      .toList(),
                  reconciliations: reconciliations,
                );
                if (timeline.isEmpty) {
                  return const EmptyStateWidget(
                    message: 'No business activity yet',
                    icon: Icons.timeline,
                  );
                }
                return Column(
                  children: timeline.take(3).map((entry) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 6),
                      child: ListTile(
                        title: Text(
                          entry.headline,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (entry.subtitle != null)
                              Text(entry.subtitle!),
                            Text(DateFormatter.format(entry.date)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const LoadingOverlay(),
              error: (e, _) => Text('Error: $e'),
            ),
            loading: () => const LoadingOverlay(),
            error: (e, _) => Text('Error: $e'),
          ),
          loading: () => const LoadingOverlay(),
          error: (e, _) => Text('Error: $e'),
        ),
        loading: () => const LoadingOverlay(),
        error: (e, _) => Text('Error: $e'),
      ),
      loading: () => const LoadingOverlay(),
      error: (e, _) => Text('Error: $e'),
    );
  }
}

class _InventoryHealthBanner extends StatelessWidget {
  final InventoryHealth health;

  const _InventoryHealthBanner({required this.health});

  @override
  Widget build(BuildContext context) {
    final color = switch (health) {
      InventoryHealth.healthy => AppColors.success,
      InventoryHealth.warning => AppColors.warning,
      InventoryHealth.critical => AppColors.error,
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(
            health == InventoryHealth.healthy
                ? Icons.check_circle_outline
                : Icons.warning_amber_rounded,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            'Inventory Health: ${InventoryHealthUtils.label(health)}',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _InventoryWarningBanner extends StatelessWidget {
  final String message;
  final Color color;

  const _InventoryWarningBanner({
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                color: color.withValues(alpha: 0.95),
                fontWeight: FontWeight.w600,
              ),
            ),
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
