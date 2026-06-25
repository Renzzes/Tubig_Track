import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../../customers/presentation/providers/customers_provider.dart';

class UnpaidReceivablesScreen extends ConsumerWidget {
  const UnpaidReceivablesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receivablesAsync = ref.watch(customersWithUnpaidReceivablesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Unpaid Receivables')),
      body: receivablesAsync.when(
        data: (entries) {
          if (entries.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.check_circle_outline,
              message: 'No unpaid receivables',
              subMessage: 'All customers are fully paid on deliveries',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  onTap: () =>
                      context.push('/customers/${entry.customer.id}'),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.error.withValues(alpha: 0.12),
                    child: Text(
                      entry.customer.name.isNotEmpty
                          ? entry.customer.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                  title: Text(entry.customer.name),
                  subtitle: Text(
                    'Outstanding: ${CurrencyFormatter.format(entry.stats.unpaidBalance)}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                ),
              );
            },
          );
        },
        loading: () => const LoadingOverlay(),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
