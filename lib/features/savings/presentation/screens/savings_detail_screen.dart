import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../domain/entities/savings_goal.dart';
import '../providers/savings_goals_provider.dart';
import '../providers/savings_provider.dart';
import '../widgets/add_savings_sheet.dart';

class SavingsDetailScreen extends ConsumerWidget {
  const SavingsDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(savingsSummaryProvider);
    final insightsAsync = ref.watch(savingsInsightsProvider);
    final activeGoalAsync = ref.watch(activeSavingsGoalProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flag_outlined),
            tooltip: 'Goals',
            onPressed: () => context.push('/savings/goals'),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'History',
            onPressed: () => context.push('/savings/history'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const AddSavingsSheet(),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Savings'),
      ),
      body: summaryAsync.when(
        data: (summary) => ResponsiveContent(
          padding: EdgeInsets.all(context.pageHorizontalPadding),
          child: ListView(
            children: [
              Card(
                color: AppColors.primary.withValues(alpha: 0.08),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Text(
                        'Current Savings',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        CurrencyFormatter.format(summary.currentSavings),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              activeGoalAsync.when(
                data: (goal) {
                  if (goal == null) return const SizedBox.shrink();
                  final pct = goal.progressPercent(summary.currentSavings);
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Active Goal: ${goal.name}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              )),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(value: pct / 100),
                          const SizedBox(height: 8),
                          Text(
                            'Target: ${CurrencyFormatter.format(goal.targetAmount)} • Progress: ${pct.toStringAsFixed(0)}%',
                          ),
                        ],
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),
              insightsAsync.when(
                data: (insights) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Savings Insights',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 12),
                        _InsightRow(
                          'Average Monthly Savings',
                          CurrencyFormatter.format(insights.averageMonthlySavings),
                        ),
                        _InsightRow(
                          'Highest Monthly Savings',
                          CurrencyFormatter.format(insights.highestMonthlySavings),
                        ),
                        _InsightRow(
                          'Lowest Monthly Savings',
                          CurrencyFormatter.format(insights.lowestMonthlySavings),
                        ),
                        _InsightRow(
                          'Trend',
                          _trendLabel(insights.trend),
                        ),
                      ],
                    ),
                  ),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),
              Text('Breakdown', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _BreakdownTile(
                label: 'Delivery Profit',
                value: summary.deliveryProfit,
                isCredit: true,
              ),
              _BreakdownTile(
                label: 'Dispenser Profit',
                value: summary.dispenserProfit,
                isCredit: true,
              ),
              _BreakdownTile(
                label: 'Manual Savings Additions',
                value: summary.manualAdditions,
                isCredit: true,
              ),
              const Divider(height: 24),
              _BreakdownTile(
                label: 'Total Expenses',
                value: summary.totalExpenses,
                isCredit: false,
              ),
              _BreakdownTile(
                label: 'Maintenance Costs',
                value: summary.maintenanceCosts,
                isCredit: false,
                indent: true,
              ),
              _BreakdownTile(
                label: 'Other Operational Costs',
                value: summary.otherOperationalCosts,
                isCredit: false,
                indent: true,
              ),
              _BreakdownTile(
                label: 'Bottle Purchases',
                value: summary.bottlePurchases,
                isCredit: false,
              ),
            ],
          ),
        ),
        loading: () => const LoadingOverlay(),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  String _trendLabel(SavingsTrend trend) {
    switch (trend) {
      case SavingsTrend.increasing:
        return 'Increasing';
      case SavingsTrend.decreasing:
        return 'Decreasing';
      case SavingsTrend.stable:
        return 'Stable';
    }
  }
}

class _InsightRow extends StatelessWidget {
  final String label;
  final String value;

  const _InsightRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(color: Colors.grey[700]))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _BreakdownTile extends StatelessWidget {
  final String label;
  final double value;
  final bool isCredit;
  final bool indent;

  const _BreakdownTile({
    required this.label,
    required this.value,
    required this.isCredit,
    this.indent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: indent ? 16 : 0, bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: indent ? 13 : 14,
                color: indent ? Colors.grey[700] : null,
              ),
            ),
          ),
          Text(
            '${isCredit ? '+' : '-'}${CurrencyFormatter.format(value.abs())}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isCredit ? Colors.green[700] : Colors.red[700],
            ),
          ),
        ],
      ),
    );
  }
}
