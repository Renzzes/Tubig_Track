import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../../customers/domain/entities/customer.dart';
import '../../../customers/presentation/providers/customers_provider.dart';
import '../../../deposits/presentation/providers/deposits_provider.dart';

/// Customers with a positive deposit balance (Pundo).
final customersWithDepositsProvider =
    FutureProvider<List<({Customer customer, double balance})>>((ref) async {
  ref.watch(allCustomerDepositsStreamProvider);
  final customerRepo = ref.read(customerRepositoryProvider);
  final depositRepo = ref.read(customerDepositRepositoryProvider);
  final customers = await customerRepo.getAll();
  final results = <({Customer customer, double balance})>[];
  for (final customer in customers) {
    final balance = await depositRepo.getBalanceForCustomer(customer.id);
    if (balance > 0.001) {
      results.add((customer: customer, balance: balance));
    }
  }
  results.sort((a, b) => b.balance.compareTo(a.balance));
  return results;
});

class CustomerDepositsScreen extends ConsumerWidget {
  const CustomerDepositsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final depositsAsync = ref.watch(customersWithDepositsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Customer Deposits')),
      body: depositsAsync.when(
        data: (entries) {
          if (entries.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.savings_outlined,
              message: 'No customer deposits',
              subMessage: 'No customers currently have deposit balances',
            );
          }
          final totalHeld =
              entries.fold(0.0, (sum, e) => sum + e.balance);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: AppColors.primary.withValues(alpha: 0.08),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        'Current Deposits Held',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        CurrencyFormatter.format(totalHeld),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _SummaryChip(
                            label: 'Customers',
                            value: '${entries.length}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ...entries.map((entry) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    onTap: () =>
                        context.push('/customers/${entry.customer.id}'),
                    leading: CircleAvatar(
                      backgroundColor:
                          AppColors.primary.withValues(alpha: 0.12),
                      child: Text(
                        entry.customer.name.isNotEmpty
                            ? entry.customer.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(color: AppColors.primary),
                      ),
                    ),
                    title: Text(entry.customer.name),
                    subtitle: Text(
                      'Deposit: ${CurrencyFormatter.format(entry.balance)}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                );
              }),
            ],
          );
        },
        loading: () => const LoadingOverlay(),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
