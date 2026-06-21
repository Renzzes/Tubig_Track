import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/inventory_audit.dart';
import '../providers/inventory_provider.dart';

class InventoryAuditScreen extends ConsumerStatefulWidget {
  const InventoryAuditScreen({super.key});

  @override
  ConsumerState<InventoryAuditScreen> createState() => _InventoryAuditScreenState();
}

class _InventoryAuditScreenState extends ConsumerState<InventoryAuditScreen> {
  final _physicalCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _physicalCtrl.dispose();
    _reasonCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  int _difference(int systemCount) {
    final physical = int.tryParse(_physicalCtrl.text) ?? systemCount;
    return physical - systemCount;
  }

  Future<void> _saveBalanced(int physical) async {
    await ref.read(inventoryRepositoryProvider).performAudit(
          physicalCount: physical,
          action: InventoryAuditAction.balanced,
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        );
  }

  Future<void> _saveDiscrepancy(int physical, int difference) async {
    final isNegative = difference < 0;
    final action = await showDialog<InventoryAuditAction>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          isNegative ? 'Inventory Discrepancy Detected' : 'Inventory Surplus Detected',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isNegative
                  ? '${difference.abs()} bottles are missing.'
                  : '$difference additional bottles found.',
            ),
            const SizedBox(height: 8),
            Text(
              isNegative
                  ? 'Choose action: Mark as Missing, Create Adjustment, or Cancel.'
                  : 'Choose action: Inventory Adjustment or Cancel.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, InventoryAuditAction.cancelled),
            child: const Text('Cancel'),
          ),
          if (isNegative)
            FilledButton(
              onPressed: () => Navigator.pop(ctx, InventoryAuditAction.markedMissing),
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('Mark as Missing'),
            ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, InventoryAuditAction.adjustment),
            child: const Text('Create Adjustment'),
          ),
        ],
      ),
    );
    if (action == null || action == InventoryAuditAction.cancelled) return;

    await ref.read(inventoryRepositoryProvider).performAudit(
          physicalCount: physical,
          action: action,
          adjustmentReason:
              _reasonCtrl.text.trim().isEmpty ? null : _reasonCtrl.text.trim(),
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        );
  }

  Future<void> _saveAudit(int systemCount) async {
    final physical = int.tryParse(_physicalCtrl.text);
    if (physical == null || physical < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid physical count.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final difference = physical - systemCount;
      if (difference == 0) {
        await _saveBalanced(physical);
      } else {
        await _saveDiscrepancy(physical, difference);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inventory audit saved.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Audit failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(inventorySummaryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory Audit')),
      body: summaryAsync.when(
        data: (summary) {
          final systemCount = summary.filledBottlesAvailable;
          if (_physicalCtrl.text.isEmpty) {
            _physicalCtrl.text = '$systemCount';
          }
          final diff = _difference(systemCount);
          final balanced = diff == 0;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _AuditValueCard(
                label: 'System Inventory',
                valueLabel: 'Filled Bottles Available',
                value: systemCount,
                color: AppColors.primary,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _physicalCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Physical Count',
                  hintText: 'Enter actual count',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              _AuditValueCard(
                label: 'Difference',
                valueLabel: 'Bottles',
                value: diff,
                color: balanced
                    ? AppColors.success
                    : diff < 0
                        ? AppColors.error
                        : AppColors.warning,
                signed: true,
              ),
              const SizedBox(height: 12),
              if (balanced)
                const ListTile(
                  leading: Icon(Icons.check_circle_outline, color: AppColors.success),
                  title: Text('Inventory Balanced'),
                  subtitle: Text('No action required.'),
                )
              else
                ListTile(
                  leading: Icon(
                    diff < 0 ? Icons.warning_amber_rounded : Icons.add_circle_outline,
                    color: diff < 0 ? AppColors.error : AppColors.warning,
                  ),
                  title: Text(
                    diff < 0
                        ? 'Inventory Discrepancy Detected'
                        : 'Inventory Surplus Detected',
                  ),
                  subtitle: Text(
                    diff < 0
                        ? '${diff.abs()} bottles are missing.'
                        : '$diff additional bottles found.',
                  ),
                ),
              const SizedBox(height: 8),
              TextField(
                controller: _reasonCtrl,
                decoration: const InputDecoration(
                  labelText: 'Reason (for adjustments)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _notesCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _saving ? null : () => _saveAudit(systemCount),
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Audit'),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _AuditValueCard extends StatelessWidget {
  final String label;
  final String valueLabel;
  final int value;
  final Color color;
  final bool signed;

  const _AuditValueCard({
    required this.label,
    required this.valueLabel,
    required this.value,
    required this.color,
    this.signed = false,
  });

  @override
  Widget build(BuildContext context) {
    final valueText = signed && value >= 0 ? '+$value' : '$value';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(
            valueText,
            style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 28),
          ),
          Text(valueLabel, style: TextStyle(color: color.withValues(alpha: 0.8))),
        ],
      ),
    );
  }
}
