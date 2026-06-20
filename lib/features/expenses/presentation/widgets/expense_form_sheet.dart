import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/expense_category_utils.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../domain/entities/expense.dart';
import '../providers/expenses_provider.dart';

class ExpenseFormSheet extends ConsumerStatefulWidget {
  const ExpenseFormSheet({super.key});

  @override
  ConsumerState<ExpenseFormSheet> createState() => _ExpenseFormSheetState();
}

class _ExpenseFormSheetState extends ConsumerState<ExpenseFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _supplierCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final _unitCostCtrl = TextEditingController();
  String _selectedCategory = AppConstants.expenseCategories.first;
  bool _isLoading = false;
  bool _autoComputeAmount = false;

  bool get _showSupplyFields =>
      _selectedCategory == ExpenseCategoryUtils.supplies ||
      _selectedCategory == ExpenseCategoryUtils.otherSupplies;

  @override
  void initState() {
    super.initState();
    _quantityCtrl.addListener(_maybeAutoCompute);
    _unitCostCtrl.addListener(_maybeAutoCompute);
  }

  void _maybeAutoCompute() {
    if (!_showSupplyFields || !_autoComputeAmount) return;
    final qty = int.tryParse(_quantityCtrl.text.trim());
    final unit = double.tryParse(_unitCostCtrl.text.trim());
    if (qty != null && unit != null && qty > 0 && unit > 0) {
      _amountCtrl.text = (qty * unit).toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    _descriptionCtrl.dispose();
    _supplierCtrl.dispose();
    _quantityCtrl.dispose();
    _unitCostCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final quantity = _showSupplyFields && _quantityCtrl.text.isNotEmpty
          ? int.tryParse(_quantityCtrl.text.trim())
          : null;
      final unitCost = _showSupplyFields && _unitCostCtrl.text.isNotEmpty
          ? double.tryParse(_unitCostCtrl.text.trim())
          : null;

      await ref.read(expenseRepositoryProvider).addExpense(
            Expense(
              id: const Uuid().v4(),
              category: _selectedCategory,
              amount: double.parse(_amountCtrl.text.trim()),
              date: DateTime.now(),
              notes: _notesCtrl.text.trim().isEmpty
                  ? null
                  : _notesCtrl.text.trim(),
              description: _descriptionCtrl.text.trim().isEmpty
                  ? null
                  : _descriptionCtrl.text.trim(),
              supplier: _supplierCtrl.text.trim().isEmpty
                  ? null
                  : _supplierCtrl.text.trim(),
              quantity: quantity,
              unitCost: unitCost,
            ),
          );

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense added!')),
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
    return SafeArea(
      child: Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
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
                  'Add Expense',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  // ignore: deprecated_member_use
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: AppConstants.expenseCategories
                      .map(
                        (c) => DropdownMenuItem(
                          value: c,
                          child: Text(c),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v!),
                ),
                if (_showSupplyFields) ...[
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Description (Optional)',
                    controller: _descriptionCtrl,
                    prefixIcon: const Icon(Icons.description_outlined),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Supplier (Optional)',
                    controller: _supplierCtrl,
                    prefixIcon: const Icon(Icons.store_outlined),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'Quantity',
                          controller: _quantityCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          label: 'Unit Cost',
                          controller: _unitCostCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Compute amount from quantity × unit cost'),
                    value: _autoComputeAmount,
                    onChanged: (v) {
                      setState(() {
                        _autoComputeAmount = v;
                        if (v) _maybeAutoCompute();
                      });
                    },
                  ),
                ],
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Amount *',
                  controller: _amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  autofocus: !_showSupplyFields,
                  prefixIcon: const Icon(Icons.monetization_on_outlined),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    final n = double.tryParse(v);
                    if (n == null || n <= 0) return 'Invalid amount';
                    return null;
                  },
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
                  child: const Text('Save Expense'),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}
