import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../providers/inventory_provider.dart';

class CustomerBottleBalancesScreen extends ConsumerWidget {
  const CustomerBottleBalancesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balancesAsync = ref.watch(customerBottleBalancesProvider);
    final summaryAsync = ref.watch(inventorySummaryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Customers Holding Bottles')),
      body: balancesAsync.when(
        data: (balances) {
          final total = summaryAsync.value?.bottlesWithCustomers ?? 0;
          final sumHeld =
              balances.fold<int>(0, (s, b) => s + b.bottlesHeld);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customers Holding Bottles',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$total Bottles',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.warning,
                        ),
                      ),
                      if (sumHeld != total && total > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Customer sum: $sumHeld (check for corrections)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange[800],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (balances.isEmpty)
                const EmptyStateWidget(
                  message: 'No bottles currently with customers',
                  icon: Icons.people_outline,
                )
              else
                ...balances.map(
                  (b) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            AppColors.warning.withValues(alpha: 0.12),
                        child: Text(
                          b.customerName.isNotEmpty
                              ? b.customerName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(color: AppColors.warning),
                        ),
                      ),
                      title: Text(
                        b.customerName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${b.bottlesHeld} bottles held',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          if (b.lastDeliveryDate != null)
                            Text(
                              'Last delivery: '
                              '${DateFormatter.format(b.lastDeliveryDate!)}',
                            ),
                          if (b.unpaidBalance > 0)
                            Text(
                              'Outstanding: '
                              '${CurrencyFormatter.format(b.unpaidBalance)}',
                              style: const TextStyle(color: AppColors.error),
                            ),
                        ],
                      ),
                      trailing: Text(
                        '${b.bottlesHeld}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.warning,
                            ),
                      ),
                      onTap: () => context.push('/customers/${b.customerId}'),
                    ),
                  ),
                ),
              if (balances.isNotEmpty) ...[
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Customers Holding Bottles: ${balances.length}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Total Bottles: $sumHeld',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          );
        },
        loading: () => const LoadingOverlay(),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
