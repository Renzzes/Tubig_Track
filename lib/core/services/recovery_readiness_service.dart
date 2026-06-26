import 'package:intl/intl.dart';

import 'automatic_backup_service.dart';
import 'backup_event_log_service.dart';
import 'data_storage_service.dart';
import 'storage_test_service.dart';

enum RecoveryOverallStatus {
  excellent,
  good,
  needsAttention,
  critical,
}

class RecoveryReadinessIssue {
  final String message;
  final String recommendation;

  const RecoveryReadinessIssue({
    required this.message,
    required this.recommendation,
  });
}

class RecoveryReadinessReport {
  final bool automaticBackupEnabled;
  final bool latestBackupVerified;
  final bool restoreTested;
  final bool storageHealthy;
  final RecoveryOverallStatus overallStatus;
  final String overallLabel;
  final List<RecoveryReadinessIssue> issues;

  const RecoveryReadinessReport({
    required this.automaticBackupEnabled,
    required this.latestBackupVerified,
    required this.restoreTested,
    required this.storageHealthy,
    required this.overallStatus,
    required this.overallLabel,
    this.issues = const [],
  });
}

class RecoveryReadinessService {
  RecoveryReadinessService._();

  static final RecoveryReadinessService instance = RecoveryReadinessService._();

  Future<RecoveryReadinessReport> evaluate() async {
    final schedule = await AutomaticBackupService.instance.loadSchedule();
    final automaticBackupEnabled = schedule != AutomaticBackupSchedule.disabled;

    final latestBackup = await BackupEventLogService.instance.latestBackupEvent();
    final latestBackupVerified =
        latestBackup?.success == true && latestBackup != null;

    final lastTest = await StorageTestService.instance.loadLastTest();
    final storageHealthy = lastTest?.allPassed ?? false;

    final events = await BackupEventLogService.instance.listEvents(limit: 100);
    final restoreTested = events.any(
      (event) =>
          event.type == BackupEventType.restore && event.success ||
          event.type == BackupEventType.storageTest && event.success,
    );

    final issues = <RecoveryReadinessIssue>[];

    if (!automaticBackupEnabled) {
      issues.add(
        const RecoveryReadinessIssue(
          message: 'Automatic Backup Disabled',
          recommendation: 'Enable Daily or Weekly automatic backups.',
        ),
      );
    }

    if (latestBackup == null) {
      issues.add(
        const RecoveryReadinessIssue(
          message: 'No backup recorded yet.',
          recommendation: 'Create a manual backup.',
        ),
      );
    } else if (latestBackup.success == false) {
      issues.add(
        const RecoveryReadinessIssue(
          message: 'Latest backup failed integrity verification.',
          recommendation: 'Create a new backup immediately.',
        ),
      );
    } else if (DateTime.now().difference(latestBackup.occurredAt).inDays >= 14) {
      issues.add(
        const RecoveryReadinessIssue(
          message: 'No verified backup created within 14 days.',
          recommendation: 'Create a manual backup.',
        ),
      );
    }

    if (!storageHealthy) {
      final storage = DataStorageService.instance;
      if (!storage.isPublicStorage) {
        issues.add(
          const RecoveryReadinessIssue(
            message: 'Storage folder may be unavailable or private.',
            recommendation: 'Choose another folder or run a storage test.',
          ),
        );
      } else {
        issues.add(
          const RecoveryReadinessIssue(
            message: 'Storage health check has not passed.',
            recommendation: 'Run a storage test from the Backup Dashboard.',
          ),
        );
      }
    }

    final overallStatus = _overallStatus(
      issues: issues,
      latestBackupVerified: latestBackupVerified,
      storageHealthy: storageHealthy,
      hasAnyBackup: latestBackup != null,
    );

    return RecoveryReadinessReport(
      automaticBackupEnabled: automaticBackupEnabled,
      latestBackupVerified: latestBackupVerified,
      restoreTested: restoreTested,
      storageHealthy: storageHealthy,
      overallStatus: overallStatus,
      overallLabel: _labelFor(overallStatus),
      issues: issues,
    );
  }

  RecoveryOverallStatus _overallStatus({
    required List<RecoveryReadinessIssue> issues,
    required bool latestBackupVerified,
    required bool storageHealthy,
    required bool hasAnyBackup,
  }) {
    if (!hasAnyBackup || !latestBackupVerified) {
      return RecoveryOverallStatus.critical;
    }
    if (!storageHealthy) {
      return RecoveryOverallStatus.critical;
    }
    if (issues.any((issue) => issue.message.contains('failed integrity'))) {
      return RecoveryOverallStatus.critical;
    }
    if (issues.isEmpty) {
      return RecoveryOverallStatus.excellent;
    }
    if (issues.length == 1 &&
        issues.first.message.contains('Automatic Backup Disabled')) {
      return RecoveryOverallStatus.good;
    }
    return RecoveryOverallStatus.needsAttention;
  }

  String _labelFor(RecoveryOverallStatus status) {
    switch (status) {
      case RecoveryOverallStatus.excellent:
        return 'Excellent';
      case RecoveryOverallStatus.good:
        return 'Good';
      case RecoveryOverallStatus.needsAttention:
        return 'Needs Attention';
      case RecoveryOverallStatus.critical:
        return 'Critical';
    }
  }
}

class BackupDashboardSnapshot {
  final DateTime? lastBackupAt;
  final String lastBackupLabel;
  final AutomaticBackupSchedule schedule;
  final String scheduleLabel;
  final bool latestBackupVerified;
  final String storageLocation;
  final int backupsStored;
  final String storageUsed;
  final RecoveryReadinessReport readiness;

  const BackupDashboardSnapshot({
    required this.lastBackupAt,
    required this.lastBackupLabel,
    required this.schedule,
    required this.scheduleLabel,
    required this.latestBackupVerified,
    required this.storageLocation,
    required this.backupsStored,
    required this.storageUsed,
    required this.readiness,
  });
}

class BackupDashboardService {
  BackupDashboardService._();

  static final BackupDashboardService instance = BackupDashboardService._();

  Future<BackupDashboardSnapshot> buildSnapshot() async {
    final storage = DataStorageService.instance;
    final summary = await storage.getStorageSummary();
    final schedule = await AutomaticBackupService.instance.loadSchedule();
    final latestBackup = await BackupEventLogService.instance.latestBackupEvent();
    final readiness = await RecoveryReadinessService.instance.evaluate();

    return BackupDashboardSnapshot(
      lastBackupAt: latestBackup?.occurredAt,
      lastBackupLabel: _formatLastBackup(latestBackup?.occurredAt),
      schedule: schedule,
      scheduleLabel: _scheduleLabel(schedule),
      latestBackupVerified: latestBackup?.success ?? false,
      storageLocation: summary.locationLabel,
      backupsStored: summary.backupCount,
      storageUsed: storage.formatBytes(summary.totalBytes),
      readiness: readiness,
    );
  }

  String _formatLastBackup(DateTime? when) {
    if (when == null) return 'Never';
    final now = DateTime.now();
    final time = DateFormat('h:mm a').format(when);
    if (when.year == now.year &&
        when.month == now.month &&
        when.day == now.day) {
      return 'Today · $time';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (when.year == yesterday.year &&
        when.month == yesterday.month &&
        when.day == yesterday.day) {
      return 'Yesterday · $time';
    }
    return '${DateFormat('MMM d, yyyy').format(when)} · $time';
  }

  String _scheduleLabel(AutomaticBackupSchedule schedule) {
    switch (schedule) {
      case AutomaticBackupSchedule.disabled:
        return 'Disabled';
      case AutomaticBackupSchedule.daily:
        return 'Daily';
      case AutomaticBackupSchedule.weekly:
        return 'Weekly';
      case AutomaticBackupSchedule.beforeAppUpdates:
        return 'Before App Updates';
    }
  }
}
