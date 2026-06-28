import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../domain/entities/bottle_transaction.dart';
import '../widgets/inventory_count_adjustment_sheet.dart';
import '../widgets/transaction_bottom_sheet.dart';

class InventoryToolsScreen extends ConsumerWidget {
  const InventoryToolsScreen({super.key});

  void _openTransactionSheet(BuildContext context, TransactionType type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TransactionBottomSheet(transactionType: type),
    );
  }

  void _openCountAdjustmentSheet(
    BuildContext context,
    InventoryCountCategory category,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => InventoryCountAdjustmentSheet(category: category),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory Tools')),
      body: ResponsiveContent(
        padding: EdgeInsets.all(context.pageHorizontalPadding),
        child: ListView(
          children: [
            Text(
              'Advanced inventory actions for reconciliation and corrections.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 20),
            Text(
              'Bottle Adjustments',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _ToolButton(
              label: 'Add Filled Bottles',
              icon: Icons.add_circle_outline,
              color: Colors.teal,
              onTap: () => _openTransactionSheet(context, TransactionType.added),
            ),
            _ToolButton(
              label: 'Adjust Filled Bottles',
              icon: Icons.tune_outlined,
              color: Colors.teal.shade700,
              onTap: () => _openCountAdjustmentSheet(
                context,
                InventoryCountCategory.filled,
              ),
            ),
            _ToolButton(
              label: 'Add Empty Bottles',
              icon: Icons.inbox_outlined,
              color: Colors.blueGrey,
              onTap: () =>
                  _openTransactionSheet(context, TransactionType.emptyAdded),
            ),
            _ToolButton(
              label: 'Adjust Empty Bottles',
              icon: Icons.tune_outlined,
              color: Colors.blueGrey.shade700,
              onTap: () => _openCountAdjustmentSheet(
                context,
                InventoryCountCategory.empty,
              ),
            ),
            _ToolButton(
              label: 'Bottle Correction',
              icon: Icons.edit_outlined,
              color: AppColors.warning,
              onTap: () => _openTransactionSheet(
                context,
                TransactionType.customerAdjustment,
              ),
            ),
            _ToolButton(
              label: 'Damaged Bottles',
              icon: Icons.broken_image_outlined,
              color: AppColors.error,
              onTap: () =>
                  _openTransactionSheet(context, TransactionType.damaged),
            ),
            _ToolButton(
              label: 'Missing Bottles',
              icon: Icons.help_outline,
              color: AppColors.missing,
              onTap: () =>
                  _openTransactionSheet(context, TransactionType.missing),
            ),
            _ToolButton(
              label: 'Donate Bottles',
              icon: Icons.volunteer_activism_outlined,
              color: Colors.deepPurple,
              onTap: () =>
                  _openTransactionSheet(context, TransactionType.donation),
            ),
            _ToolButton(
              label: 'Inventory Adjustment',
              icon: Icons.fact_check_outlined,
              color: AppColors.primary,
              onTap: () => context.push('/inventory/audit'),
            ),
            const SizedBox(height: 20),
            Text(
              'Audit & Reconciliation',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _ToolButton(
              label: 'Audit Inventory',
              icon: Icons.fact_check_outlined,
              color: AppColors.primary,
              onTap: () => context.push('/inventory/audit'),
            ),
            _ToolButton(
              label: 'Audit History',
              icon: Icons.history_toggle_off,
              color: AppColors.primary,
              onTap: () => context.push('/inventory/audit-history'),
            ),
            _ToolButton(
              label: 'Adjustment History',
              icon: Icons.tune_outlined,
              color: Colors.indigo,
              onTap: () => context.push('/inventory/adjustments'),
            ),
            _ToolButton(
              label: 'Bottle Reconciliation History',
              icon: Icons.balance_outlined,
              color: AppColors.warning,
              onTap: () => context.push('/inventory/business-timeline'),
            ),
            _ToolButton(
              label: 'Inventory Settings',
              icon: Icons.settings_outlined,
              color: AppColors.primary,
              onTap: () => context.push('/settings/inventory'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ToolButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18, color: color),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }
}
