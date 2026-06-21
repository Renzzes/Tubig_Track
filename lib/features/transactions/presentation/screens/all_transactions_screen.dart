import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/history_filter_bar.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../domain/entities/recent_transaction.dart';
import '../providers/recent_transactions_provider.dart';
import '../widgets/recent_transactions_widget.dart';

class AllTransactionsScreen extends ConsumerStatefulWidget {
  const AllTransactionsScreen({super.key});

  @override
  ConsumerState<AllTransactionsScreen> createState() =>
      _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends ConsumerState<AllTransactionsScreen> {
  final _searchCtrl = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  RecentTransactionType? _typeFilter;
  static const _pageSize = 30;
  int _visibleCount = _pageSize;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  static String _typeLabel(RecentTransactionType type) {
    switch (type) {
      case RecentTransactionType.delivery:
        return 'Delivery';
      case RecentTransactionType.payment:
        return 'Payment';
      case RecentTransactionType.expense:
        return 'Expense';
      case RecentTransactionType.bottleBorrow:
        return 'Bottle Borrow';
      case RecentTransactionType.bottleReturn:
        return 'Bottle Return';
      case RecentTransactionType.bottlePurchase:
        return 'Purchase New Bottles';
      case RecentTransactionType.bottleDamaged:
        return 'Damaged Bottles';
      case RecentTransactionType.bottleMissing:
        return 'Missing Bottles';
      case RecentTransactionType.bottleDonation:
        return 'Donated Bottles';
      case RecentTransactionType.bottleAdjustment:
        return 'Inventory Adjustment';
      case RecentTransactionType.bottleAudit:
        return 'Inventory Audit';
      case RecentTransactionType.dispenserSale:
        return 'Dispenser Sale';
      case RecentTransactionType.walkInOperation:
        return 'Walk-In Operation';
      case RecentTransactionType.savingsAddition:
        return 'Savings Addition';
      case RecentTransactionType.supplyPurchase:
        return 'Supply Purchase';
      case RecentTransactionType.depositAdded:
        return 'Deposit Added';
      case RecentTransactionType.depositUsed:
        return 'Deposit Used';
      case RecentTransactionType.depositAdjustment:
        return 'Deposit Adjustment';
    }
  }

  List<RecentTransaction> _filter(List<RecentTransaction> all) {
    final query = _searchCtrl.text.trim().toLowerCase();
    return all.where((tx) {
      if (_typeFilter != null && tx.type != _typeFilter) return false;
      if (!isInDateRange(tx.date, _startDate, _endDate)) return false;
      if (query.isEmpty) return true;
      return tx.title.toLowerCase().contains(query) ||
          tx.typeLabel.toLowerCase().contains(query) ||
          (tx.subtitle?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final txsAsync = ref.watch(allTransactionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('All Transactions')),
      body: Column(
        children: [
          HistoryFilterBar(
            searchController: _searchCtrl,
            startDate: _startDate,
            endDate: _endDate,
            onDateFilterTap: () async {
              final (start, end) = await showDateRangePickerDialog(
                context,
                initialStart: _startDate,
                initialEnd: _endDate,
              );
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
            typeFilter: PopupMenuButton<RecentTransactionType?>(
              icon: const Icon(Icons.filter_list),
              tooltip: 'Type filter',
              onSelected: (v) => setState(() {
                _typeFilter = v;
                _visibleCount = _pageSize;
              }),
              itemBuilder: (_) => [
                const PopupMenuItem(value: null, child: Text('All Types')),
                ...RecentTransactionType.values.map(
                  (t) => PopupMenuItem(
                    value: t,
                    child: Text(_typeLabel(t)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: txsAsync.when(
              data: (all) {
                final filtered = _filter(all);
                if (filtered.isEmpty) {
                  return const Center(child: Text('No transactions found'));
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
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      RecentTransactionsWidget(
                        transactions: visible,
                        limit: visible.length,
                      ),
                      if (_visibleCount < filtered.length)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                    ],
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
}
