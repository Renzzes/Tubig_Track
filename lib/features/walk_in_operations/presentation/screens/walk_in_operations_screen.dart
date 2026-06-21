import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../../customers/presentation/providers/customers_provider.dart';
import '../../domain/entities/walk_in_sale.dart';
import '../providers/walk_in_provider.dart';

class WalkInOperationsScreen extends ConsumerStatefulWidget {
  const WalkInOperationsScreen({super.key});

  @override
  ConsumerState<WalkInOperationsScreen> createState() =>
      _WalkInOperationsScreenState();
}

class _WalkInOperationsScreenState
    extends ConsumerState<WalkInOperationsScreen> {
  @override
  Widget build(BuildContext context) {
    final salesAsync = ref.watch(walkInSalesStreamProvider);
    final customersAsync = ref.watch(customersStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Walk-In Operations')),
      body: salesAsync.when(
        data: (sales) {
          if (sales.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.storefront_outlined,
              message: 'No walk-in operations recorded',
              subMessage: 'Tap + to record a borrow or refill',
            );
          }

          final totalRevenue =
              sales.fold(0.0, (sum, s) => sum + s.totalAmount);
          final customerMap = customersAsync.when(
            data: (c) => {for (final x in c) x.id: x.name},
            loading: () => <String, String>{},
            error: (_, __) => <String, String>{},
          );

          return Column(
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${sales.length} operation${sales.length > 1 ? 's' : ''}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      CurrencyFormatter.format(totalRevenue),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.only(
                    bottom: context.fabListBottomPadding,
                  ),
                  itemCount: sales.length,
                  itemBuilder: (context, index) {
                    final sale = sales[index];
                    final customerName = sale.customerId != null
                        ? (customerMap[sale.customerId] ??
                            WalkInSale.walkInCustomerLabel)
                        : WalkInSale.walkInCustomerLabel;
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              AppColors.success.withValues(alpha: 0.12),
                          child: Icon(
                            _iconForType(sale.walkInType),
                            color: AppColors.success,
                          ),
                        ),
                        title: Text(
                          sale.walkInType.label,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(customerName),
                            Text(sale.quantityDescription),
                            Text(DateFormatter.formatDateTime(sale.date)),
                          ],
                        ),
                        trailing: Text(
                          CurrencyFormatter.format(sale.totalAmount),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        onLongPress: () async {
                          final confirmed = await showConfirmDialog(
                            context,
                            title: 'Delete Walk-In',
                            message:
                                'Delete this walk-in operation and reverse inventory changes?',
                            confirmText: 'Delete',
                          );
                          if (confirmed == true) {
                            await ref
                                .read(walkInRepositoryProvider)
                                .deleteWalkIn(sale.id);
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const LoadingOverlay(),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('New Walk-In'),
      ),
    );
  }

  IconData _iconForType(WalkInType type) => switch (type) {
        WalkInType.businessBottles => Icons.inventory_2_outlined,
        WalkInType.customerRefill => Icons.local_drink_outlined,
        WalkInType.exchange => Icons.swap_horiz,
      };

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddWalkInSheet(),
    );
  }
}

class _AddWalkInSheet extends ConsumerStatefulWidget {
  const _AddWalkInSheet();

  @override
  ConsumerState<_AddWalkInSheet> createState() => _AddWalkInSheetState();
}

class _AddWalkInSheetState extends ConsumerState<_AddWalkInSheet> {
  final _formKey = GlobalKey<FormState>();
  WalkInType _type = WalkInType.businessBottles;
  String? _customerId;
  final _businessQtyCtrl = TextEditingController(text: '1');
  final _customerQtyCtrl = TextEditingController(text: '1');
  final _returnedQtyCtrl = TextEditingController(text: '1');
  final _priceCtrl = TextEditingController(
    text: AppConstants.defaultPricePerBottle.toStringAsFixed(0),
  );
  final _notesCtrl = TextEditingController();
  String _paymentMethod = 'Cash';
  bool _isLoading = false;

  @override
  void dispose() {
    _businessQtyCtrl.dispose();
    _customerQtyCtrl.dispose();
    _returnedQtyCtrl.dispose();
    _priceCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  int get _quantity {
    switch (_type) {
      case WalkInType.businessBottles:
        return int.tryParse(_businessQtyCtrl.text) ?? 0;
      case WalkInType.customerRefill:
        return int.tryParse(_customerQtyCtrl.text) ?? 0;
      case WalkInType.exchange:
        return int.tryParse(_businessQtyCtrl.text) ?? 0;
    }
  }

  double get _total {
    final price = double.tryParse(_priceCtrl.text) ?? 0;
    return _quantity * price;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final now = DateTime.now();
    final price = double.parse(_priceCtrl.text.trim());
    final businessQty = int.tryParse(_businessQtyCtrl.text) ?? 0;
    final customerQty = int.tryParse(_customerQtyCtrl.text) ?? 0;
    final returnedQty = int.tryParse(_returnedQtyCtrl.text) ?? 0;

    final sale = WalkInSale(
      id: const Uuid().v4(),
      customerId: _customerId,
      walkInType: _type,
      businessOwnedQuantity: _type == WalkInType.customerRefill
          ? 0
          : businessQty,
      customerOwnedQuantity:
          _type == WalkInType.customerRefill ? customerQty : 0,
      returnedEmptyQuantity:
          _type == WalkInType.exchange ? returnedQty : 0,
      pricePerBottle: price,
      totalAmount: _total,
      paymentMethod: _paymentMethod,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      date: now,
      createdAt: now,
      updatedAt: now,
    );

    try {
      await ref.read(walkInRepositoryProvider).recordWalkIn(sale);
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Walk-in operation recorded!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersStreamProvider);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'New Walk-In',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Paid immediately — no schedules or unpaid balances.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Select Type',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  RadioListTile<WalkInType>(
                    title: const Text('Borrow Bottle'),
                    subtitle: Text(WalkInType.businessBottles.subtitle),
                    value: WalkInType.businessBottles,
                    groupValue: _type,
                    onChanged: (v) => setState(() => _type = v!),
                  ),
                  RadioListTile<WalkInType>(
                    title: const Text('Refill Own Bottle'),
                    subtitle: Text(WalkInType.customerRefill.subtitle),
                    value: WalkInType.customerRefill,
                    groupValue: _type,
                    onChanged: (v) => setState(() => _type = v!),
                  ),
                  const Divider(height: 24),
                  if (_type == WalkInType.businessBottles)
                    AppTextField(
                      label: 'Bottles *',
                      controller: _businessQtyCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        if (n == null || n <= 0) return 'Enter a valid quantity';
                        return null;
                      },
                      onChanged: (_) => setState(() {}),
                    ),
                  if (_type == WalkInType.customerRefill)
                    AppTextField(
                      label: 'Bottles to Refill *',
                      controller: _customerQtyCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        if (n == null || n <= 0) return 'Enter a valid quantity';
                        return null;
                      },
                      onChanged: (_) => setState(() {}),
                    ),
                  const SizedBox(height: 12),
                  customersAsync.when(
                    data: (customers) => DropdownButtonFormField<String?>(
                      value: _customerId,
                      decoration: const InputDecoration(
                        labelText: 'Customer (optional)',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text(WalkInSale.walkInCustomerLabel),
                        ),
                        ...customers.map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          ),
                        ),
                      ],
                      onChanged: (v) => setState(() => _customerId = v),
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Price Per Bottle *',
                    controller: _priceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (v) {
                      final n = double.tryParse(v ?? '');
                      if (n == null || n <= 0) return 'Enter a valid price';
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total: ${CurrencyFormatter.format(_total)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _paymentMethod,
                    decoration: const InputDecoration(
                      labelText: 'Payment Method',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                      DropdownMenuItem(value: 'GCash', child: Text('GCash')),
                      DropdownMenuItem(value: 'Bank', child: Text('Bank Transfer')),
                    ],
                    onChanged: (v) =>
                        setState(() => _paymentMethod = v ?? 'Cash'),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Notes',
                    controller: _notesCtrl,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _save,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Record Walk-In'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
