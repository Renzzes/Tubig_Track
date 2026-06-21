import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/bottle_balance_utils.dart';
import '../../../../core/utils/bottle_variance_utils.dart';
import '../../../../core/utils/customer_status_utils.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../../deliveries/domain/entities/delivery.dart';
import '../../../deliveries/presentation/providers/deliveries_provider.dart';
import '../../../inventory/domain/entities/bottle_transaction.dart';
import '../../../inventory/presentation/providers/inventory_provider.dart';
import '../../../payments/presentation/providers/payments_provider.dart';
import '../../../deposits/domain/entities/customer_deposit.dart';
import '../../../deposits/presentation/providers/deposits_provider.dart';
import '../../domain/entities/customer.dart';
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
    final depositsAsync =
        ref.watch(customerDepositsStreamProvider(customerId));
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
                            _statusBadge(stats),
                          ],
                        ),
                        const SizedBox(height: 12),
                        CustomerStatsRow(stats: stats),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.savings_outlined,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Deposit Balance (Pundo)',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                    Text(
                                      CurrencyFormatter.format(
                                        stats.depositBalance,
                                      ),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 12),
                        Text(
                          'Customer Analytics',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        _AnalyticsRow(
                          label: 'Current Bottles Held',
                          value: '${stats.bottlesHeld} Bottles',
                        ),
                        _AnalyticsRow(
                          label: 'Total Delivered',
                          value: '${stats.borrowedBottles}',
                        ),
                        _AnalyticsRow(
                          label: 'Total Collected',
                          value: '${stats.returnedBottles}',
                        ),
                        _AnalyticsRow(
                          label: 'Outstanding Bottles',
                          value: '${stats.bottlesHeld}',
                        ),
                        _AnalyticsRow(
                          label: 'Deposit Balance',
                          value: CurrencyFormatter.format(stats.depositBalance),
                        ),
                        _AnalyticsRow(
                          label: 'Outstanding Balance',
                          value: CurrencyFormatter.format(stats.unpaidBalance),
                        ),
                        _AnalyticsRow(
                          label: 'Last Delivery Date',
                          value: stats.lastDeliveryDate != null
                              ? DateFormatter.format(stats.lastDeliveryDate!)
                              : 'None',
                        ),
                        _AnalyticsRow(
                          label: 'Lifetime Revenue',
                          value: CurrencyFormatter.format(stats.lifetimeRevenue),
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

              // Bottle Activity — lifecycle snapshot
              statsAsync.when(
                data: (stats) => deliveriesAsync.when(
                  data: (deliveries) {
                    final pending = deliveries
                        .where(
                          (d) =>
                              d.deliveryStatus == DeliveryStatus.scheduled ||
                              d.deliveryStatus == DeliveryStatus.inProgress,
                        )
                        .toList();
                    final pendingQty =
                        pending.fold<int>(0, (s, d) => s + d.quantity);
                    final inProgress = pending.any(
                      (d) => d.deliveryStatus == DeliveryStatus.inProgress,
                    );
                    final statusLabel = pending.isEmpty
                        ? 'None'
                        : inProgress
                            ? 'In Progress'
                            : 'Scheduled';

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bottle Activity',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 12),
                            _AnalyticsRow(
                              label: 'Current Held',
                              value: '${stats.bottlesHeld} Bottles',
                            ),
                            if (pending.isNotEmpty) ...[
                              _AnalyticsRow(
                                label: 'Pending Delivery',
                                value: '$pendingQty Bottles',
                              ),
                              _AnalyticsRow(
                                label: 'Delivery Status',
                                value: statusLabel,
                              ),
                            ],
                            _AnalyticsRow(
                              label: 'Collected',
                              value: '${stats.returnedBottles} Bottles',
                            ),
                            customerAsync.when(
                              data: (c) {
                                if (c == null) return const SizedBox();
                                final variance = c.bottleVariance(stats.bottlesHeld);
                                if (variance == null || variance == 0) {
                                  return const SizedBox();
                                }
                                final color =
                                    BottleVarianceUtils.colorFor(variance);
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: color.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Text(
                                      BottleVarianceUtils.listLabel(variance),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: color,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              loading: () => const SizedBox(),
                              error: (_, __) => const SizedBox(),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),
              const SizedBox(height: 16),

              // Bottle Management — primary bottle tracking hub
              statsAsync.when(
                data: (stats) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bottle Management',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.warning.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.inventory_2_outlined,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Current Bottles Held',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                    Text(
                                      '${stats.bottlesHeld} Bottles',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.warning,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => context.push(
                                  '/customers/$customerId/initial-balance',
                                ),
                                icon: Icon(
                                  stats.hasInitialBalance
                                      ? Icons.edit_outlined
                                      : Icons.playlist_add,
                                ),
                                label: Text(
                                  stats.hasInitialBalance
                                      ? 'Edit'
                                      : 'Set Initial Balance',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => context.push(
                                  '/customers/$customerId/adjust-bottles',
                                ),
                                icon: const Icon(Icons.tune_outlined),
                                label: const Text('Adjust Balance'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => context.push(
                              '/customers/$customerId/collect-bottles',
                            ),
                            icon: const Icon(Icons.arrow_downward),
                            label: const Text('Collect Bottles'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _showReconcileDialog(
                              context,
                              ref,
                              stats.bottlesHeld,
                            ),
                            icon: const Icon(Icons.balance_outlined),
                            label: const Text('Reconcile Bottles'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _AnalyticsRow(
                          label: 'Outstanding Bottles',
                          value: '${stats.bottlesHeld}',
                        ),
                        _AnalyticsRow(
                          label: 'Total Bottles Delivered',
                          value: '${stats.borrowedBottles}',
                        ),
                        _AnalyticsRow(
                          label: 'Total Bottles Collected',
                          value: '${stats.returnedBottles}',
                        ),
                      ],
                    ),
                  ),
                ),
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),
              const SizedBox(height: 16),

              // Bottle Ledger — timeline style
              _SectionHeader(
                title: 'Bottle Ledger',
                count: customerTransactions.isNotEmpty
                    ? buildCustomerBottleLedger(customerTransactions).length
                    : null,
                onViewAll: () => context.push(
                  '/customers/$customerId/history/bottles',
                ),
              ),
              const SizedBox(height: 8),
              if (customerTransactions.isEmpty)
                const EmptyStateWidget(
                  message: 'No bottle movements yet',
                  icon: Icons.inventory_2_outlined,
                )
              else
                _BottleLedgerTimeline(
                  entries: buildCustomerBottleLedger(customerTransactions)
                      .take(5)
                      .toList(),
                ),
              const SizedBox(height: 16),

              // Primary actions — delivery, collect, payment
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => context.push(
                            '/deliveries/add',
                            extra: {'customerId': customerId},
                          ),
                          icon: const Icon(Icons.local_shipping_outlined),
                          label: const Text('New Delivery'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(0, 48),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.push(
                            '/customers/$customerId/collect-bottles',
                          ),
                          icon: const Icon(Icons.arrow_downward),
                          label: const Text('Collect Bottles'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 48),
                          ),
                        ),
                      ),
                    ],
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

              // ── DEPOSIT HISTORY ───────────────────────────────────────────
              _SectionHeader(
                title: 'Deposit History',
                count: depositsAsync.whenOrNull(data: (d) => d.length),
                onViewAll: () => context.push(
                  '/customers/$customerId/history/deposits',
                ),
              ),
              const SizedBox(height: 8),
              depositsAsync.when(
                data: (deposits) {
                  if (deposits.isEmpty) {
                    return const EmptyStateWidget(
                      message: 'No deposit transactions yet',
                      icon: Icons.savings_outlined,
                    );
                  }
                  final preview = deposits.take(5).toList();
                  return Column(
                    children: preview.map((d) {
                      final color =
                          d.transactionType == DepositTransactionType.depositUsed
                              ? AppColors.warning
                              : AppColors.success;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: color.withValues(alpha: 0.12),
                            child: Icon(Icons.savings_outlined, color: color),
                          ),
                          title: Text(
                            CustomerDeposit.typeLabel(d.transactionType),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            DateFormatter.formatDateTime(d.createdAt),
                          ),
                          trailing: Text(
                            CurrencyFormatter.format(d.amount),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: color,
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

  void _showReconcileDialog(
    BuildContext context,
    WidgetRef ref,
    int expectedBottles,
  ) {
    final ctrl = TextEditingController(text: expectedBottles.toString());
    final reasonCtrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          final actual = int.tryParse(ctrl.text) ?? expectedBottles;
          final variance = actual - expectedBottles;
          final varianceColor = BottleVarianceUtils.colorFor(variance);
          final hasMissing = variance < 0;
          final hasExcess = variance > 0;

          return AlertDialog(
            title: const Text('Bottle Reconciliation'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ReconcileRow(
                    label: 'Expected Bottles',
                    value: '$expectedBottles',
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: ctrl,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Actual Count',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: reasonCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Reason (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (variance != 0) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: varianceColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: varianceColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ReconcileRow(
                            label: 'Variance',
                            value: variance > 0 ? '+$variance' : '$variance',
                            valueColor: varianceColor,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            hasMissing
                                ? '⚠ Missing Bottles: ${variance.abs()}'
                                : 'Excess Bottles: ${variance.abs()}',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: varianceColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else
                    const Text(
                      'Bottles match. No adjustment needed.',
                      style: TextStyle(color: AppColors.success),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              if (variance == 0)
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    try {
                      await ref
                          .read(inventoryRepositoryProvider)
                          .recordCustomerBottleReconciliation(
                            customerId: customerId,
                            expectedCount: expectedBottles,
                            actualCount: actual,
                            reason: reasonCtrl.text.trim().isEmpty
                                ? null
                                : reasonCtrl.text.trim(),
                            applyAdjustment: false,
                          );
                    } catch (_) {}
                  },
                  child: const Text('Log'),
                ),
              if (variance != 0) ...[
                OutlinedButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    try {
                      await ref
                          .read(inventoryRepositoryProvider)
                          .recordCustomerBottleReconciliation(
                            customerId: customerId,
                            expectedCount: expectedBottles,
                            actualCount: actual,
                            reason: reasonCtrl.text.trim().isEmpty
                                ? null
                                : reasonCtrl.text.trim(),
                            applyAdjustment: false,
                          );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Physical count recorded.'),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('Save Count'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    if (!context.mounted) return;
                    final confirmMsg = hasExcess
                        ? 'This customer has ${variance.abs()} excess bottles.\n\nApply correction?'
                        : 'This customer has ${variance.abs()} missing bottles.\n\nApply correction?';
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (c) => AlertDialog(
                        title: Text(
                          hasExcess ? 'Excess Bottles' : 'Missing Bottles',
                        ),
                        content: Text(confirmMsg),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(c, false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(c, true),
                            child: const Text('Confirm'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true && context.mounted) {
                      try {
                        await ref
                            .read(inventoryRepositoryProvider)
                            .recordCustomerBottleReconciliation(
                              customerId: customerId,
                              expectedCount: expectedBottles,
                              actualCount: actual,
                              reason: reasonCtrl.text.trim().isEmpty
                                  ? (hasMissing
                                      ? 'Customer Lost Bottles'
                                      : 'Excess Bottles')
                                  : reasonCtrl.text.trim(),
                              applyAdjustment: true,
                            );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                hasMissing
                                    ? 'Adjusted: ${variance.abs()} missing bottles recorded.'
                                    : 'Adjusted: ${variance.abs()} excess bottles recorded.',
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    }
                  },
                  child: const Text('Apply Correction'),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _statusBadge(CustomerStats stats) {
    final info = CustomerStatusUtils.infoFor(stats);
    final color = Color(info.colorValue);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        info.label,
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

/// Timeline-style bottle ledger shown on the customer profile.
class _BottleLedgerTimeline extends StatelessWidget {
  final List<CustomerBottleLedgerEntry> entries;

  const _BottleLedgerTimeline({required this.entries});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(entries.length, (i) {
        final entry = entries[i];
        final isLast = i == entries.length - 1;
        final isIncrease = entry.quantityDelta > 0;
        final dotColor = isIncrease ? AppColors.success : AppColors.warning;
        final deltaStr = isIncrease
            ? '+${entry.quantityDelta}'
            : '${entry.quantityDelta}';

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 28,
                child: Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: Colors.grey[200],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormatter.format(entry.transaction.date),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              ledgerHeadline(entry),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Text(
                            deltaStr,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: dotColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Balance: ${entry.balanceAfter}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _ReconcileRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _ReconcileRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
