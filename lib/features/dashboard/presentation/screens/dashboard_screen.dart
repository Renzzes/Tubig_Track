import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../../transactions/presentation/providers/recent_transactions_provider.dart';
import '../../../transactions/presentation/widgets/recent_transactions_widget.dart';
import '../../../savings/presentation/providers/savings_provider.dart';
import '../../../savings/presentation/providers/savings_goals_provider.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/summary_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final transactionsAsync = ref.watch(recentTransactionsProvider);
    final savingsAsync = ref.watch(savingsSummaryProvider);
    final lowStockAsync = ref.watch(lowStockItemsProvider);
    final activeGoalAsync = ref.watch(activeSavingsGoalProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('TubigTrack'),
            Text(
              DateFormatter.format(DateTime.now()),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardSummaryProvider);
        },
        child: summaryAsync.when(
          data: (summary) => ResponsiveContent(
            padding: EdgeInsets.all(context.pageHorizontalPadding),
            child: ListView(
            children: [
              _QuickActions(context: context),
              const SizedBox(height: 20),

              // Today's summary header
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Today's Summary",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/reports'),
                    child: const Text('View Reports'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              ResponsiveStatGrid(
                children: [
                  SummaryCard(
                    title: "Today's Deliveries",
                    value: '${summary.todayDeliveriesCount}',
                    icon: Icons.local_shipping_outlined,
                    color: AppColors.primary,
                    subtitle: 'deliveries today',
                    onTap: () => context.go('/deliveries'),
                  ),
                  SummaryCard(
                    title: "Today's Sales",
                    value: CurrencyFormatter.format(summary.todaySales),
                    icon: Icons.trending_up,
                    color: AppColors.success,
                    subtitle: 'Delivery + Dispenser',
                    onTap: () => context.go('/deliveries'),
                  ),
                  SummaryCard(
                    title: 'Available Bottles',
                    value: '${summary.availableBottles}',
                    icon: Icons.inventory_2_outlined,
                    color: AppColors.primary,
                    onTap: () => context.go('/inventory'),
                  ),
                  SummaryCard(
                    title: 'Borrowed Bottles',
                    value: '${summary.borrowedBottles}',
                    icon: Icons.people_outline,
                    color: AppColors.warning,
                    subtitle: 'with customers',
                    onTap: () => context.go('/inventory'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              lowStockAsync.when(
                data: (items) {
                  if (items.isEmpty) return const SizedBox.shrink();
                  final labels = items
                      .map((i) => '${i.label}: ${i.remaining}')
                      .join(' • ');
                  return Column(
                    children: [
                      SummaryCard(
                        title: 'Low Stock Warning',
                        value: '${items.length} item${items.length > 1 ? 's' : ''}',
                        icon: Icons.warning_amber_rounded,
                        color: AppColors.error,
                        subtitle: labels,
                        onTap: () => context.go('/inventory'),
                      ),
                      const SizedBox(height: 12),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              savingsAsync.when(
                data: (savings) => SummaryCard(
                  title: 'Savings',
                  value: CurrencyFormatter.format(savings.currentSavings),
                  icon: Icons.savings_outlined,
                  color: AppColors.success,
                  subtitle: savings.manualAdditions > 0
                      ? 'Manual Additions: ${CurrencyFormatter.format(savings.manualAdditions)}'
                      : 'Tap for details',
                  onTap: () => context.push('/savings'),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 12),

              activeGoalAsync.when(
                data: (goal) {
                  if (goal == null) return const SizedBox.shrink();
                  final current = savingsAsync.value?.currentSavings ?? 0;
                  final pct = goal.progressPercent(current);
                  return Column(
                    children: [
                      SummaryCard(
                        title: 'Savings Goal: ${goal.name}',
                        value: '${pct.toStringAsFixed(0)}%',
                        icon: Icons.flag_outlined,
                        color: AppColors.primary,
                        subtitle:
                            '${CurrencyFormatter.format(current)} / ${CurrencyFormatter.format(goal.targetAmount)}',
                        onTap: () => context.push('/savings/goals'),
                      ),
                      const SizedBox(height: 12),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              // Unpaid Receivables — full width
              SummaryCard(
                title: 'Unpaid Receivables',
                value: CurrencyFormatter.format(summary.unpaidReceivables),
                icon: Icons.account_balance_wallet_outlined,
                color: summary.unpaidReceivables > 0
                    ? AppColors.error
                    : AppColors.success,
                subtitle: summary.unpaidReceivables > 0
                    ? 'Tap to view customers'
                    : 'All payments received!',
                onTap: () => context.go('/customers'),
              ),
              const SizedBox(height: 12),

              SummaryCard(
                title: 'Overdue Payments',
                value: '${summary.overdueCustomerCount}',
                icon: Icons.warning_amber_rounded,
                color: summary.overdueCustomerCount > 0
                    ? AppColors.error
                    : AppColors.success,
                subtitle: summary.overdueCustomerCount > 0
                    ? 'Total: ${CurrencyFormatter.format(summary.overdueTotalAmount)} • Tap to view'
                    : 'No overdue accounts',
                onTap: () => context.push('/overdue'),
              ),
              const SizedBox(height: 24),

              // Upcoming Deliveries section
              if (summary.upcomingDeliveries.isNotEmpty) ...[
                const Text(
                  'Upcoming Deliveries',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                _UpcomingDeliveriesCard(items: summary.upcomingDeliveries),
                const SizedBox(height: 24),
              ],

              // Recent transactions
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Recent Transactions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/transactions/all'),
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: transactionsAsync.when(
                    data: (txs) => RecentTransactionsWidget(
                      transactions: txs,
                      limit: 10,
                    ),
                    loading: () => const LoadingOverlay(),
                    error: (e, _) => Text('Error: $e'),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Dispenser sales link
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey[200]!),
                ),
                tileColor: Colors.white,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.local_drink,
                    color: AppColors.primary,
                  ),
                ),
                title: const Text('Dispenser Sales'),
                subtitle: const Text('Record walk-in cash sales'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () => context.push('/dispenser-sales'),
              ),
              const SizedBox(height: 16),
            ],
          ),
          ),
          loading: () => const LoadingOverlay(),
          error: (e, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text('Error: $e'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(dashboardSummaryProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final BuildContext context;

  const _QuickActions({required this.context});

  @override
  Widget build(BuildContext _) {
    final buttonStyle = ElevatedButton.styleFrom(
      minimumSize: const Size(0, 48),
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
    final outlinedStyle = OutlinedButton.styleFrom(
      minimumSize: const Size(0, 48),
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final useSingleColumn = constraints.maxWidth < 360;

        if (useSingleColumn) {
          return Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/deliveries/add'),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New Delivery'),
                  style: buttonStyle,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/expenses'),
                  icon: const Icon(Icons.receipt_outlined, size: 18),
                  label: const Text('Add Expense'),
                  style: outlinedStyle,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/dispenser-sales'),
                  icon: const Icon(Icons.local_drink_outlined, size: 18),
                  label: const Text('Dispenser Sale'),
                  style: outlinedStyle,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/customers'),
                  icon: const Icon(Icons.people_outline, size: 18),
                  label: const Text('Customers'),
                  style: outlinedStyle,
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.push('/deliveries/add'),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('New Delivery'),
                    style: buttonStyle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/expenses'),
                    icon: const Icon(Icons.receipt_outlined, size: 18),
                    label: const Text('Add Expense'),
                    style: outlinedStyle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/dispenser-sales'),
                    icon: const Icon(Icons.local_drink_outlined, size: 18),
                    label: const Text('Dispenser Sale'),
                    style: outlinedStyle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.go('/customers'),
                    icon: const Icon(Icons.people_outline, size: 18),
                    label: const Text('Customers'),
                    style: outlinedStyle,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _UpcomingDeliveriesCard extends StatelessWidget {
  final List<UpcomingDeliveryItem> items;

  const _UpcomingDeliveriesCard({required this.items});

  String _dateLabel(DateTime date) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final d = DateTime(date.year, date.month, date.day);
    if (d == DateTime(tomorrow.year, tomorrow.month, tomorrow.day)) {
      return 'Tomorrow';
    }
    return DateFormat('MMMM d').format(date);
  }

  @override
  Widget build(BuildContext context) {
    // Group by date label
    final Map<String, List<UpcomingDeliveryItem>> grouped = {};
    for (final item in items) {
      final label = _dateLabel(item.deliveryDate);
      grouped.putIfAbsent(label, () => []).add(item);
    }

    final dateKeys = grouped.keys.toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: grouped.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    entry.key,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                ...entry.value.map((item) => Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF1976D2),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.customerName,
                              style: const TextStyle(fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (item.deliveryTime != null) ...[
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                item.deliveryTime!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                          const SizedBox(width: 4),
                          Text(
                            '${item.quantity} btl',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )),
                if (entry.key != dateKeys.last) const Divider(height: 12),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
