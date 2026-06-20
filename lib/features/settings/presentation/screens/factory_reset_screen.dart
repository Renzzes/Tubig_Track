import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_refresh.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/settings_provider.dart';

/// Confirmation screen — user must type RESET TUBIGTRACK to enable Reset.
class FactoryResetConfirmScreen extends ConsumerStatefulWidget {
  const FactoryResetConfirmScreen({super.key});

  static const confirmPhrase = 'RESET TUBIGTRACK';

  @override
  ConsumerState<FactoryResetConfirmScreen> createState() =>
      _FactoryResetConfirmScreenState();
}

class _FactoryResetConfirmScreenState
    extends ConsumerState<FactoryResetConfirmScreen> {
  final _confirmCtrl = TextEditingController();
  bool _isResetting = false;
  OperationalDataCounts? _counts;

  bool get _canReset =>
      _confirmCtrl.text == FactoryResetConfirmScreen.confirmPhrase;

  @override
  void initState() {
    super.initState();
    _confirmCtrl.addListener(() => setState(() {}));
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    final counts =
        await ref.read(settingsRepositoryProvider).getOperationalDataCounts();
    if (mounted) setState(() => _counts = counts);
  }

  @override
  void dispose() {
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _performReset() async {
    if (!_canReset || _isResetting) return;
    setState(() => _isResetting = true);
    try {
      await ref.read(settingsRepositoryProvider).factoryReset();
      invalidateAllDataProviders(ref);
      if (mounted) {
        context.go('/settings/factory-reset/complete');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reset failed: $e')),
        );
        setState(() => _isResetting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Reset')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 56,
              color: Colors.orange[700],
            ),
            const SizedBox(height: 16),
            const Text(
              'Final Confirmation',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            if (_counts != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'You are about to delete:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    _CountRow('Customers', _counts!.customers),
                    _CountRow('Deliveries', _counts!.deliveries),
                    _CountRow('Payments', _counts!.payments),
                    _CountRow('Expenses', _counts!.expenses),
                    _CountRow('Supply Purchases', _counts!.supplyPurchases),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              'Type ${FactoryResetConfirmScreen.confirmPhrase} below to permanently erase all operational data. '
              'This cannot be undone.',
              style: TextStyle(color: Colors.grey[700], height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _confirmCtrl,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Type ${FactoryResetConfirmScreen.confirmPhrase}',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.edit_outlined),
              ),
            ),
            const Spacer(),
            FilledButton(
              onPressed: _canReset && !_isResetting ? _performReset : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
                disabledBackgroundColor: Colors.grey[300],
                minimumSize: const Size.fromHeight(48),
              ),
              child: _isResetting
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Reset Application'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _isResetting ? null : () => context.pop(),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Success screen shown after factory reset completes.
class FactoryResetCompleteScreen extends ConsumerWidget {
  const FactoryResetCompleteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 72,
                color: Colors.green[600],
              ),
              const SizedBox(height: 24),
              const Text(
                'Reset Complete',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'All operational data has been removed.\n\n'
                'The application is ready for a new business cycle.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              FilledButton(
                onPressed: () {
                  invalidateAllDataProviders(ref);
                  context.go('/');
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Restart App'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountRow extends StatelessWidget {
  final String label;
  final int count;

  const _CountRow(this.label, this.count);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            count.toString(),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

/// Shows the initial warning dialog. Returns the user's choice.
enum FactoryResetWarningAction { createBackup, continueReset, cancel }

Future<FactoryResetWarningAction?> showFactoryResetWarningDialog(
  BuildContext context,
) {
  return showDialog<FactoryResetWarningAction>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      icon: Icon(Icons.warning_amber_rounded, color: Colors.orange[700], size: 36),
      title: const Text('Reset TubigTrack'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'This action will permanently delete:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...[
              'Customers',
              'Deliveries',
              'Payments',
              'Inventory',
              'Expenses',
              'Savings',
              'Reports',
              'Dispenser Sales',
              'Supply Purchases',
              'Transaction History',
            ].map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(child: Text(item)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This action cannot be undone.',
              style: TextStyle(
                color: Colors.red[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, FactoryResetWarningAction.cancel),
          child: const Text('Cancel'),
        ),
        OutlinedButton(
          onPressed: () =>
              Navigator.pop(ctx, FactoryResetWarningAction.createBackup),
          child: const Text('Create Backup'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.error),
          onPressed: () =>
              Navigator.pop(ctx, FactoryResetWarningAction.continueReset),
          child: const Text('Continue'),
        ),
      ],
    ),
  );
}

enum FactoryResetBackupPromptAction { backupAndReset, resetAnyway, cancel }

Future<FactoryResetBackupPromptAction?> showNoBackupPromptDialog(
  BuildContext context,
) {
  return showDialog<FactoryResetBackupPromptAction>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: const Text('No Backup Found'),
      content: const Text(
        'No database backup was found on this device. '
        'We recommend creating a backup before resetting.',
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.pop(ctx, FactoryResetBackupPromptAction.cancel),
          child: const Text('Cancel'),
        ),
        OutlinedButton(
          onPressed: () =>
              Navigator.pop(ctx, FactoryResetBackupPromptAction.resetAnyway),
          child: const Text('Reset Anyway'),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.pop(ctx, FactoryResetBackupPromptAction.backupAndReset),
          child: const Text('Backup & Reset'),
        ),
      ],
    ),
  );
}

/// Entry point from Settings — orchestrates the full reset flow.
Future<void> startFactoryResetFlow(BuildContext context, WidgetRef ref) async {
  final warningAction = await showFactoryResetWarningDialog(context);
  if (warningAction == null ||
      warningAction == FactoryResetWarningAction.cancel) {
    return;
  }

  if (warningAction == FactoryResetWarningAction.createBackup) {
    try {
      final path =
          await ref.read(settingsRepositoryProvider).backupDatabase();
      if (context.mounted) {
        await Share.shareXFiles(
          [XFile(path)],
          text: 'TubigTrack Database Backup',
        );
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup created successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup failed: $e')),
        );
      }
    }
    return;
  }

  final hasBackup = await ref.read(settingsRepositoryProvider).hasAnyBackup();
  if (!hasBackup && context.mounted) {
    final backupAction = await showNoBackupPromptDialog(context);
    if (backupAction == null ||
        backupAction == FactoryResetBackupPromptAction.cancel) {
      return;
    }
    if (backupAction == FactoryResetBackupPromptAction.backupAndReset) {
      try {
        await ref.read(settingsRepositoryProvider).backupDatabase();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Backup created')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Backup failed: $e')),
          );
        }
        return;
      }
    }
  }

  if (context.mounted) {
    context.push('/settings/factory-reset/confirm');
  }
}
