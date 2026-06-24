import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../providers/customers_provider.dart';
import '../utils/customer_statement_export.dart';
import '../widgets/customer_bottle_reconcile_dialog.dart';

/// Field-optimized hub for customer visits.
class CustomerVisitScreen extends ConsumerWidget {
  final String customerId;

  const CustomerVisitScreen({super.key, required this.customerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerAsync = ref.watch(customerByIdProvider(customerId));
    final statsAsync = ref.watch(customerStatsProvider(customerId));

    return Scaffold(
      appBar: AppBar(
        title: customerAsync.when(
          data: (c) => Text(c?.name ?? 'Customer Visit'),
          loading: () => const Text('Customer Visit'),
          error: (_, __) => const Text('Customer Visit'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Full Profile',
            onPressed: () => context.push('/customers/$customerId'),
          ),
        ],
      ),
      body: customerAsync.when(
        data: (customer) {
          if (customer == null) {
            return const Center(child: Text('Customer not found'));
          }
          return statsAsync.when(
            data: (stats) {
              return ResponsiveContent(
                padding: EdgeInsets.all(context.pageHorizontalPadding),
                child: ListView(
                  children: [
                    Text(
                      customer.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _VisitRow(
                              label: 'Business-Owned Bottles',
                              value: '${stats.bottlesHeld}',
                            ),
                            _VisitRow(
                              label: 'Customer-Owned Bottles',
                              value: '${stats.customerOwnedBottlesHeld}',
                            ),
                            _VisitRow(
                              label: 'Outstanding Balance',
                              value: CurrencyFormatter.format(stats.unpaidBalance),
                              highlight: stats.unpaidBalance > 0,
                            ),
                            _VisitRow(
                              label: 'Deposit Balance',
                              value: CurrencyFormatter.format(stats.depositBalance),
                            ),
                            _VisitRow(
                              label: 'Last Delivery',
                              value: stats.lastDeliveryDate != null
                                  ? DateFormatter.format(stats.lastDeliveryDate!)
                                  : 'None',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Actions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ActionButton(
                      icon: Icons.local_shipping_outlined,
                      label: 'Deliver Bottles',
                      onPressed: () => context.push(
                        '/deliveries/add',
                        extra: {'customerId': customerId},
                      ),
                    ),
                    _ActionButton(
                      icon: Icons.arrow_downward,
                      label: 'Collect Bottles',
                      onPressed: () => context.push(
                        '/customers/$customerId/collect-bottles',
                      ),
                    ),
                    _ActionButton(
                      icon: Icons.payments_outlined,
                      label: 'Receive Payment',
                      onPressed: () =>
                          context.push('/customers/$customerId/payment'),
                    ),
                    _ActionButton(
                      icon: Icons.inventory_2_outlined,
                      label: 'Check Bottle Count',
                      onPressed: () => CustomerBottleCountDialog.show(
                        context,
                        ref,
                        customerId: customerId,
                        businessOwnedHeld: stats.bottlesHeld,
                        customerOwnedHeld: stats.customerOwnedBottlesHeld,
                      ),
                    ),
                    _ActionButton(
                      icon: Icons.picture_as_pdf_outlined,
                      label: 'Print Statement',
                      onPressed: () => CustomerStatementExport.exportPdf(
                        context,
                        ref,
                        customerId,
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const LoadingOverlay(),
            error: (e, _) => Center(child: Text('Error: $e')),
          );
        },
        loading: () => const LoadingOverlay(),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _VisitRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _VisitRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: highlight ? AppColors.error : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(label),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
            alignment: Alignment.centerLeft,
          ),
        ),
      ),
    );
  }
}
