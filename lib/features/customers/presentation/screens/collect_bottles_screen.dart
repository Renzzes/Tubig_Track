import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../inventory/presentation/providers/inventory_provider.dart';
import '../providers/customers_provider.dart';

class CollectBottlesScreen extends ConsumerStatefulWidget {
  final String customerId;

  const CollectBottlesScreen({super.key, required this.customerId});

  @override
  ConsumerState<CollectBottlesScreen> createState() =>
      _CollectBottlesScreenState();
}

class _CollectBottlesScreenState extends ConsumerState<CollectBottlesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessQtyCtrl = TextEditingController(text: '0');
  final _customerOwnedQtyCtrl = TextEditingController(text: '0');
  final _notesCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _businessQtyCtrl.dispose();
    _customerOwnedQtyCtrl.dispose();
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
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final businessQty = int.parse(_businessQtyCtrl.text.trim());
      final customerOwnedQty = int.parse(_customerOwnedQtyCtrl.text.trim());
      if (businessQty == 0 && customerOwnedQty == 0) {
        throw StateError('Enter at least one bottle quantity to collect.');
      }

      await ref.read(inventoryRepositoryProvider).collectBottlesFromCustomer(
            customerId: widget.customerId,
            businessOwnedCollected: businessQty,
            customerOwnedCollected: customerOwnedQty,
            date: _selectedDate,
            notes: _notesCtrl.text.trim().isEmpty
                ? null
                : _notesCtrl.text.trim(),
          );

      ref.invalidate(customerStatsProvider(widget.customerId));
      ref.invalidate(bottleTransactionsStreamProvider);
      refreshInventoryProviders(ref);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Collected $businessQty business-owned and '
              '$customerOwnedQty customer-owned bottles',
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
    final customerAsync = ref.watch(customerByIdProvider(widget.customerId));
    final statsAsync = ref.watch(customerStatsProvider(widget.customerId));

    return Scaffold(
      appBar: AppBar(title: const Text('Collect Bottles')),
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
                        data: (s) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Business-Owned Held: ${s.bottlesHeld}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              'Customer-Owned Held: ${s.customerOwnedBottlesHeld}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        loading: () => const SizedBox(),
                        error: (_, __) => const SizedBox(),
                      ),
                    ],
                  ),
                ),
              ),
              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: LinearProgressIndicator(),
                ),
              ),
              error: (e, _) => Text('Error: $e'),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Business-Owned Bottles Collected',
              controller: _businessQtyCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              prefixIcon: const Icon(Icons.inventory_2_outlined),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                final n = int.tryParse(v);
                if (n == null || n < 0) return 'Enter a valid quantity';
                final held = statsAsync.value?.bottlesHeld;
                if (held != null && n > held) {
                  return 'Only $held business-owned bottles held';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Customer-Owned Bottles Collected',
              controller: _customerOwnedQtyCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              prefixIcon: const Icon(Icons.person_outline),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                final n = int.tryParse(v);
                if (n == null || n < 0) return 'Enter a valid quantity';
                final held = statsAsync.value?.customerOwnedBottlesHeld;
                if (held != null && n > held) {
                  return 'Only $held customer-owned bottles held';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Only business-owned collections affect inventory.',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Collection Date'),
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
                  : const Text('Record Collection'),
            ),
          ],
        ),
      ),
    );
  }
}
