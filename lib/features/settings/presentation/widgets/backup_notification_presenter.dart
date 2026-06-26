import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/backup_notification_queue.dart';
import '../../../../core/services/backup_verification_service.dart';
import '../../../../core/services/data_storage_service.dart';

class BackupNotificationPresenter {
  BackupNotificationPresenter._();

  static Future<void> showPendingIfAny(BuildContext context) async {
    final pending = await BackupNotificationQueue.instance.peek();
    if (pending == null || !context.mounted) return;
    await BackupNotificationQueue.instance.clear();
    if (!context.mounted) return;

    switch (pending.kind) {
      case BackupNotificationKind.automaticBackupSuccess:
        await showAutomaticBackupSuccess(
          context,
          backupPath: pending.backupPath,
        );
      case BackupNotificationKind.manualBackupSuccess:
        if (pending.backupPath != null) {
          await showManualBackupSuccess(
            context,
            VerifiedBackupResult(
              path: pending.backupPath!,
              verification: const BackupVerificationResult(
                passed: true,
                fileExists: true,
                databaseOpened: true,
                integrityCheckPassed: true,
                requiredTablesPresent: true,
              ),
            ),
          );
        }
      case BackupNotificationKind.verificationFailed:
        await showVerificationFailed(context, backupPath: pending.backupPath);
      case BackupNotificationKind.automaticBackupFailed:
        await showAutomaticBackupFailed(
          context,
          reason: pending.body,
        );
      case BackupNotificationKind.storageChanged:
        await showStorageChanged(
          context,
          location: pending.storageLocation ?? pending.body,
        );
    }
  }

  static Future<void> showAutomaticBackupSuccess(
    BuildContext context, {
    String? backupPath,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Expanded(child: Text('Automatic Backup Completed')),
          ],
        ),
        content: const Text(
          'Database verified successfully.\n\nSaved to:\n\nTubigTrack/Backups',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Dismiss'),
          ),
          if (backupPath != null)
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.push('/recovery-center');
              },
              child: const Text('View Backup'),
            ),
        ],
      ),
    );
  }

  static Future<void> showManualBackupSuccess(
    BuildContext context,
    VerifiedBackupResult result,
  ) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Expanded(child: Text('Backup Created')),
          ],
        ),
        content: const Text(
          'Integrity Check Passed.\n\nReady for restore.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Dismiss'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.push('/recovery-center');
            },
            child: const Text('View Backup'),
          ),
        ],
      ),
    );
  }

  static Future<void> showVerificationFailed(
    BuildContext context, {
    String? backupPath,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Expanded(child: Text('Backup Created')),
          ],
        ),
        content: const Text(
          'Integrity verification failed.\n\nPlease create another backup.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }

  static Future<void> showAutomaticBackupFailed(
    BuildContext context, {
    required String reason,
    VoidCallback? onFixStorage,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Expanded(child: Text('Automatic Backup Failed')),
          ],
        ),
        content: Text('Reason:\n\n$reason'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Dismiss'),
          ),
          if (onFixStorage != null)
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                onFixStorage();
              },
              child: const Text('Fix Storage'),
            ),
        ],
      ),
    );
  }

  static Future<void> showStorageChanged(
    BuildContext context, {
    required String location,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Expanded(child: Text('Storage Location Updated')),
          ],
        ),
        content: Text(
          'Future backups will be stored in:\n\n$location',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }

  static Future<void> queueAutomaticBackupSuccess(String backupPath) {
    return BackupNotificationQueue.instance.enqueue(
      BackupNotificationPayload(
        kind: BackupNotificationKind.automaticBackupSuccess,
        title: 'Automatic Backup Completed',
        body: 'Database verified successfully.',
        backupPath: backupPath,
        createdAt: DateTime.now(),
      ),
    );
  }

  static Future<void> queueAutomaticBackupFailed(String reason) {
    return BackupNotificationQueue.instance.enqueue(
      BackupNotificationPayload(
        kind: BackupNotificationKind.automaticBackupFailed,
        title: 'Automatic Backup Failed',
        body: reason,
        createdAt: DateTime.now(),
      ),
    );
  }

  static Future<void> queueStorageChanged(String location) {
    return BackupNotificationQueue.instance.enqueue(
      BackupNotificationPayload(
        kind: BackupNotificationKind.storageChanged,
        title: 'Storage Location Updated',
        body: location,
        storageLocation: location,
        createdAt: DateTime.now(),
      ),
    );
  }
}
