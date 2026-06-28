import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';

enum ExcessPaymentChoice { returnChange, addToDeposit }

/// Cashier decision when customer pays more than amount due.
Future<ExcessPaymentChoice?> showExcessPaymentDialog({
  required BuildContext context,
  required double cashReceived,
  required double amountDue,
  required double excess,
}) {
  return showModalBottomSheet<ExcessPaymentChoice>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) {
      var selected = ExcessPaymentChoice.returnChange;
      return StatefulBuilder(
        builder: (context, setState) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
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
                    'Excess Payment',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _InfoRow(
                    label: 'Customer paid',
                    value: CurrencyFormatter.format(cashReceived),
                  ),
                  _InfoRow(
                    label: 'Amount Due',
                    value: CurrencyFormatter.format(amountDue),
                  ),
                  _InfoRow(
                    label: 'Excess',
                    value: CurrencyFormatter.format(excess),
                    emphasized: true,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'How would you like to handle the excess?',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  RadioListTile<ExcessPaymentChoice>(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Return Change'),
                    subtitle: Text(
                      'Customer receives ${CurrencyFormatter.format(excess)} change.',
                    ),
                    value: ExcessPaymentChoice.returnChange,
                    groupValue: selected,
                    onChanged: (v) => setState(() => selected = v!),
                  ),
                  RadioListTile<ExcessPaymentChoice>(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Add to Customer Deposit'),
                    subtitle: Text(
                      '${CurrencyFormatter.format(excess)} will be added to '
                      "the customer's deposit balance.",
                    ),
                    value: ExcessPaymentChoice.addToDeposit,
                    groupValue: selected,
                    onChanged: (v) => setState(() => selected = v!),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => Navigator.pop(ctx, selected),
                          child: const Text('Confirm'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasized;

  const _InfoRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: emphasized ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
