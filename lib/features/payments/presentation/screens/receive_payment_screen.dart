import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../customers/presentation/providers/customers_provider.dart';
import '../../../deliveries/domain/entities/delivery.dart';
import '../../../deliveries/presentation/providers/deliveries_provider.dart';
import '../providers/payments_provider.dart';

class ReceivePaymentScreen extends ConsumerStatefulWidget {
  final String customerId;

  const ReceivePaymentScreen({super.key, required this.customerId});

  @override
  ConsumerState<ReceivePaymentScreen> createState() =>
      _ReceivePaymentScreenState();
}

class _ReceivePaymentScreenState extends ConsumerState<ReceivePaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String? _selectedDeliveryId;
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
      await ref.read(paymentRepositoryProvider).recordPayment(
            customerId: widget.customerId,
            amount: double.parse(_amountCtrl.text.trim()),
            deliveryId: _selectedDeliveryId,
            notes: _notesCtrl.text.trim().isEmpty
                ? null
                : _notesCtrl.text.trim(),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment received!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
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
    final customerAsync = ref.watch(customerByIdProvider(widget.customerId));
    final statsAsync = ref.watch(customerStatsProvider(widget.customerId));
    final deliveriesAsync =
        ref.watch(customerDeliveriesStreamProvider(widget.customerId));

    return Scaffold(
      appBar: AppBar(title: const Text('Receive Payment')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Customer info card
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
                                'Outstanding Balance: ${CurrencyFormatter.format(s.unpaidBalance)}',
                                style: TextStyle(
                                  color: s.unpaidBalance > 0
                                      ? AppColors.error
                                      : AppColors.success,
                                  fontWeight: FontWeight.w600,
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
              loading: () => const SizedBox(),
              error: (e, _) => Text('Error: $e'),
            ),
            const SizedBox(height: 16),

            // Unpaid deliveries selector
            deliveriesAsync.when(
              data: (deliveries) {
                final unpaid = deliveries
                    .where(
                      (d) =>
                          d.paymentStatus != PaymentStatus.paid &&
                          d.remainingBalance > 0,
                    )
                    .toList();
                if (unpaid.isEmpty) return const SizedBox();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Apply to delivery (optional)',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.grey[700],
                          ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: RadioGroup<String?>(
                        groupValue: _selectedDeliveryId,
                        onChanged: (v) =>
                            setState(() => _selectedDeliveryId = v),
                        child: Column(
                          children: [
                            const RadioListTile<String?>(
                              title: Text('Apply to oldest balance'),
                              value: null,
                            ),
                            ...unpaid.map(
                              (d) => RadioListTile<String?>(
                                title: Text(
                                  '${d.quantity} btl — Balance: ${CurrencyFormatter.format(d.remainingBalance)}',
                                ),
                                subtitle: Text(
                                  _paymentStatusLabel(d.paymentStatus),
                                  style: TextStyle(
                                    color:
                                        _paymentStatusColor(d.paymentStatus),
                                    fontSize: 12,
                                  ),
                                ),
                                value: d.id,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),

            AppTextField(
              label: 'Amount Received *',
              controller: _amountCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'^\d+\.?\d{0,2}'),
                ),
              ],
              autofocus: true,
              prefixIcon: const Icon(Icons.payments_outlined),
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
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                minimumSize: const Size(double.infinity, 56),
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
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline),
                        SizedBox(width: 8),
                        Text(
                          'Receive Payment',
                          style: TextStyle(fontSize: 17),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _paymentStatusLabel(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.partial:
        return 'Partial';
      case PaymentStatus.unpaid:
        return 'Unpaid';
    }
  }

  Color _paymentStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return AppColors.paid;
      case PaymentStatus.partial:
        return AppColors.partial;
      case PaymentStatus.unpaid:
        return AppColors.unpaid;
    }
  }
}
