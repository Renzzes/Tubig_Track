import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
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
      appBar: AppBar(title: const Text('Customer Bottle Balances')),
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
                        'Bottles With Customers',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$total bottles across ${balances.length} customers',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (sumHeld != total && total > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Ledger total: $sumHeld',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
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
                      trailing: Text(
                        '${b.bottlesHeld}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.warning,
                        ),
                      ),
                      onTap: () => context.push('/customers/${b.customerId}'),
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => const LoadingOverlay(),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
