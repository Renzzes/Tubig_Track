import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/business_timeline_utils.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../../customers/presentation/providers/customers_provider.dart';
import '../../../deposits/domain/entities/customer_deposit.dart';
import '../../../deposits/presentation/providers/deposits_provider.dart';
import '../../../deliveries/domain/entities/delivery.dart';
import '../../../deliveries/presentation/providers/deliveries_provider.dart';
import '../../../payments/presentation/providers/payments_provider.dart';
import '../../../supply_purchases/presentation/providers/supply_purchase_provider.dart';
import '../../domain/entities/customer_bottle_reconciliation.dart';
import '../providers/inventory_provider.dart';
import '../../../walk_in_operations/domain/entities/walk_in_sale.dart';
import '../../../walk_in_operations/presentation/providers/walk_in_provider.dart';

class BusinessTimelineScreen extends ConsumerStatefulWidget {
  const BusinessTimelineScreen({super.key});

  @override
  ConsumerState<BusinessTimelineScreen> createState() =>
      _BusinessTimelineScreenState();
}

class _BusinessTimelineScreenState extends ConsumerState<BusinessTimelineScreen> {
  BusinessTimelineFilter _filter = BusinessTimelineFilter.all;

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(bottleTransactionsStreamProvider);
    final supplyAsync = ref.watch(supplyPurchasesStreamProvider);
    final deliveriesAsync = ref.watch(deliveriesStreamProvider);
    final paymentsAsync = ref.watch(paymentsStreamProvider);
    final depositsAsync = ref.watch(allCustomerDepositsStreamProvider);
    final customersAsync = ref.watch(customersStreamProvider);
    final reconciliationsAsync = ref.watch(bottleReconciliationsStreamProvider);
    final walkInAsync = ref.watch(walkInSalesStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Business Timeline')),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: BusinessTimelineFilter.values.map((f) {
                final selected = _filter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(_filterLabel(f)),
                    selected: selected,
                    onSelected: (_) => setState(() => _filter = f),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: transactionsAsync.when(
              data: (transactions) => supplyAsync.when(
                data: (purchases) => deliveriesAsync.when(
                  data: (deliveries) => paymentsAsync.when(
                    data: (payments) => depositsAsync.when(
                      data: (deposits) {
                        final reconciliations = reconciliationsAsync.when(
                          data: (r) => r,
                          loading: () => <CustomerBottleReconciliation>[],
                          error: (_, __) => <CustomerBottleReconciliation>[],
                        );
                        final customerMap = customersAsync.when(
                          data: (c) => {for (final x in c) x.id: x.name},
                          loading: () => <String, String>{},
                          error: (_, __) => <String, String>{},
                        );
                        final walkInSales = walkInAsync.when(
                          data: (s) => s,
                          loading: () => <WalkInSale>[],
                          error: (_, __) => <WalkInSale>[],
                        );
                        final linkedIds = purchases
                            .map((p) => p.bottleTransactionId)
                            .whereType<String>()
                            .toSet();
                        final all = buildBusinessTimeline(
                          transactions: transactions,
                          supplyPurchases: purchases,
                          supplyLinkedTxIds: linkedIds,
                          customerNames: customerMap,
                          deliveries: deliveries
                              .where(
                                (d) =>
                                    d.deliveryStatus ==
                                    DeliveryStatus.completed,
                              )
                              .map(
                                (d) => (
                                  id: d.id,
                                  customerId: d.customerId,
                                  quantity: d.quantity,
                                  date: d.deliveryDate,
                                ),
                              )
                              .toList(),
                          payments: payments
                              .map(
                                (p) => (
                                  amount: p.amount,
                                  date: p.paymentDate,
                                  customerName: customerMap[p.customerId],
                                ),
                              )
                              .toList(),
                          deposits: deposits
                              .map(
                                (d) => (
                                  label: _depositLabel(d),
                                  amount: d.amount,
                                  date: d.createdAt,
                                  customerName: customerMap[d.customerId],
                                ),
                              )
                              .toList(),
                          reconciliations: reconciliations,
                          walkInSales: walkInSales,
                        );
                        final filtered =
                            filterBusinessTimeline(all, _filter);
                        if (filtered.isEmpty) {
                          return const EmptyStateWidget(
                            message: 'No activity found',
                            icon: Icons.timeline,
                          );
                        }
                        return ListView.builder(
                          padding: EdgeInsets.all(
                            context.pageHorizontalPadding,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (_, i) {
                            final entry = filtered[i];
                            final dateKey =
                                businessTimelineDateKey(entry.date);
                            final showDateHeader = i == 0 ||
                                businessTimelineDateKey(
                                      filtered[i - 1].date,
                                    ) !=
                                    dateKey;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (showDateHeader)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 12,
                                      bottom: 6,
                                    ),
                                    child: Text(
                                      dateKey,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                Card(
                                  margin: const EdgeInsets.only(bottom: 6),
                                  child: ListTile(
                                    title: Text(
                                      entry.headline,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (entry.subtitle != null)
                                          Text(entry.subtitle!),
                                        Text(
                                          DateFormatter.format(entry.date),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      loading: () => const LoadingOverlay(),
                      error: (e, _) => Center(child: Text('Error: $e')),
                    ),
                    loading: () => const LoadingOverlay(),
                    error: (e, _) => Center(child: Text('Error: $e')),
                  ),
                  loading: () => const LoadingOverlay(),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
                loading: () => const LoadingOverlay(),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
              loading: () => const LoadingOverlay(),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  String _filterLabel(BusinessTimelineFilter f) => switch (f) {
        BusinessTimelineFilter.all => 'All',
        BusinessTimelineFilter.deliveries => 'Deliveries',
        BusinessTimelineFilter.collections => 'Collections',
        BusinessTimelineFilter.payments => 'Payments',
        BusinessTimelineFilter.inventory => 'Inventory',
        BusinessTimelineFilter.suppliers => 'Suppliers',
        BusinessTimelineFilter.audits => 'Audits',
        BusinessTimelineFilter.reconciliations => 'Reconciliations',
        BusinessTimelineFilter.walkInOperations => 'Walk-In',
      };

  String _depositLabel(CustomerDeposit d) {
    return '${CustomerDeposit.typeLabel(d.transactionType)} '
        '${CurrencyFormatter.format(d.amount)}';
  }
}
