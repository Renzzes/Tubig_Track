import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/responsive.dart';
import '../../domain/entities/savings_entities.dart';
import '../../domain/repositories/savings_repository.dart';
import '../providers/savings_provider.dart';
import '../../../dashboard/presentation/providers/business_cash_provider.dart';

class SavingsTransferSheet extends ConsumerStatefulWidget {
  final SavingsTransferType type;
  final double maxAmount;

  const SavingsTransferSheet({
    super.key,
    required this.type,
    required this.maxAmount,
  });

  @override
  ConsumerState<SavingsTransferSheet> createState() =>
      _SavingsTransferSheetState();
}

class _SavingsTransferSheetState extends ConsumerState<SavingsTransferSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  bool _loading = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(savingsRepositoryProvider).recordTransfer(
            SavingsTransfer(
              id: const Uuid().v4(),
              amount: double.parse(_amountCtrl.text.trim()),
              type: widget.type,
              date: _date,
              notes: _notesCtrl.text.trim().isEmpty
                  ? null
                  : _notesCtrl.text.trim(),
            ),
          );
      ref.invalidate(savingsSummaryProvider);
      ref.invalidate(savingsTransferLedgerProvider);
      ref.invalidate(businessCashBreakdownProvider);
      if (mounted) {
        Navigator.pop(context, true);
        final message = widget.type == SavingsTransferType.transfer
            ? 'Transferred to savings account'
            : 'Withdrawn from savings account';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } on SavingsTransferException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTransfer = widget.type == SavingsTransferType.transfer;
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
                  widget.type.label,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  isTransfer
                      ? 'Move money from business cash to your savings account. Accumulated profit does not change.'
                      : 'Move money from your savings account back to business cash.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 8),
                Text(
                  'Available: ${CurrencyFormatter.format(widget.maxAmount)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
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
                  prefixIcon: Icon(
                    isTransfer
                        ? Icons.savings_outlined
                        : Icons.account_balance_wallet_outlined,
                  ),
                  autofocus: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    final n = double.tryParse(v);
                    if (n == null || n <= 0) return 'Invalid amount';
                    if (n > widget.maxAmount + 0.001) {
                      return 'Exceeds available amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: const Text('Date'),
                  subtitle: Text(
                    '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setState(() => _date = picked);
                  },
                ),
                const SizedBox(height: 8),
                AppTextField(
                  label: 'Notes (Optional)',
                  controller: _notesCtrl,
                  maxLines: 2,
                  hint: isTransfer
                      ? 'e.g. Monthly savings allocation'
                      : 'e.g. Needed for supplies purchase',
                ),
                const SizedBox(height: 24),
                ResponsivePrimaryButton(
                  onPressed: _loading ? null : _save,
                  isLoading: _loading,
                  child: Text(widget.type.label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
