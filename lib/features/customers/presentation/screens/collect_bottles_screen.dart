import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../customers/presentation/providers/customers_provider.dart';
import '../../../inventory/domain/entities/bottle_transaction.dart';
import '../../../inventory/presentation/providers/inventory_provider.dart';

class CollectBottlesScreen extends ConsumerStatefulWidget {
  final String customerId;

  const CollectBottlesScreen({super.key, required this.customerId});

  @override
  ConsumerState<CollectBottlesScreen> createState() =>
      _CollectBottlesScreenState();
}

class _CollectBottlesScreenState extends ConsumerState<CollectBottlesScreen> {
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
      final qty = int.parse(_quantityCtrl.text.trim());
      final stats =
          await ref.read(customerRepositoryProvider).getCustomerStats(
                widget.customerId,
              );
      if (qty > stats.bottlesHeld) {
        throw StateError(
          'Cannot collect more than ${stats.bottlesHeld} bottles currently held.',
        );
      }

      await ref.read(inventoryRepositoryProvider).recordTransaction(
            BottleTransaction(
              id: const Uuid().v4(),
              customerId: widget.customerId,
              transactionType: TransactionType.ret,
              quantity: qty,
              date: _selectedDate,
              notes: _notesCtrl.text.trim().isEmpty
                  ? 'Empty bottles collected'
                  : _notesCtrl.text.trim(),
            ),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Collected $qty bottles'),
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
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.1),
                        child: Text(
                          c?.name[0].toUpperCase() ?? '?',
                          style: const TextStyle(color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c?.name ?? '',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            statsAsync.when(
                              data: (s) => Text(
                                'Currently holding ${s.bottlesHeld} bottles',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                              loading: () => const SizedBox(),
                              error: (_, __) => const SizedBox(),
                            ),
                          ],
                        ),
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
              label: 'Quantity Collected *',
              controller: _quantityCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              prefixIcon: const Icon(Icons.inventory_2_outlined),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                final n = int.tryParse(v);
                if (n == null || n <= 0) return 'Enter a valid quantity';
                final held = statsAsync.value?.bottlesHeld;
                if (held != null && n > held) {
                  return 'Customer only holds $held bottles';
                }
                return null;
              },
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
