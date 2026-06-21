import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../inventory/presentation/providers/inventory_provider.dart';
import '../providers/customers_provider.dart';

class AdjustCustomerOwnedBottleBalanceScreen extends ConsumerStatefulWidget {
  final String customerId;

  const AdjustCustomerOwnedBottleBalanceScreen({
    super.key,
    required this.customerId,
  });

  @override
  ConsumerState<AdjustCustomerOwnedBottleBalanceScreen> createState() =>
      _AdjustCustomerOwnedBottleBalanceScreenState();
}

class _AdjustCustomerOwnedBottleBalanceScreenState
    extends ConsumerState<AdjustCustomerOwnedBottleBalanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isIncrease = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _quantityCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final qty = int.parse(_quantityCtrl.text.trim());
      final delta = _isIncrease ? qty : -qty;

      await ref.read(inventoryRepositoryProvider).adjustCustomerOwnedBottleBalance(
            customerId: widget.customerId,
            quantityDelta: delta,
            notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
            date: _selectedDate,
          );

      ref.invalidate(customerStatsProvider(widget.customerId));
      ref.invalidate(customerByIdProvider(widget.customerId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              delta >= 0
                  ? 'Customer-owned balance increased by $qty'
                  : 'Customer-owned balance decreased by $qty',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(customerStatsProvider(widget.customerId));

    return Scaffold(
      appBar: AppBar(title: const Text('Adjust Customer-Owned Balance')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            statsAsync.when(
              data: (s) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Customer-Owned Bottles Held: ${s.customerOwnedBottlesHeld}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
            ),
            const SizedBox(height: 16),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('Add Bottles')),
                ButtonSegment(value: false, label: Text('Remove Bottles')),
              ],
              selected: {_isIncrease},
              onSelectionChanged: (s) =>
                  setState(() => _isIncrease = s.first),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Quantity *',
              controller: _quantityCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                final n = int.tryParse(v);
                if (n == null || n <= 0) return 'Enter a valid quantity';
                if (!_isIncrease) {
                  final held = statsAsync.value?.customerOwnedBottlesHeld;
                  if (held != null && n > held) {
                    return 'Customer only holds $held customer-owned bottles';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date'),
              subtitle: Text(DateFormat('MMMM d, yyyy').format(_selectedDate)),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: _pickDate,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Notes (Optional)',
              controller: _notesCtrl,
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _save,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Save Adjustment'),
            ),
          ],
        ),
      ),
    );
  }
}
