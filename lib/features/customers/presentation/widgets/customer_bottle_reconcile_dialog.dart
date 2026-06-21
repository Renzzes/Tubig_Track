import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/bottle_variance_utils.dart';
import '../../../inventory/presentation/providers/inventory_provider.dart';
import '../providers/customers_provider.dart';

/// Shared bottle reconciliation dialog for profile and visit mode.
class CustomerBottleReconcileDialog {
  CustomerBottleReconcileDialog._();

  static Future<void> show(
    BuildContext context,
    WidgetRef ref, {
    required String customerId,
    required int expectedBottles,
  }) async {
    final ctrl = TextEditingController(text: expectedBottles.toString());
    final reasonCtrl = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          final actual = int.tryParse(ctrl.text) ?? expectedBottles;
          final variance = actual - expectedBottles;
          final varianceColor = BottleVarianceUtils.colorFor(variance);
          final hasMissing = variance < 0;
          final hasExcess = variance > 0;

          Future<void> invalidate() async {
            ref.invalidate(customerByIdProvider(customerId));
            ref.invalidate(customerStatsProvider(customerId));
          }

          return AlertDialog(
            title: const Text('Bottle Reconciliation'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ReconcileRow(
                    label: 'Expected Bottles',
                    value: '$expectedBottles',
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: ctrl,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Actual Count',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: reasonCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Reason (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (variance != 0) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: varianceColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: varianceColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ReconcileRow(
                            label: 'Variance',
                            value: variance > 0 ? '+$variance' : '$variance',
                            valueColor: varianceColor,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            hasMissing
                                ? '⚠ Missing Bottles: ${variance.abs()}'
                                : 'Excess Bottles: ${variance.abs()}',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: varianceColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else
                    const Text(
                      'Bottles match. No adjustment needed.',
                      style: TextStyle(color: AppColors.success),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              if (variance == 0)
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    try {
                      await ref
                          .read(inventoryRepositoryProvider)
                          .recordCustomerBottleReconciliation(
                            customerId: customerId,
                            expectedCount: expectedBottles,
                            actualCount: actual,
                            reason: reasonCtrl.text.trim().isEmpty
                                ? null
                                : reasonCtrl.text.trim(),
                            applyAdjustment: false,
                          );
                      await invalidate();
                    } catch (_) {}
                  },
                  child: const Text('Log'),
                ),
              if (variance != 0) ...[
                OutlinedButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    try {
                      await ref
                          .read(inventoryRepositoryProvider)
                          .recordCustomerBottleReconciliation(
                            customerId: customerId,
                            expectedCount: expectedBottles,
                            actualCount: actual,
                            reason: reasonCtrl.text.trim().isEmpty
                                ? null
                                : reasonCtrl.text.trim(),
                            applyAdjustment: false,
                          );
                      await invalidate();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Physical count recorded.'),
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
                  },
                  child: const Text('Save Count'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    if (!context.mounted) return;
                    final confirmMsg = hasExcess
                        ? 'This customer has ${variance.abs()} excess bottles.\n\nApply correction?'
                        : 'This customer has ${variance.abs()} missing bottles.\n\nApply correction?';
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (c) => AlertDialog(
                        title: Text(
                          hasExcess ? 'Excess Bottles' : 'Missing Bottles',
                        ),
                        content: Text(confirmMsg),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(c, false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(c, true),
                            child: const Text('Confirm'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true && context.mounted) {
                      try {
                        await ref
                            .read(inventoryRepositoryProvider)
                            .recordCustomerBottleReconciliation(
                              customerId: customerId,
                              expectedCount: expectedBottles,
                              actualCount: actual,
                              reason: reasonCtrl.text.trim().isEmpty
                                  ? (hasMissing
                                      ? 'Customer Lost Bottles'
                                      : 'Excess Bottles')
                                  : reasonCtrl.text.trim(),
                              applyAdjustment: true,
                            );
                        await invalidate();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                hasMissing
                                    ? 'Adjusted: ${variance.abs()} missing bottles recorded.'
                                    : 'Adjusted: ${variance.abs()} excess bottles recorded.',
                              ),
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
                  },
                  child: const Text('Apply Correction'),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _ReconcileRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _ReconcileRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
