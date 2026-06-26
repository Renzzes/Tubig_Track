import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/backup_event_log_service.dart';
import '../../../../core/services/recovery_readiness_service.dart';
import 'update_provider.dart';

export '../../../../core/services/recovery_readiness_service.dart'
    show BackupDashboardSnapshot, RecoveryReadinessReport;

final backupDashboardProvider =
    FutureProvider<BackupDashboardSnapshot>((ref) async {
  return BackupDashboardService.instance.buildSnapshot();
});

final backupEventHistoryProvider =
    FutureProvider<List<BackupEvent>>((ref) async {
  return BackupEventLogService.instance.listEvents();
});

final recoveryReadinessProvider =
    FutureProvider<RecoveryReadinessReport>((ref) async {
  return RecoveryReadinessService.instance.evaluate();
});

void invalidateBackupMonitoring(WidgetRef ref) {
  ref.invalidate(backupDashboardProvider);
  ref.invalidate(backupEventHistoryProvider);
  ref.invalidate(recoveryReadinessProvider);
  ref.invalidate(storageSummaryProvider);
  ref.invalidate(recoveryFilesProvider);
  ref.invalidate(availableBackupsProvider);
}
