import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../customers/presentation/providers/customers_provider.dart';
import '../../domain/entities/bottle_transaction.dart';
import '../providers/inventory_provider.dart';

class TransactionBottomSheet extends ConsumerStatefulWidget {
  final TransactionType transactionType;
  final BottleTransaction? existingTransaction;

  const TransactionBottomSheet({
    super.key,
    required this.transactionType,
    this.existingTransaction,
  });

  @override
  ConsumerState<TransactionBottomSheet> createState() =>
      _TransactionBottomSheetState();
}

class _TransactionBottomSheetState
    extends ConsumerState<TransactionBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _quantityCtrl;
  late final TextEditingController _notesCtrl;
  String? _selectedCustomerId;
  bool _isLoading = false;

  bool get _isEditing => widget.existingTransaction != null;

  bool get _requiresCustomer =>
      widget.transactionType == TransactionType.borrow ||
      widget.transactionType == TransactionType.ret;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingTransaction;
    _quantityCtrl = TextEditingController(
      text: existing != null ? '${existing.quantity}' : '1',
    );
    _notesCtrl = TextEditingController(text: existing?.notes ?? '');
    _selectedCustomerId = existing?.customerId;
  }

  @override
  void dispose() {
    _quantityCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_requiresCustomer && _selectedCustomerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a customer')),
      );
      return;
    }
    setState(() => _isLoading = true);

    try {
      final tx = BottleTransaction(
        id: widget.existingTransaction?.id ?? const Uuid().v4(),
        customerId: _selectedCustomerId,
        transactionType: widget.transactionType,
        quantity: int.parse(_quantityCtrl.text.trim()),
        date: widget.existingTransaction?.date ?? DateTime.now(),
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );

      if (_isEditing) {
        await ref.read(inventoryRepositoryProvider).updateTransaction(tx);
      } else {
        await ref.read(inventoryRepositoryProvider).recordTransaction(tx);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? '${BottleTransaction.typeLabel(widget.transactionType)} updated!'
                  : '${BottleTransaction.typeLabel(widget.transactionType)} recorded!',
            ),
          ),
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

    final typeLabel = BottleTransaction.typeLabel(widget.transactionType);

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
                _isEditing ? 'Edit $typeLabel' : '$typeLabel Bottles',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              if (_requiresCustomer) ...[
                customersAsync.when(
                  data: (customers) => DropdownButtonFormField<String>(
                    // ignore: deprecated_member_use
                    value: _selectedCustomerId,
                    decoration: const InputDecoration(
                      labelText: 'Customer',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    items: customers
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedCustomerId = v),
                    validator: (v) =>
                        _requiresCustomer && v == null
                            ? 'Required'
                            : null,
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error: $e'),
                ),
                const SizedBox(height: 16),
              ],
              AppTextField(
                label: 'Quantity *',
                controller: _quantityCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                autofocus: !_requiresCustomer,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  final n = int.tryParse(v);
                  if (n == null || n <= 0) return 'Must be > 0';
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
                child: Text(
                  _isEditing ? 'Update $typeLabel' : 'Save $typeLabel',
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
