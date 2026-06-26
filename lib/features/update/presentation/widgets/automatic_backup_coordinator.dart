import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/automatic_backup_service.dart';
import '../../../../core/services/backup_event_log_service.dart';
import '../../../../core/services/backup_notification_queue.dart';
import '../../../settings/presentation/widgets/backup_notification_presenter.dart';
import '../providers/backup_monitoring_provider.dart';
import '../providers/update_provider.dart';

/// Runs daily/weekly automatic backups when the app starts or resumes.
class AutomaticBackupCoordinator extends ConsumerStatefulWidget {
  final Widget child;

  const AutomaticBackupCoordinator({super.key, required this.child});

  @override
  ConsumerState<AutomaticBackupCoordinator> createState() =>
      _AutomaticBackupCoordinatorState();
}

class _AutomaticBackupCoordinatorState
    extends ConsumerState<AutomaticBackupCoordinator>
    with WidgetsBindingObserver {
  static bool _startupScheduled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduleRun(fromStartup: true);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _scheduleRun(fromResume: true);
    }
  }

  Future<void> _scheduleRun({
    bool fromStartup = false,
    bool fromResume = false,
  }) async {
    if (!mounted) return;

    if (fromStartup) {
      if (_startupScheduled) return;
      _startupScheduled = true;
      await Future.delayed(const Duration(seconds: 4));
      if (!mounted) return;
    } else if (!fromResume) {
      return;
    }

    try {
      final repository = ref.read(backupRepositoryProvider);
      final result = await AutomaticBackupService.instance.maybeRunScheduledBackup(
        repository,
      );

      if (!mounted) return;

      if (result != null) {
        await BackupEventLogService.instance.record(
          type: BackupEventType.automaticBackup,
          title: result.verification.passed
              ? 'Automatic Backup Completed'
              : 'Automatic Backup (Verification Failed)',
          success: result.verification.passed,
          relatedPath: result.path,
        );
        if (!result.verification.passed) {
          await BackupEventLogService.instance.record(
            type: BackupEventType.verification,
            title: 'Backup Verification Failed',
            success: false,
            relatedPath: result.path,
          );
        }
        invalidateBackupMonitoring(ref);
        if (result.verification.passed) {
          await BackupNotificationPresenter.queueAutomaticBackupSuccess(
            result.path,
          );
        } else {
          await BackupNotificationQueue.instance.enqueue(
            BackupNotificationPayload(
              kind: BackupNotificationKind.verificationFailed,
              title: 'Backup Verification Failed',
              body: 'Please create another backup.',
              backupPath: result.path,
              createdAt: DateTime.now(),
            ),
          );
        }
      }
    } catch (e) {
      await BackupEventLogService.instance.record(
        type: BackupEventType.automaticBackup,
        title: 'Automatic Backup Failed',
        success: false,
        detail: e.toString(),
      );
      await BackupNotificationPresenter.queueAutomaticBackupFailed(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
