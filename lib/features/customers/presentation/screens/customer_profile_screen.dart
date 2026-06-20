import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../../deliveries/domain/entities/delivery.dart';
import '../../../deliveries/presentation/providers/deliveries_provider.dart';
import '../../../inventory/domain/entities/bottle_transaction.dart';
import '../../../inventory/presentation/providers/inventory_provider.dart';
import '../../../payments/presentation/providers/payments_provider.dart';
import '../providers/customers_provider.dart';
import '../widgets/customer_stats_row.dart';

class CustomerProfileScreen extends ConsumerWidget {
  final String customerId;

  const CustomerProfileScreen({super.key, required this.customerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerAsync = ref.watch(customerByIdProvider(customerId));
    final statsAsync = ref.watch(customerStatsProvider(customerId));
    // Use stream providers for live updates
    final deliveriesAsync =
        ref.watch(customerDeliveriesStreamProvider(customerId));
    final paymentsAsync =
        ref.watch(customerPaymentsStreamProvider(customerId));
    final allTransactionsAsync = ref.watch(bottleTransactionsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: customerAsync.when(
          data: (c) => Text(c?.name ?? 'Customer'),
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('Customer'),
        ),
        actions: [
          customerAsync.when(
            data: (c) {
              if (c == null) return const SizedBox();
              return IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () =>
                    context.push('/customers/$customerId/edit'),
              );
            },
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
      body: customerAsync.when(
        data: (customer) {
          if (customer == null) {
            return const Center(child: Text('Customer not found'));
          }

          // Filter bottle transactions to this customer
          final customerTransactions = allTransactionsAsync.when(
            data: (txs) =>
                txs.where((t) => t.customerId == customerId).toList(),
            loading: () => <BottleTransaction>[],
            error: (_, __) => <BottleTransaction>[],
          );

          return ResponsiveContent(
            padding: EdgeInsets.all(context.pageHorizontalPadding),
            child: ListView(
            children: [
              // Contact info card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.1),
                            radius: 28,
                            child: Text(
                              customer.name[0].toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 22,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  customer.name,
                                  style:
                                      Theme.of(context).textTheme.titleLarge,
                                ),
                                Text(
                                  'Since ${DateFormatter.format(customer.createdAt)}',
                                  style:
                                      Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (customer.phone != null) ...[
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 8),
                        _InfoRow(
                            icon: Icons.phone_outlined,
                            text: customer.phone!),
                      ],
                      if (customer.address != null) ...[
                        const SizedBox(height: 8),
                        _InfoRow(
                            icon: Icons.location_on_outlined,
                            text: customer.address!),
                      ],
                      if (customer.notes != null) ...[
                        const SizedBox(height: 8),
                        _InfoRow(
                            icon: Icons.note_outlined,
                            text: customer.notes!),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Stats card — Outstanding Balance + Bottles
              statsAsync.when(
                data: (stats) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Account Overview',
                                style: Theme.of(context).textTheme.titleMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _paymentBadge(stats.unpaidBalance,
                                stats.totalAmountPaid),
                          ],
                        ),
                        const SizedBox(height: 12),
                        CustomerStatsRow(stats: stats),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 12),
                        Text(
                          'Customer Analytics',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        _AnalyticsRow(
                          label: 'Lifetime Revenue',
                          value: CurrencyFormatter.format(stats.lifetimeRevenue),
                        ),
                        _AnalyticsRow(
                          label: 'Bottles Delivered',
                          value: '${stats.lifetimeBottlesDelivered}',
                        ),
                        _AnalyticsRow(
                          label: 'Total Deliveries',
                          value: '${stats.totalDeliveries}',
                        ),
                        _AnalyticsRow(
                          label: 'Last Delivery',
                          value: stats.lastDeliveryDate != null
                              ? DateFormatter.format(stats.lastDeliveryDate!)
                              : 'None',
                        ),
                      ],
                    ),
                  ),
                ),
                loading: () => const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: LoadingOverlay(),
                  ),
                ),
                error: (e, _) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Error: $e'),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Action buttons — stack on very narrow screens
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 360) {
                    return Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => context.push(
                              '/deliveries/add',
                              extra: {'customerId': customerId},
                            ),
                            icon: const Icon(Icons.add_shopping_cart),
                            label: const Text('New Delivery'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                context.push('/customers/$customerId/payment'),
                            icon: const Icon(Icons.payments_outlined),
                            label: const Text('Receive Payment'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => context.push(
                            '/deliveries/add',
                            extra: {'customerId': customerId},
                          ),
                          icon: const Icon(Icons.add_shopping_cart),
                          label: const Text('New Delivery'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(0, 48),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              context.push('/customers/$customerId/payment'),
                          icon: const Icon(Icons.payments_outlined),
                          label: const Text('Receive Payment'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 48),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // ── DELIVERIES ──────────────────────────────────────────────
              _SectionHeader(
                title: 'Deliveries',
                count: deliveriesAsync.whenOrNull(data: (d) => d.length),
                onViewAll: () => context.push(
                  '/customers/$customerId/history/deliveries',
                ),
              ),
              const SizedBox(height: 8),
              deliveriesAsync.when(
                data: (deliveries) {
                  if (deliveries.isEmpty) {
                    return const EmptyStateWidget(
                      message: 'No deliveries yet',
                      icon: Icons.local_shipping_outlined,
                    );
                  }
                  return Column(
                    children: deliveries.map((d) {
                      Color statusColor;
                      String statusLabel;
                      switch (d.paymentStatus) {
                        case PaymentStatus.paid:
                          statusColor = AppColors.paid;
                          statusLabel = 'PAID';
                        case PaymentStatus.partial:
                          statusColor = AppColors.partial;
                          statusLabel = 'PARTIAL';
                        default:
                          statusColor = AppColors.unpaid;
                          statusLabel = 'UNPAID';
                      }

                      // Delivery status color
                      Color deliveryColor;
                      String deliveryLabel;
                      switch (d.deliveryStatus) {
                        case DeliveryStatus.scheduled:
                          deliveryColor = Colors.blue;
                          deliveryLabel = 'Scheduled';
                        case DeliveryStatus.inProgress:
                          deliveryColor = Colors.orange;
                          deliveryLabel = 'In Progress';
                        case DeliveryStatus.cancelled:
                          deliveryColor = Colors.grey;
                          deliveryLabel = 'Cancelled';
                        default:
                          deliveryColor = Colors.green;
                          deliveryLabel = 'Completed';
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${d.quantity} bottles × ${CurrencyFormatter.format(d.pricePerBottle)}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  _SmallBadge(
                                      label: statusLabel,
                                      color: statusColor),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.calendar_today_outlined,
                                        size: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        DateFormatter.format(d.deliveryDate),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      if (d.deliveryTime != null) ...[
                                        const SizedBox(width: 8),
                                        const Icon(
                                          Icons.access_time,
                                          size: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          d.deliveryTime!,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  _SmallBadge(
                                    label: deliveryLabel,
                                    color: deliveryColor,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Total: ${CurrencyFormatter.format(d.totalAmount)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (d.remainingBalance > 0)
                                    Flexible(
                                      child: Text(
                                        'Balance: ${CurrencyFormatter.format(d.remainingBalance)}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: statusColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.end,
                                      ),
                                    ),
                                ],
                              ),
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
              const SizedBox(height: 24),

              // ── PAYMENTS ────────────────────────────────────────────────
              _SectionHeader(
                title: 'Payments',
                count: paymentsAsync.whenOrNull(data: (p) => p.length),
                onViewAll: () => context.push(
                  '/customers/$customerId/history/payments',
                ),
              ),
              const SizedBox(height: 8),
              paymentsAsync.when(
                data: (payments) {
                  if (payments.isEmpty) {
                    return const EmptyStateWidget(
                      message: 'No payments yet',
                      icon: Icons.receipt_long_outlined,
                    );
                  }
                  return Column(
                    children: payments.map((p) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFE8F5E9),
                            child: Icon(
                              Icons.payments,
                              color: AppColors.success,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            CurrencyFormatter.format(p.amount),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(DateFormatter.format(p.paymentDate)),
                              if (p.notes != null)
                                Text(
                                  p.notes!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
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
              const SizedBox(height: 24),

              // ── BOTTLE TRANSACTIONS ──────────────────────────────────────
              _SectionHeader(
                title: 'Bottle Transactions',
                count: customerTransactions.isNotEmpty
                    ? customerTransactions.length
                    : null,
                onViewAll: () => context.push(
                  '/customers/$customerId/history/bottles',
                ),
              ),
              const SizedBox(height: 8),
              if (customerTransactions.isEmpty)
                const EmptyStateWidget(
                  message: 'No bottle transactions yet',
                  icon: Icons.inventory_2_outlined,
                )
              else
                Column(
                  children: customerTransactions.map((tx) {
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
                    return Card(
                      margin: const EdgeInsets.only(bottom: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: color.withValues(alpha: 0.12),
                          child: Icon(icon, color: color, size: 18),
                        ),
                        title: Text(
                          '${BottleTransaction.typeLabel(tx.transactionType)} — ${tx.quantity} bottles',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(DateFormatter.format(tx.date)),
                            if (tx.notes != null) Text(tx.notes!),
                          ],
                        ),
                        trailing: Text(
                          '${tx.quantity} btl',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: color,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 32),
            ],
          ),
          );
        },
        loading: () => const LoadingOverlay(),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _paymentBadge(double unpaidBalance, double totalPaid) {
    String label;
    Color color;
    if (unpaidBalance <= 0) {
      label = 'Paid';
      color = AppColors.paid;
    } else if (totalPaid > 0) {
      label = 'Partial';
      color = AppColors.partial;
    } else {
      label = 'Unpaid';
      color = AppColors.unpaid;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int? count;
  final VoidCallback? onViewAll;

  const _SectionHeader({
    required this.title,
    this.count,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (count != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
        const Spacer(),
        if (onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            child: const Text('View All'),
          ),
      ],
    );
  }
}

class _SmallBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _SmallBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _AnalyticsRow extends StatelessWidget {
  final String label;
  final String value;

  const _AnalyticsRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
