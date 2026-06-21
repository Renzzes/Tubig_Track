import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../inventory/presentation/providers/inventory_provider.dart';
import '../providers/customers_provider.dart';

class SetCustomerOwnedBottleBalanceScreen extends ConsumerStatefulWidget {
  final String customerId;

  const SetCustomerOwnedBottleBalanceScreen({
    super.key,
    required this.customerId,
  });

  @override
  ConsumerState<SetCustomerOwnedBottleBalanceScreen> createState() =>
      _SetCustomerOwnedBottleBalanceScreenState();
}

class _SetCustomerOwnedBottleBalanceScreenState
    extends ConsumerState<SetCustomerOwnedBottleBalanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _quantityCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final held = await ref
          .read(inventoryRepositoryProvider)
          .getCustomerOwnedBottlesHeld(widget.customerId);
      if (mounted && held > 0) {
        _quantityCtrl.text = '$held';
      }
    });
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
      await ref.read(inventoryRepositoryProvider).setCustomerOwnedBottleBalance(
            customerId: widget.customerId,
            quantity: qty,
            date: _selectedDate,
            notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
          );

      ref.invalidate(customerStatsProvider(widget.customerId));
      ref.invalidate(customerByIdProvider(widget.customerId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Customer-owned balance set to $qty bottles'),
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
    final customerAsync = ref.watch(customerByIdProvider(widget.customerId));
    final statsAsync = ref.watch(customerStatsProvider(widget.customerId));

    return Scaffold(
      appBar: AppBar(title: const Text('Set Customer-Owned Balance')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            customerAsync.when(
              data: (c) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c?.name ?? '',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      statsAsync.when(
                        data: (s) => Text(
                          'Current customer-owned: ${s.customerOwnedBottlesHeld} bottles',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        loading: () => const SizedBox(),
                        error: (_, __) => const SizedBox(),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Customer-owned bottles do not affect business inventory.',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Customer-Owned Bottles Held *',
              controller: _quantityCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                final n = int.tryParse(v);
                if (n == null || n < 0) return 'Enter a valid quantity';
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
                  : const Text('Save Balance'),
            ),
          ],
        ),
      ),
    );
  }
}
