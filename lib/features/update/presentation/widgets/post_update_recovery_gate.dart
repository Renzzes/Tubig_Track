import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/database_restore_service.dart';
import '../../../../core/services/backup_event_log_service.dart';
import '../../../settings/presentation/widgets/backup_restore_flow.dart';
import '../providers/backup_monitoring_provider.dart';
import '../providers/update_provider.dart';

/// Checks for missing database on startup and offers restore from pre-update backup.
class PostUpdateRecoveryGate extends ConsumerStatefulWidget {
  final Widget child;

  const PostUpdateRecoveryGate({super.key, required this.child});

  @override
  ConsumerState<PostUpdateRecoveryGate> createState() =>
      _PostUpdateRecoveryGateState();
}

class _PostUpdateRecoveryGateState extends ConsumerState<PostUpdateRecoveryGate> {
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkDatabase());
  }

  Future<void> _checkDatabase() async {
    if (_checked) return;
    _checked = true;

    final backupRepo = ref.read(backupRepositoryProvider);
    final exists = await backupRepo.databaseExists();
    if (exists || !mounted) return;

    final backup = await backupRepo.findLatestPreUpdateBackup();
    if (backup == null || !mounted) return;

    await _offerRestore(backup.path);
  }

  Future<void> _offerRestore(String backupPath) async {
    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Backup Found'),
        content: const Text(
          'Your database was not found after the update.\n\n'
          'Restore from the most recent pre-update backup?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Skip'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    await _performRestore(backupPath);
  }

  Future<void> _performRestore(String backupPath) async {
    if (!mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PopScope(
        canPop: false,
        child: Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Restoring backup…'),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final result = await restoreDatabaseFromBackup(ref, backupPath);

    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    if (!mounted) return;

    if (result.success) {
      invalidateBackupMonitoring(ref);
      await BackupEventLogService.instance.record(
        type: BackupEventType.restore,
        title: 'Database Restored',
        success: true,
        relatedPath: backupPath,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backup restored successfully')),
      );
      context.go('/');
      return;
    }

    if (result.rollbackFailed && result.safetyCopyPath != null) {
      await showCriticalRestoreErrorDialog(
        context,
        safetyCopyPath: result.safetyCopyPath!,
      );
      return;
    }

    await showRestoreFailedDialog(
      context,
      ref,
      backupPath: backupPath,
      errorMessage: result.errorMessage ?? 'Restore failed',
      onRetry: () => _performRestore(backupPath),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
