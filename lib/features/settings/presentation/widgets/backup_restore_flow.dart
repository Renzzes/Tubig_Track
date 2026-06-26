import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;

import '../../../../core/database/backup_metadata.dart';
import '../../../../core/database/database_restore_service.dart';
import '../../../../core/services/backup_event_log_service.dart';
import '../../../update/presentation/providers/backup_monitoring_provider.dart';
import '../../../update/presentation/providers/update_provider.dart';
import '../../../update/presentation/widgets/backup_details_dialog.dart';

/// Shared restore flow with compatibility checks, migration prompts, and logging.
Future<void> runBackupRestoreFlow(
  BuildContext context,
  WidgetRef ref,
  String backupPath,
) async {
  final repo = ref.read(backupRepositoryProvider);
  final compatibility = await repo.checkCompatibility(backupPath);
  if (!context.mounted) return;

  switch (compatibility.status) {
    case BackupCompatibilityStatus.compatible:
      final ok = await _showStandardRestoreDialog(context);
      if (ok != true || !context.mounted) return;
    case BackupCompatibilityStatus.migratable:
      final ok = await _showMigrationRestoreDialog(context, compatibility);
      if (ok != true || !context.mounted) return;
    case BackupCompatibilityStatus.unsupported:
    case BackupCompatibilityStatus.newerThanApp:
      await _showUnsupportedDialog(context, ref, compatibility);
      return;
    case BackupCompatibilityStatus.unknown:
      final ok = await _showUnknownSchemaDialog(context);
      if (ok != true || !context.mounted) return;
  }

  if (!context.mounted) return;
  await _runRestoreWithProgress(context, ref, backupPath);
}

Future<void> _runRestoreWithProgress(
  BuildContext context,
  WidgetRef ref,
  String backupPath,
) async {
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

  if (context.mounted) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  if (!context.mounted) return;

  if (result.success) {
    invalidateBackupMonitoring(ref);

    await BackupEventLogService.instance.record(
      type: BackupEventType.restore,
      title: 'Database Restored',
      success: true,
      detail: p.basename(backupPath),
      relatedPath: backupPath,
    );

    if (result.migration != null && result.migration!.success) {
      await BackupEventLogService.instance.record(
        type: BackupEventType.migration,
        title: 'Backup Migrated',
        detail:
            'Steps: ${result.migration!.migrationStepsExecuted.join(', ')}',
        relatedPath: backupPath,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Database restored successfully')),
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
    onRetry: () => _runRestoreWithProgress(context, ref, backupPath),
  );
}

Future<bool?> _showStandardRestoreDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Restore Database?'),
      content: const Text(
        'Current data will be replaced.\n\n'
        'It is recommended to create a backup first.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Restore'),
        ),
      ],
    ),
  );
}

Future<bool?> _showMigrationRestoreDialog(
  BuildContext context,
  BackupCompatibilityResult compatibility,
) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Backup Detected'),
      content: Text(
        'This backup was created with:\n\n'
        'TubigTrack v${compatibility.backupAppVersion}\n'
        'Database Schema ${compatibility.backupSchema}\n\n'
        'Your app will automatically upgrade it to the latest version '
        '(Schema ${compatibility.currentSchema}).\n\n'
        'No business data will be lost.\n\n'
        'Continue?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Restore'),
        ),
      ],
    ),
  );
}

Future<void> _showUnsupportedDialog(
  BuildContext context,
  WidgetRef ref,
  BackupCompatibilityResult compatibility,
) async {
  final action = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Cannot Restore Automatically'),
      content: Text(
        'This backup cannot be restored automatically.\n\n'
        'Reason:\n${compatibility.reason ?? 'Unsupported backup format.'}\n\n'
        'Your original backup remains safe.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, 'cancel'),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, 'details'),
          child: const Text('View Backup Information'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, 'readonly'),
          child: const Text('Export Data (Read Only)'),
        ),
      ],
    ),
  );

  if (!context.mounted) return;

  switch (action) {
    case 'details':
      await showBackupDetailsDialog(
        context,
        ref,
        backupPath: compatibility.backupPath,
      );
    case 'readonly':
      context.push('/read-only-recovery', extra: compatibility.backupPath);
    case 'cancel':
    case null:
      break;
  }
}

Future<bool?> _showUnknownSchemaDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Unknown Backup Schema'),
      content: const Text(
        'Could not read the schema version from this backup.\n\n'
        'Restore will be attempted, but if migration fails your current '
        'database will not be changed.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Try Restore'),
        ),
      ],
    ),
  );
}

Future<void> showRestoreFailedDialog(
  BuildContext context,
  WidgetRef ref, {
  required String backupPath,
  required String errorMessage,
  required VoidCallback onRetry,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Restore Failed'),
      content: Text(
        'The backup could not be restored.\n\n'
        'Reason:\n\n$errorMessage\n\n'
        'Your existing database has not been modified.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Close'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
            context.push('/recovery-center');
          },
          child: const Text('Open Recovery Center'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(ctx);
            onRetry();
          },
          child: const Text('Retry'),
        ),
      ],
    ),
  );
}

Future<void> showCriticalRestoreErrorDialog(
  BuildContext context, {
  required String safetyCopyPath,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Critical Restore Error'),
      content: Text(
        'TubigTrack could not automatically restore your previous database.\n\n'
        'Your safety backup has been preserved.\n\n'
        'Location:\n\n$safetyCopyPath\n\n'
        'Please restore it manually from Recovery Center.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Close'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(ctx);
            context.push('/recovery-center');
          },
          child: const Text('Open Recovery Center'),
        ),
      ],
    ),
  );
}
