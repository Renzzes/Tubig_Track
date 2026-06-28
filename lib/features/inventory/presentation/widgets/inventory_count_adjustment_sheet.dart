import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../domain/entities/bottle_transaction.dart';
import '../providers/inventory_provider.dart';
import 'inventory_validation_dialog.dart';

enum InventoryCountCategory { filled, empty }

class InventoryCountAdjustmentSheet extends ConsumerStatefulWidget {
  final InventoryCountCategory category;
  final BottleTransaction? existingTransaction;

  const InventoryCountAdjustmentSheet({
    super.key,
    required this.category,
    this.existingTransaction,
  });

  @override
  ConsumerState<InventoryCountAdjustmentSheet> createState() =>
      _InventoryCountAdjustmentSheetState();
}

class _InventoryCountAdjustmentSheetState
    extends ConsumerState<InventoryCountAdjustmentSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _actualCtrl;
  late final TextEditingController _reasonCtrl;
  late final TextEditingController _notesCtrl;
  bool _isLoading = false;
  int? _systemCount;

  bool get _isEditing => widget.existingTransaction != null;

  TransactionType get _transactionType => switch (widget.category) {
        InventoryCountCategory.filled => TransactionType.adjustment,
        InventoryCountCategory.empty => TransactionType.emptyAdjustment,
      };

  String get _categoryLabel => switch (widget.category) {
        InventoryCountCategory.filled => 'Filled Bottles',
        InventoryCountCategory.empty => 'Empty Bottles',
      };

  @override
  void initState() {
    super.initState();
    final existing = widget.existingTransaction;
    _actualCtrl = TextEditingController();
    _reasonCtrl = TextEditingController(text: existing?.reason ?? '');
    _notesCtrl = TextEditingController(text: existing?.notes ?? '');

    if (existing != null) {
      _parseExistingTransition(existing.notes, existing.quantity);
    }
  }

  void _parseExistingTransition(String? notes, int quantity) {
    if (notes != null && notes.contains('→')) {
      final parts = notes.split('→');
      if (parts.length == 2) {
        final before = int.tryParse(parts[0].trim());
        final after = int.tryParse(parts[1].trim());
        if (before != null && after != null) {
          _systemCount = before;
          _actualCtrl.text = '$after';
          return;
        }
      }
    }
    if (_systemCount != null) {
      _actualCtrl.text = '${_systemCount! + quantity}';
    }
  }

  @override
  void dispose() {
    _actualCtrl.dispose();
    _reasonCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  int? get _actualCount => int.tryParse(_actualCtrl.text.trim());

  int? get _difference {
    final system = _systemCount;
    final actual = _actualCount;
    if (system == null || actual == null) return null;
    return actual - system;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final system = _systemCount;
    final actual = _actualCount;
    final difference = _difference;
    if (system == null || actual == null || difference == null) return;
    if (difference == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Actual count matches system count.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final tx = BottleTransaction(
        id: widget.existingTransaction?.id ?? const Uuid().v4(),
        transactionType: _transactionType,
        quantity: difference,
        date: widget.existingTransaction?.date ?? DateTime.now(),
        reason: _reasonCtrl.text.trim(),
        notes: '$system → $actual',
      );

      final repo = ref.read(inventoryRepositoryProvider);
      if (_isEditing) {
        await repo.updateTransaction(tx);
      } else {
        await repo.recordTransaction(tx);
      }

      if (mounted) {
        refreshInventoryProviders(ref);
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? '$_categoryLabel adjustment updated!'
                  : '$_categoryLabel adjustment recorded!',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) await handleInventorySaveError(context, e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(inventorySummaryProvider);

    return summaryAsync.when(
      data: (summary) {
        _systemCount ??= switch (widget.category) {
          InventoryCountCategory.filled => summary.filledBottlesAvailable,
          InventoryCountCategory.empty => summary.emptyBottlesReadyForRefill,
        };

        final difference = _difference;

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
                      _isEditing
                          ? 'Edit Adjust $_categoryLabel'
                          : 'Adjust $_categoryLabel',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Correct recorded inventory after a physical count.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      label: 'System Count',
                      initialValue: '$_systemCount',
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Actual Count *',
                      controller: _actualCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      autofocus: true,
                      onChanged: (_) => setState(() {}),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (int.tryParse(v) == null) return 'Invalid number';
                        return null;
                      },
                    ),
                    if (difference != null && difference != 0) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Difference: ${difference >= 0 ? '+' : ''}$difference',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Reason *',
                      controller: _reasonCtrl,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
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
                      child: Text(_isEditing ? 'Update' : 'Save'),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(48),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (e, _) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Error loading inventory: $e'),
        ),
      ),
    );
  }
}
