import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/history_filter_bar.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../domain/entities/supply_purchase.dart';
import '../providers/supply_purchase_provider.dart';

class SupplyPurchasesHistoryScreen extends ConsumerStatefulWidget {
  const SupplyPurchasesHistoryScreen({super.key});

  @override
  ConsumerState<SupplyPurchasesHistoryScreen> createState() =>
      _SupplyPurchasesHistoryScreenState();
}

class _SupplyPurchasesHistoryScreenState
    extends ConsumerState<SupplyPurchasesHistoryScreen> {
  final _searchCtrl = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String? _supplierFilter;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<SupplyPurchase> _filter(List<SupplyPurchase> all) {
    final query = _searchCtrl.text.trim().toLowerCase();
    return all.where((p) {
      if (_supplierFilter != null &&
          p.supplierName.toLowerCase() != _supplierFilter!.toLowerCase()) {
        return false;
      }
      if (!isInDateRange(p.purchaseDate, _startDate, _endDate)) return false;
      if (query.isEmpty) return true;
      return p.supplierName.toLowerCase().contains(query) ||
          p.itemType.toLowerCase().contains(query) ||
          p.description.toLowerCase().contains(query) ||
          (p.notes?.toLowerCase().contains(query) ?? false);
    }).toList()
      ..sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));
  }

  @override
  Widget build(BuildContext context) {
    final purchasesAsync = ref.watch(supplyPurchasesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Supply Purchases'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/inventory/purchase-stock'),
            tooltip: 'Purchase Stock',
          ),
        ],
      ),
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
                });
              }
            },
            onClearDates: () => setState(() {
              _startDate = null;
              _endDate = null;
            }),
            typeFilter: purchasesAsync.when(
              data: (all) {
                final suppliers = all
                    .map((p) => p.supplierName)
                    .toSet()
                    .toList()
                  ..sort();
                return PopupMenuButton<String?>(
                  icon: const Icon(Icons.filter_list),
                  tooltip: 'Supplier filter',
                  onSelected: (v) => setState(() => _supplierFilter = v),
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: null, child: Text('All Suppliers')),
                    ...suppliers.map(
                      (s) => PopupMenuItem(value: s, child: Text(s)),
                    ),
                  ],
                );
              },
              loading: () => null,
              error: (_, __) => null,
            ),
          ),
          Expanded(
            child: purchasesAsync.when(
              data: (all) {
                final filtered = _filter(all);
                if (filtered.isEmpty) {
                  return const Center(child: Text('No supply purchases found'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final p = filtered[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        onTap: () => context.push(
                          '/inventory/supply-purchases/${p.id}',
                        ),
                        leading: CircleAvatar(
                          backgroundColor:
                              AppColors.primary.withValues(alpha: 0.1),
                          child: const Icon(
                            Icons.inventory_2_outlined,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          p.description,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.supplierName),
                            Text(DateFormatter.format(p.purchaseDate)),
                            Text(
                              '${p.quantity} × ${CurrencyFormatter.format(p.unitCost)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        trailing: Text(
                          CurrencyFormatter.format(p.totalCost),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.error,
                          ),
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
