import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../providers/business_cash_provider.dart';

class BusinessCashBreakdownScreen extends ConsumerWidget {
  const BusinessCashBreakdownScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final breakdownAsync = ref.watch(businessCashBreakdownProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Cash Breakdown')),
      body: breakdownAsync.when(
        data: (b) => ResponsiveContent(
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
                        'Business Cash',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        CurrencyFormatter.format(b.businessCash),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Operating cash (not in savings account)',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Where the money is', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _CashRow(
                label: 'Accumulated Profit',
                value: b.accumulatedProfit,
                subtitle: 'Profit earned — never changes on transfer',
                onTap: () => context.push('/savings'),
              ),
              _CashRow(
                label: 'Owner Capital',
                value: b.ownerCapital,
                subtitle: 'Investments and startup capital',
                isAdd: true,
              ),
              _CashRow(
                label: 'Savings Account',
                value: b.savingsAccountBalance,
                subtitle: 'Money set aside in savings',
                isDeduction: b.savingsAccountBalance > 0,
                onTap: () => context.push('/savings/account'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Total Business Money',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(b.totalBusinessMoney),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const Divider(height: 24),
              Text('Other', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _CashRow(
                label: 'Customer Deposits',
                value: b.customerDepositsHeld,
                subtitle: 'Held for customers (liability)',
                isDeduction: true,
                onTap: b.customerDepositsHeld > 0
                    ? () => context.push('/deposits/customers')
                    : null,
              ),
              _CashRow(
                label: 'Outstanding Receivables',
                value: b.unpaidReceivables,
                subtitle: 'Money customers still owe you',
                onTap: b.unpaidReceivables > 0
                    ? () => context.push('/receivables/unpaid')
                    : null,
              ),
              const SizedBox(height: 16),
              Card(
                color: AppColors.success.withValues(alpha: 0.08),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Cash Available',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Business cash after customer deposit liability',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(b.cashAvailable),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
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

class _CashRow extends StatelessWidget {
  final String label;
  final double value;
  final String? subtitle;
  final bool isAdd;
  final bool isDeduction;
  final VoidCallback? onTap;

  const _CashRow({
    required this.label,
    required this.value,
    this.subtitle,
    this.isAdd = false,
    this.isDeduction = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final prefix = isDeduction ? '−' : (isAdd ? '+' : '');
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        title: Text(label),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$prefix${CurrencyFormatter.format(value.abs())}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDeduction
                    ? Colors.orange[800]
                    : (isAdd ? Colors.green[700] : null),
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
            ],
          ],
        ),
      ),
    );
  }
}
