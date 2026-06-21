import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../suppliers/presentation/providers/suppliers_provider.dart';
import '../../domain/entities/supply_purchase.dart';
import '../providers/supply_purchase_provider.dart';

class PurchaseStockScreen extends ConsumerStatefulWidget {
  final String? purchaseId;

  const PurchaseStockScreen({super.key, this.purchaseId});

  @override
  ConsumerState<PurchaseStockScreen> createState() =>
      _PurchaseStockScreenState();
}

class _PurchaseStockScreenState extends ConsumerState<PurchaseStockScreen> {
  final _formKey = GlobalKey<FormState>();
  final _supplierCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController(text: '1');
  final _unitCostCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _purchaseDate = DateTime.now();
  String _itemType = AppConstants.supplyItemTypes.first;
  String? _selectedSupplierId;
  bool _manualSupplier = false;
  bool _isLoading = false;
  bool _loaded = false;
  SupplyPurchase? _existing;

  bool get _isViewMode => widget.purchaseId != null;

  double get _totalCost {
    final qty = int.tryParse(_quantityCtrl.text.trim()) ?? 0;
    final unit = double.tryParse(_unitCostCtrl.text.trim()) ?? 0;
    return qty * unit;
  }

  @override
  void initState() {
    super.initState();
    if (widget.purchaseId != null) {
      _loadPurchase();
    }
    _quantityCtrl.addListener(() => setState(() {}));
    _unitCostCtrl.addListener(() => setState(() {}));
  }

  Future<void> _loadPurchase() async {
    setState(() => _isLoading = true);
    final purchase = await ref
        .read(supplyPurchaseRepositoryProvider)
        .getById(widget.purchaseId!);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _loaded = true;
      _existing = purchase;
      if (purchase != null) {
        _supplierCtrl.text = purchase.supplierName;
        _itemType = purchase.itemType;
        _quantityCtrl.text = '${purchase.quantity}';
        _unitCostCtrl.text = '${purchase.unitCost}';
        _notesCtrl.text = purchase.notes ?? '';
        _purchaseDate = purchase.purchaseDate;
      }
    });
  }

  @override
  void dispose() {
    _supplierCtrl.dispose();
    _quantityCtrl.dispose();
    _unitCostCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _purchaseDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final id = const Uuid().v4();
      final expenseId = const Uuid().v4();
      final qty = int.parse(_quantityCtrl.text.trim());
      final unitCost = double.parse(_unitCostCtrl.text.trim());

      await ref.read(supplyPurchaseRepositoryProvider).createPurchase(
            SupplyPurchase(
              id: id,
              purchaseDate: _purchaseDate,
              supplierName: _supplierCtrl.text.trim(),
              supplierId: _selectedSupplierId,
              itemType: _itemType,
              quantity: qty,
              unitCost: unitCost,
              totalCost: qty * unitCost,
              notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
              expenseId: expenseId,
            ),
          );

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stock purchase recorded!')),
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

  Future<void> _delete() async {
    if (_existing == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Purchase'),
        content: const Text(
          'This will reverse inventory, remove the linked expense, and update savings. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref
        .read(supplyPurchaseRepositoryProvider)
        .deletePurchase(_existing!.id);
    if (mounted) {
      context.pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Purchase deleted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isViewMode && !_loaded) {
      return Scaffold(
        appBar: AppBar(title: const Text('Purchase Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_isViewMode && _existing == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Purchase Details')),
        body: const Center(child: Text('Purchase not found')),
      );
    }

    final readOnly = _isViewMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(readOnly ? 'Delivery Details' : 'Supplier Delivery'),
        actions: [
          if (readOnly && _existing != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
              tooltip: 'Delete',
            ),
        ],
      ),
      body: ResponsiveContent(
        padding: EdgeInsets.all(context.pageHorizontalPadding),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (readOnly && _existing != null) ...[
                _InfoTile('Date', DateFormatter.format(_existing!.purchaseDate)),
                _InfoTile('Supplier', _existing!.supplierName),
                _InfoTile('Item', _existing!.itemType),
                _InfoTile('Quantity', '${_existing!.quantity}'),
                _InfoTile('Unit Cost',
                    CurrencyFormatter.format(_existing!.unitCost)),
                _InfoTile('Total Cost',
                    CurrencyFormatter.format(_existing!.totalCost)),
                if (_existing!.notes != null)
                  _InfoTile('Notes', _existing!.notes!),
                const SizedBox(height: 16),
                Text(
                  'Linked expense and inventory were updated automatically when this purchase was saved.',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ] else ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Purchase Date'),
                  subtitle: Text(DateFormatter.format(_purchaseDate)),
                  trailing: const Icon(Icons.calendar_today_outlined),
                  onTap: _pickDate,
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Enter supplier manually'),
                  value: _manualSupplier,
                  onChanged: (v) => setState(() {
                    _manualSupplier = v;
                    _selectedSupplierId = null;
                    if (!v) _supplierCtrl.clear();
                  }),
                ),
                if (_manualSupplier)
                  AppTextField(
                    label: 'Supplier Name *',
                    controller: _supplierCtrl,
                    prefixIcon: const Icon(Icons.store_outlined),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  )
                else
                  ref.watch(suppliersStreamProvider).when(
                        data: (suppliers) =>
                            DropdownButtonFormField<String?>(
                          // ignore: deprecated_member_use
                          value: _selectedSupplierId,
                          decoration: const InputDecoration(
                            labelText: 'Supplier *',
                            prefixIcon: Icon(Icons.store_outlined),
                          ),
                          items: [
                            ...suppliers.map(
                              (s) => DropdownMenuItem(
                                value: s.id,
                                child: Text(s.name),
                              ),
                            ),
                            const DropdownMenuItem(
                              value: null,
                              child: Text('Manual entry...'),
                            ),
                          ],
                          onChanged: (v) {
                            setState(() {
                              if (v == null) {
                                _manualSupplier = true;
                                _selectedSupplierId = null;
                              } else {
                                _selectedSupplierId = v;
                                final s = suppliers
                                    .firstWhere((x) => x.id == v);
                                _supplierCtrl.text = s.name;
                              }
                            });
                          },
                          validator: (v) {
                            if (!_manualSupplier && v == null) {
                              return 'Select a supplier';
                            }
                            return null;
                          },
                        ),
                        loading: () => const LinearProgressIndicator(),
                        error: (_, __) => AppTextField(
                          label: 'Supplier Name *',
                          controller: _supplierCtrl,
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                      ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  // ignore: deprecated_member_use
                  value: _itemType,
                  decoration: const InputDecoration(
                    labelText: 'Item Type *',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: AppConstants.supplyItemTypes
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setState(() => _itemType = v!),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Quantity *',
                  controller: _quantityCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  prefixIcon: const Icon(Icons.numbers),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    final n = int.tryParse(v);
                    if (n == null || n <= 0) return 'Invalid quantity';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Unit Cost *',
                  controller: _unitCostCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  prefixIcon: const Icon(Icons.monetization_on_outlined),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    final n = double.tryParse(v);
                    if (n == null || n <= 0) return 'Invalid amount';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Cost',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        CurrencyFormatter.format(_totalCost),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Notes (Optional)',
                  controller: _notesCtrl,
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                ResponsivePrimaryButton(
                  onPressed: _isLoading ? null : _save,
                  isLoading: _isLoading,
                  child: const Text('Save Purchase'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: TextStyle(color: Colors.grey[600])),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
