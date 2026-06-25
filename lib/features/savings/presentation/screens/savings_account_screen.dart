import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../domain/entities/savings_entities.dart';
import '../providers/savings_provider.dart';
import '../widgets/savings_transfer_sheet.dart';

class SavingsAccountScreen extends ConsumerWidget {
  const SavingsAccountScreen({super.key});

  void _openTransferSheet(
    BuildContext context, {
    required SavingsTransferType type,
    required double maxAmount,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SavingsTransferSheet(type: type, maxAmount: maxAmount),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(savingsSummaryProvider);
    final transfersAsync = ref.watch(savingsTransferLedgerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings Account'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            tooltip: 'Cash Breakdown',
            onPressed: () => context.push('/cash/breakdown'),
          ),
        ],
      ),
      body: summaryAsync.when(
        data: (summary) => ResponsiveContent(
          padding: EdgeInsets.all(context.pageHorizontalPadding),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    Card(
                      color: AppColors.success.withValues(alpha: 0.08),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            const Text(
                              'Savings Account',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              CurrencyFormatter.format(
                                summary.savingsAccountBalance,
                              ),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: AppColors.success,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Money intentionally set aside',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
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
                            Icon(Icons.info_outline,
                                size: 18, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Transfers move money between business cash and savings. '
                                'Accumulated profit (${CurrencyFormatter.format(summary.accumulatedProfit)}) never changes.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Business Cash',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    CurrencyFormatter.format(
                                      summary.businessCash,
                                    ),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Accumulated Profit',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    CurrencyFormatter.format(
                                      summary.accumulatedProfit,
                                    ),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Transfer History',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    transfersAsync.when(
                      data: (transfers) {
                        if (transfers.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: EmptyStateWidget(
                              icon: Icons.history,
                              message: 'No transfers yet',
                              subMessage:
                                  'Use Transfer to Savings when you set money aside',
                            ),
                          );
                        }
                        return Column(
                          children: transfers.map((t) {
                            final isTransfer =
                                t.type == SavingsTransferType.transfer;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: (isTransfer
                                          ? AppColors.success
                                          : AppColors.primary)
                                      .withValues(alpha: 0.12),
                                  child: Icon(
                                    isTransfer
                                        ? Icons.arrow_downward
                                        : Icons.arrow_upward,
                                    color: isTransfer
                                        ? AppColors.success
                                        : AppColors.primary,
                                    size: 20,
                                  ),
                                ),
                                title: Text(t.type.label),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(DateFormatter.formatDateTime(t.date)),
                                    if (t.notes != null && t.notes!.isNotEmpty)
                                      Text(
                                        t.notes!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: Text(
                                  '${isTransfer ? '+' : '-'}${CurrencyFormatter.format(t.amount)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: isTransfer
                                        ? Colors.green[700]
                                        : Colors.orange[800],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                      loading: () => const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (e, _) => Text('Error: $e'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: summary.savingsAccountBalance > 0.001
                          ? () => _openTransferSheet(
                                context,
                                type: SavingsTransferType.withdraw,
                                maxAmount: summary.savingsAccountBalance,
                              )
                          : null,
                      icon: const Icon(Icons.arrow_upward, size: 18),
                      label: const Text('Withdraw'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: summary.businessCash > 0.001
                          ? () => _openTransferSheet(
                                context,
                                type: SavingsTransferType.transfer,
                                maxAmount: summary.businessCash,
                              )
                          : null,
                      icon: const Icon(Icons.savings_outlined, size: 18),
                      label: const Text('Transfer'),
                    ),
                  ),
                ],
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
