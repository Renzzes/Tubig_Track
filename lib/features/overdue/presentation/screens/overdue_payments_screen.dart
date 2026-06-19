import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../../deliveries/domain/repositories/delivery_repository.dart';
import '../providers/overdue_provider.dart';

class OverduePaymentsScreen extends ConsumerWidget {
  const OverduePaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(overdueAccountsProvider);
    final sort = ref.watch(overdueSortProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Overdue Payments')),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _SortChip(
                  label: 'Highest Balance',
                  selected: sort == OverdueSort.highestBalance,
                  onTap: () => ref
                      .read(overdueSortProvider.notifier)
                      .setSort(OverdueSort.highestBalance),
                ),
                _SortChip(
                  label: 'Oldest Debt',
                  selected: sort == OverdueSort.oldestDebt,
                  onTap: () => ref
                      .read(overdueSortProvider.notifier)
                      .setSort(OverdueSort.oldestDebt),
                ),
                _SortChip(
                  label: 'Newest Debt',
                  selected: sort == OverdueSort.newestDebt,
                  onTap: () => ref
                      .read(overdueSortProvider.notifier)
                      .setSort(OverdueSort.newestDebt),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: accountsAsync.when(
              data: (accounts) {
                if (accounts.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.check_circle_outline,
                    message: 'No overdue accounts',
                    subMessage: 'All customers are up to date',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: accounts.length,
                  itemBuilder: (context, index) {
                    final a = accounts[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        onTap: () =>
                            context.push('/customers/${a.customerId}'),
                        leading: CircleAvatar(
                          backgroundColor:
                              AppColors.error.withValues(alpha: 0.12),
                          child: Text(
                            a.customerName.isNotEmpty
                                ? a.customerName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(color: AppColors.error),
                          ),
                        ),
                        title: Text(
                          a.customerName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              CurrencyFormatter.format(a.balance),
                              style: const TextStyle(
                                color: AppColors.error,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (a.phone != null && a.phone!.isNotEmpty)
                              Text(a.phone!),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${a.daysOverdue}d',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.error,
                              ),
                            ),
                            const Text(
                              'overdue',
                              style: TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const LoadingOverlay(),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SortChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
      ),
    );
  }
}
