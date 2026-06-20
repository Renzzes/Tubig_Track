import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../providers/savings_provider.dart';
import '../widgets/add_savings_sheet.dart';

class SavingsDetailScreen extends ConsumerWidget {
  const SavingsDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(savingsSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings'),
        actions: [
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
              Text(
                'Breakdown',
                style: Theme.of(context).textTheme.titleMedium,
              ),
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
