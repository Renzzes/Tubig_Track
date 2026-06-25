import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../providers/savings_goals_provider.dart';
import '../providers/savings_provider.dart';
import '../widgets/add_savings_sheet.dart';

class SavingsDetailScreen extends ConsumerWidget {
  const SavingsDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(savingsSummaryProvider);
    final activeGoalAsync = ref.watch(activeSavingsGoalProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accumulated Profit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            tooltip: 'Business Cash',
            onPressed: () => context.push('/cash/breakdown'),
          ),
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
          builder: (_) => const AddCapitalSheet(),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Capital'),
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
                        'Accumulated Profit',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        CurrencyFormatter.format(summary.accumulatedProfit),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Profit earned from deliveries, walk-ins, and dispensers',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                color: Colors.blueGrey.withValues(alpha: 0.06),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 18, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This is not money set aside in a savings account — it is profit your business has earned.',
                          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profit Breakdown',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      _BreakdownRow(
                        label: 'Delivery Profit',
                        value: summary.deliveryProfit,
                        isCredit: true,
                      ),
                      _BreakdownRow(
                        label: 'Walk-In Profit',
                        value: summary.walkInProfit,
                        isCredit: true,
                      ),
                      _BreakdownRow(
                        label: 'Dispenser Profit',
                        value: summary.dispenserProfit,
                        isCredit: true,
                      ),
                      _BreakdownRow(
                        label: 'Total Expenses',
                        value: summary.totalExpenses,
                        isCredit: false,
                      ),
                      const Divider(height: 20),
                      _BreakdownRow(
                        label: 'Accumulated Profit',
                        value: summary.accumulatedProfit,
                        isCredit: summary.accumulatedProfit >= 0,
                        bold: true,
                      ),
                    ],
                  ),
                ),
              ),
              if (summary.ownerCapital > 0) ...[
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.account_balance_outlined),
                    title: const Text('Owner Capital'),
                    subtitle: Text(
                      CurrencyFormatter.format(summary.ownerCapital),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/cash/breakdown'),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.savings_outlined),
                  title: const Text('Savings Account'),
                  subtitle: Text(
                    CurrencyFormatter.format(summary.savingsAccountBalance),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/savings/account'),
                ),
              ),
              const SizedBox(height: 16),
              activeGoalAsync.when(
                data: (goal) {
                  if (goal == null) return const SizedBox.shrink();
                  final pct = goal.progressPercent(summary.accumulatedProfit);
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
            ],
          ),
        ),
        loading: () => const LoadingOverlay(),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isCredit;
  final bool bold;

  const _BreakdownRow({
    required this.label,
    required this.value,
    required this.isCredit,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: bold ? 14 : 13,
                fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
                color: bold ? null : Colors.grey[700],
              ),
            ),
          ),
          Text(
            '${isCredit ? '+' : '-'}${CurrencyFormatter.format(value.abs())}',
            style: TextStyle(
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
              color: isCredit ? Colors.green[700] : Colors.red[700],
            ),
          ),
        ],
      ),
    );
  }
}
