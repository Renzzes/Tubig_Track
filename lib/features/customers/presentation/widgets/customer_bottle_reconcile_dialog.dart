import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../inventory/presentation/providers/inventory_provider.dart';
import '../providers/customers_provider.dart';

/// Physical bottle count check for business-owned and customer-owned bottles.
class CustomerBottleCountDialog {
  CustomerBottleCountDialog._();

  static Future<void> show(
    BuildContext context,
    WidgetRef ref, {
    required String customerId,
    required int businessOwnedHeld,
    required int customerOwnedHeld,
  }) async {
    final businessCtrl =
        TextEditingController(text: businessOwnedHeld.toString());
    final customerCtrl =
        TextEditingController(text: customerOwnedHeld.toString());
    final notesCtrl = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          final actualBusiness =
              int.tryParse(businessCtrl.text) ?? businessOwnedHeld;
          final actualCustomer =
              int.tryParse(customerCtrl.text) ?? customerOwnedHeld;
          final businessDiff = actualBusiness - businessOwnedHeld;
          final customerDiff = actualCustomer - customerOwnedHeld;
          final hasDifference = businessDiff != 0 || customerDiff != 0;

          Future<void> invalidate() async {
            ref.invalidate(customerByIdProvider(customerId));
            ref.invalidate(customerStatsProvider(customerId));
          }

          Future<void> applyCounts() async {
            Navigator.pop(ctx);
            if (!hasDifference) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bottle counts match the system.'),
                  ),
                );
              }
              return;
            }

            final confirmed = await showDialog<bool>(
              context: context,
              builder: (c) => AlertDialog(
                title: const Text('Update Bottle Count?'),
                content: Text(
                  _buildConfirmMessage(
                    businessDiff: businessDiff,
                    customerDiff: customerDiff,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(c, false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(c, true),
                    child: const Text('Update Counts'),
                  ),
                ],
              ),
            );

            if (confirmed != true || !context.mounted) return;

            try {
              await ref.read(inventoryRepositoryProvider).recordCustomerBottleCountCheck(
                    customerId: customerId,
                    expectedBusinessOwned: businessOwnedHeld,
                    actualBusinessOwned: actualBusiness,
                    expectedCustomerOwned: customerOwnedHeld,
                    actualCustomerOwned: actualCustomer,
                    notes: notesCtrl.text.trim().isEmpty
                        ? null
                        : notesCtrl.text.trim(),
                  );
              await invalidate();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bottle counts updated.'),
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            }
          }

          return AlertDialog(
            title: const Text('Check Bottle Count'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'System Count',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  _CountRow(
                    label: 'Business-Owned Bottles',
                    value: '$businessOwnedHeld',
                  ),
                  _CountRow(
                    label: 'Customer-Owned Bottles',
                    value: '$customerOwnedHeld',
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Actual Count',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: businessCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Business-Owned Bottles',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: customerCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Customer-Owned Bottles',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notesCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (hasDifference) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Difference',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          if (businessDiff != 0)
                            _CountRow(
                              label: 'Business-Owned',
                              value: _signed(businessDiff),
                              valueColor: _colorForDiff(businessDiff),
                            ),
                          if (customerDiff != 0)
                            _CountRow(
                              label: 'Customer-Owned',
                              value: _signed(customerDiff),
                              valueColor: _colorForDiff(customerDiff),
                            ),
                        ],
                      ),
                    ),
                  ] else
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        'Counts match the system.',
                        style: TextStyle(color: Colors.green[700]),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: applyCounts,
                child: Text(hasDifference ? 'Update Counts' : 'Done'),
              ),
            ],
          );
        },
      ),
    );

    businessCtrl.dispose();
    customerCtrl.dispose();
    notesCtrl.dispose();
  }

  static String _signed(int value) =>
      value > 0 ? '+$value' : value.toString();

  static Color _colorForDiff(int diff) =>
      diff < 0 ? AppColors.error : AppColors.warning;

  static String _buildConfirmMessage({
    required int businessDiff,
    required int customerDiff,
  }) {
    final parts = <String>[];
    if (businessDiff != 0) {
      parts.add(
        'Business-owned: ${_signed(businessDiff)} bottle${businessDiff.abs() == 1 ? '' : 's'}',
      );
    }
    if (customerDiff != 0) {
      parts.add(
        'Customer-owned: ${_signed(customerDiff)} bottle${customerDiff.abs() == 1 ? '' : 's'}',
      );
    }
    return '${parts.join('\n')}\n\nUpdate stored counts and record in the bottle ledger?';
  }
}

class _CountRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _CountRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
