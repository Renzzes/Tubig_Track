import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/customer_bottle_ownership_utils.dart';
import '../../../../shared/widgets/history_filter_bar.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../../deliveries/domain/entities/delivery.dart';
import '../../../deliveries/presentation/providers/deliveries_provider.dart';
import '../../../inventory/domain/entities/customer_owned_bottle_log.dart';
import '../../../inventory/domain/entities/bottle_transaction.dart';
import '../../../inventory/presentation/providers/inventory_provider.dart';
import '../../../payments/domain/entities/payment.dart';
import '../../../payments/presentation/providers/payments_provider.dart';
import '../../../deposits/domain/entities/customer_deposit.dart';
import '../../../deposits/presentation/providers/deposits_provider.dart';
import '../../../customers/presentation/providers/customers_provider.dart';

enum CustomerHistoryType { deliveries, payments, bottleTransactions, deposits }

class CustomerHistoryScreen extends ConsumerStatefulWidget {
  final String customerId;
  final CustomerHistoryType type;

  const CustomerHistoryScreen({
    super.key,
    required this.customerId,
    required this.type,
  });

  @override
  ConsumerState<CustomerHistoryScreen> createState() =>
      _CustomerHistoryScreenState();
}

class _CustomerHistoryScreenState extends ConsumerState<CustomerHistoryScreen> {
  final _searchCtrl = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  static const _pageSize = 25;
  int _visibleCount = _pageSize;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String get _title {
    switch (widget.type) {
      case CustomerHistoryType.deliveries:
        return 'Delivery History';
      case CustomerHistoryType.payments:
        return 'Payment History';
      case CustomerHistoryType.bottleTransactions:
        return 'Bottle History';
      case CustomerHistoryType.deposits:
        return 'Deposit History';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: Column(
        children: [
          HistoryFilterBar(
            searchController: _searchCtrl,
            startDate: _startDate,
            endDate: _endDate,
            onDateFilterTap: () async {
              final (start, end) = await showDateRangePickerDialog(context);
              if (start != null) {
                setState(() {
                  _startDate = start;
                  _endDate = end;
                  _visibleCount = _pageSize;
                });
              }
            },
            onClearDates: () => setState(() {
              _startDate = null;
              _endDate = null;
              _visibleCount = _pageSize;
            }),
          ),
          Expanded(
            child: switch (widget.type) {
              CustomerHistoryType.deliveries => _buildDeliveries(),
              CustomerHistoryType.payments => _buildPayments(),
              CustomerHistoryType.bottleTransactions => _buildBottleTx(),
              CustomerHistoryType.deposits => _buildDeposits(),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveries() {
    final async = ref.watch(customerDeliveriesStreamProvider(widget.customerId));
    return async.when(
      data: (items) => _buildPagedList<Delivery>(
        items.where((d) {
          if (!isInDateRange(d.deliveryDate, _startDate, _endDate)) {
            return false;
          }
          final q = _searchCtrl.text.trim().toLowerCase();
          if (q.isEmpty) return true;
          return d.notes?.toLowerCase().contains(q) == true ||
              d.quantity.toString().contains(q);
        }).toList(),
        (d) => ListTile(
          title: Text('${d.quantity} bottles'),
          subtitle: Text(
            '${DateFormatter.format(d.deliveryDate)} • ${Delivery.paymentStatusToString(d.paymentStatus)}',
          ),
          trailing: Text(CurrencyFormatter.format(d.totalAmount)),
        ),
      ),
      loading: () => const LoadingOverlay(),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildPayments() {
    final async =
        ref.watch(customerPaymentsStreamProvider(widget.customerId));
    return async.when(
      data: (items) {
        final filtered = items.where((p) {
          if (!isInDateRange(p.paymentDate, _startDate, _endDate)) return false;
          final q = _searchCtrl.text.trim().toLowerCase();
          if (q.isEmpty) return true;
          return p.notes?.toLowerCase().contains(q) == true ||
              p.amount.toString().contains(q);
        }).toList();
        return _buildPagedList<Payment>(
          filtered,
          (p) => ListTile(
            title: Text(CurrencyFormatter.format(p.amount)),
            subtitle: Text(DateFormatter.formatDateTime(p.paymentDate)),
            trailing: p.notes != null ? Text(p.notes!) : null,
          ),
        );
      },
      loading: () => const LoadingOverlay(),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildBottleTx() {
    final async = ref.watch(bottleTransactionsStreamProvider);
    final logsAsync =
        ref.watch(customerOwnedLogsStreamProvider(widget.customerId));
    return async.when(
      data: (all) {
        final items =
            all.where((t) => t.customerId == widget.customerId).toList();
        final logs = logsAsync.when(
          data: (l) => l,
          loading: () => <CustomerOwnedBottleLog>[],
          error: (_, __) => <CustomerOwnedBottleLog>[],
        );
        final ledger = buildCustomerOwnershipLedger(
          transactions: items,
          logs: logs,
        ).where((entry) {
          if (!isInDateRange(entry.date, _startDate, _endDate)) {
            return false;
          }
          final q = _searchCtrl.text.trim().toLowerCase();
          if (q.isEmpty) return true;
          return entry.headline.toLowerCase().contains(q) ||
              ownershipLedgerSubtitle(entry).toLowerCase().contains(q) ||
              ownershipBalanceAfterLabel(entry).contains(q) ||
              (entry.notes?.toLowerCase().contains(q) ?? false);
        }).toList();

        if (ledger.isEmpty) {
          return const Center(child: Text('No records found'));
        }

        final visible = ledger.take(_visibleCount).toList();
        return NotificationListener<ScrollNotification>(
          onNotification: (n) {
            if (n is ScrollEndNotification &&
                n.metrics.pixels >= n.metrics.maxScrollExtent - 100 &&
                _visibleCount < ledger.length) {
              setState(() => _visibleCount += _pageSize);
            }
            return false;
          },
          child: ListView.builder(
            itemCount: visible.length,
            itemBuilder: (_, i) {
              final entry = visible[i];
              return ListTile(
                title: Text(entry.headline),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(DateFormatter.format(entry.date)),
                    if (entry.hasBusinessDelta || entry.hasCustomerOwnedDelta)
                      Text(ownershipLedgerSubtitle(entry)),
                    Text(
                      'Balance After: ${ownershipBalanceAfterLabel(entry)}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    if (entry.notes != null && entry.notes!.isNotEmpty)
                      Text(entry.notes!),
                  ],
                ),
              );
            },
          ),
        );
      },
      loading: () => const LoadingOverlay(),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildDeposits() {
    final async = ref.watch(customerDepositsStreamProvider(widget.customerId));
    return async.when(
      data: (items) => _buildPagedList<CustomerDeposit>(
        items.where((d) {
          if (!isInDateRange(d.createdAt, _startDate, _endDate)) return false;
          final q = _searchCtrl.text.trim().toLowerCase();
          if (q.isEmpty) return true;
          return CustomerDeposit.typeLabel(d.transactionType)
                  .toLowerCase()
                  .contains(q) ||
              d.amount.toString().contains(q) ||
              (d.notes?.toLowerCase().contains(q) ?? false);
        }).toList(),
        (d) => ListTile(
          title: Text(CustomerDeposit.typeLabel(d.transactionType)),
          subtitle: Text(
            '${DateFormatter.formatDateTime(d.createdAt)}${d.notes != null ? ' • ${d.notes}' : ''}',
          ),
          trailing: Text(
            CurrencyFormatter.format(d.amount),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: d.transactionType == DepositTransactionType.depositUsed
                  ? Colors.orange
                  : Colors.green,
            ),
          ),
        ),
      ),
      loading: () => const LoadingOverlay(),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildPagedList<T>(List<T> items, Widget Function(T) builder) {
    if (items.isEmpty) {
      return const Center(child: Text('No records found'));
    }
    final visible = items.take(_visibleCount).toList();
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n is ScrollEndNotification &&
            n.metrics.pixels >= n.metrics.maxScrollExtent - 100 &&
            _visibleCount < items.length) {
          setState(() => _visibleCount += _pageSize);
        }
        return false;
      },
      child: ListView.builder(
        itemCount: visible.length,
        itemBuilder: (_, i) => builder(visible[i]),
      ),
    );
  }
}

class InventoryHistoryScreen extends ConsumerStatefulWidget {
  const InventoryHistoryScreen({super.key});

  @override
  ConsumerState<InventoryHistoryScreen> createState() =>
      _InventoryHistoryScreenState();
}

class _InventoryHistoryScreenState extends ConsumerState<InventoryHistoryScreen> {
  final _searchCtrl = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  TransactionType? _typeFilter;
  static const _pageSize = 25;
  int _visibleCount = _pageSize;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final txsAsync = ref.watch(bottleTransactionsStreamProvider);
    final customersAsync = ref.watch(customersStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Inventory Timeline')),
      body: Column(
        children: [
          HistoryFilterBar(
            searchController: _searchCtrl,
            startDate: _startDate,
            endDate: _endDate,
            onDateFilterTap: () async {
              final (start, end) = await showDateRangePickerDialog(context);
              if (start != null) {
                setState(() {
                  _startDate = start;
                  _endDate = end;
                  _visibleCount = _pageSize;
                });
              }
            },
            onClearDates: () => setState(() {
              _startDate = null;
              _endDate = null;
              _visibleCount = _pageSize;
            }),
            typeFilter: PopupMenuButton<TransactionType?>(
              icon: const Icon(Icons.filter_list),
              onSelected: (v) => setState(() {
                _typeFilter = v;
                _visibleCount = _pageSize;
              }),
              itemBuilder: (_) => [
                const PopupMenuItem(value: null, child: Text('All Types')),
                ...TransactionType.values.map(
                  (t) => PopupMenuItem(
                    value: t,
                    child: Text(BottleTransaction.typeLabel(t)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: txsAsync.when(
              data: (txs) {
                final customerMap = customersAsync.value != null
                    ? {for (final c in customersAsync.value!) c.id: c.name}
                    : <String, String>{};

                final filtered = txs.where((t) {
                  if (_typeFilter != null && t.transactionType != _typeFilter) {
                    return false;
                  }
                  if (!isInDateRange(t.date, _startDate, _endDate)) {
                    return false;
                  }
                  final q = _searchCtrl.text.trim().toLowerCase();
                  if (q.isEmpty) return true;
                  final name = t.customerId != null
                      ? customerMap[t.customerId]
                      : null;
                  return BottleTransaction.typeLabel(t.transactionType)
                          .toLowerCase()
                          .contains(q) ||
                      (name?.toLowerCase().contains(q) ?? false) ||
                      t.quantity.toString().contains(q);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No records found'));
                }

                final visible = filtered.take(_visibleCount).toList();
                return NotificationListener<ScrollNotification>(
                  onNotification: (n) {
                    if (n is ScrollEndNotification &&
                        n.metrics.pixels >= n.metrics.maxScrollExtent - 100 &&
                        _visibleCount < filtered.length) {
                      setState(() => _visibleCount += _pageSize);
                    }
                    return false;
                  },
                  child: ListView.builder(
                    itemCount: visible.length,
                    itemBuilder: (_, i) {
                      final t = visible[i];
                      final name = t.customerId != null
                          ? customerMap[t.customerId]
                          : null;
                      return ListTile(
                        leading: Icon(_iconForType(t.transactionType)),
                        title: Text(
                          name ??
                              BottleTransaction.typeLabel(t.transactionType),
                        ),
                        subtitle: Text(
                          '${DateFormatter.formatDateTime(t.date)} • ${t.quantity} bottles',
                        ),
                        trailing: t.notes != null
                            ? Text(
                                t.notes!,
                                overflow: TextOverflow.ellipsis,
                              )
                            : null,
                      );
                    },
                  ),
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

  IconData _iconForType(TransactionType type) {
    switch (type) {
      case TransactionType.borrow:
        return Icons.arrow_upward;
      case TransactionType.ret:
        return Icons.arrow_downward;
      case TransactionType.purchase:
        return Icons.add_shopping_cart;
      case TransactionType.added:
        return Icons.add_circle_outline;
      case TransactionType.damaged:
        return Icons.broken_image_outlined;
      case TransactionType.missing:
        return Icons.help_outline;
      case TransactionType.donation:
        return Icons.volunteer_activism_outlined;
      case TransactionType.adjustment:
        return Icons.tune_outlined;
      case TransactionType.audit:
        return Icons.fact_check_outlined;
      case TransactionType.customerAdjustment:
        return Icons.edit_outlined;
    }
  }
}
