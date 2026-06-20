import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../domain/entities/dispenser_sale.dart';
import '../providers/dispenser_sales_provider.dart';

class DispenserSalesScreen extends ConsumerStatefulWidget {
  const DispenserSalesScreen({super.key});

  @override
  ConsumerState<DispenserSalesScreen> createState() =>
      _DispenserSalesScreenState();
}

class _DispenserSalesScreenState extends ConsumerState<DispenserSalesScreen> {
  @override
  Widget build(BuildContext context) {
    final salesAsync = ref.watch(dispenserSalesStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dispenser Sales')),
      body: salesAsync.when(
        data: (sales) {
          if (sales.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.local_drink_outlined,
              message: 'No dispenser sales recorded',
              subMessage: 'Tap + to add your first sale',
            );
          }

          double total = sales.fold(0, (s, e) => s + e.amount);

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
                    const Text(
                      'Total Dispenser Sales',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      CurrencyFormatter.format(total),
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
                    final s = sales[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFE3F2FD),
                          child: Icon(
                            Icons.local_drink,
                            color: AppColors.primary,
                          ),
                        ),
                        title: Text(
                          CurrencyFormatter.format(s.amount),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(DateFormatter.formatDateTime(s.date)),
                            if (s.notes != null) Text(s.notes!),
                          ],
                        ),
                        onLongPress: () async {
                          final confirmed = await showConfirmDialog(
                            context,
                            title: 'Delete Sale',
                            message: 'Delete this dispenser sale?',
                            confirmText: 'Delete',
                          );
                          if (confirmed == true) {
                            await ref
                                .read(dispenserSaleRepositoryProvider)
                                .deleteSale(s.id);
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
        label: const Text('Add Sale'),
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddSaleSheet(),
    );
  }
}

class _AddSaleSheet extends ConsumerStatefulWidget {
  const _AddSaleSheet();

  @override
  ConsumerState<_AddSaleSheet> createState() => _AddSaleSheetState();
}

class _AddSaleSheetState extends ConsumerState<_AddSaleSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await ref.read(dispenserSaleRepositoryProvider).addSale(
            DispenserSale(
              id: const Uuid().v4(),
              amount: double.parse(_amountCtrl.text.trim()),
              date: DateTime.now(),
              notes: _notesCtrl.text.trim().isEmpty
                  ? null
                  : _notesCtrl.text.trim(),
            ),
          );

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sale recorded!')),
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
                'Record Dispenser Sale',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
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
                autofocus: true,
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
                child: const Text('Save Sale'),
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
