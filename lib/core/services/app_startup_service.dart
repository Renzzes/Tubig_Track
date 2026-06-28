import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../database/app_database.dart';
import 'backup_event_log_service.dart';
import 'backup_notification_queue.dart';
import 'backup_retention_service.dart';
import 'data_storage_service.dart';
import 'notification_service.dart';
import 'recovery_readiness_service.dart';
import 'startup_logger.dart';
import 'storage_test_service.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/presentation/widgets/backup_notification_presenter.dart';
import '../../features/update/presentation/providers/backup_monitoring_provider.dart';
import '../../features/update/presentation/providers/update_provider.dart';
import 'automatic_backup_service.dart';

class StartupStepFailure {
  final String step;
  final Object error;
  final StackTrace? stackTrace;
  final Duration elapsed;

  const StartupStepFailure({
    required this.step,
    required this.error,
    this.stackTrace,
    required this.elapsed,
  });
}

class StartupResult {
  final bool success;
  final bool safeMode;
  final Duration totalElapsed;
  final List<StartupStepFailure> failures;
  final String? blockingStep;

  const StartupResult({
    required this.success,
    this.safeMode = false,
    required this.totalElapsed,
    this.failures = const [],
    this.blockingStep,
  });
}

/// Orchestrates app launch: essential steps block splash; everything else is background.
class AppStartupService {
  AppStartupService._();

  static final AppStartupService instance = AppStartupService._();

  static const startupTimeout = Duration(seconds: 10);
  static const backgroundStepTimeout = Duration(seconds: 8);

  AppDatabase? _database;
  bool _safeMode = false;
  bool _essentialComplete = false;
  bool _backgroundScheduled = false;
  bool _backgroundRunning = false;
  StartupResult? lastResult;

  bool get safeMode => _safeMode;
  bool get essentialComplete => _essentialComplete;
  AppDatabase? get databaseIfReady => _database;

  AppDatabase getDatabase() {
    _database ??= AppDatabase();
    return _database!;
  }

  Future<StartupResult> runEssentialStartup({
    Duration timeout = startupTimeout,
    bool forceSafeMode = false,
  }) async {
    if (forceSafeMode) {
      _safeMode = true;
    }

    final totalStopwatch = Stopwatch()..start();
    final failures = <StartupStepFailure>[];
    StartupLogger.info('Essential startup beginning (safeMode=$_safeMode)');

    try {
      await _runEssentialSteps(failures).timeout(
        timeout,
        onTimeout: () {
          throw TimeoutException(
            'Essential startup exceeded ${timeout.inSeconds} seconds',
          );
        },
      );
      _essentialComplete = true;
      final result = StartupResult(
        success: true,
        safeMode: _safeMode,
        totalElapsed: totalStopwatch.elapsed,
        failures: failures,
      );
      lastResult = result;
      StartupLogger.info(
        'Essential startup complete (${totalStopwatch.elapsed.inMilliseconds} ms)',
      );
      return result;
    } on TimeoutException catch (e, st) {
      failures.add(
        StartupStepFailure(
          step: 'Overall startup timeout',
          error: e,
          stackTrace: st,
          elapsed: totalStopwatch.elapsed,
        ),
      );
      final result = StartupResult(
        success: false,
        safeMode: _safeMode,
        totalElapsed: totalStopwatch.elapsed,
        failures: failures,
        blockingStep: failures.isNotEmpty
            ? failures.last.step
            : 'Overall startup timeout',
      );
      lastResult = result;
      StartupLogger.failure(
        'Essential startup',
        totalStopwatch.elapsed,
        e,
        st,
      );
      return result;
    } catch (e, st) {
      failures.add(
        StartupStepFailure(
          step: failures.isEmpty ? 'Essential startup' : failures.last.step,
          error: e,
          stackTrace: st,
          elapsed: totalStopwatch.elapsed,
        ),
      );
      final result = StartupResult(
        success: false,
        safeMode: _safeMode,
        totalElapsed: totalStopwatch.elapsed,
        failures: failures,
        blockingStep: failures.last.step,
      );
      lastResult = result;
      StartupLogger.failure(
        'Essential startup',
        totalStopwatch.elapsed,
        e,
        st,
      );
      return result;
    }
  }

  Future<void> _runEssentialSteps(List<StartupStepFailure> failures) async {
    await _runStep(
      'Flutter date formatting',
      failures,
      required: true,
      action: () => initializeDateFormatting('en_PH', null),
    );

    if (_safeMode) {
      StartupLogger.skipped('Database warm-up', 'safe mode');
      _database ??= AppDatabase();
      return;
    }

    await _runStep(
      'Database open and migration',
      failures,
      required: true,
      action: () async {
        final db = getDatabase();
        await db.customSelect('SELECT 1').get();
      },
    );

    await _runStep(
      'App settings load',
      failures,
      required: true,
      action: () async {
        final db = getDatabase();
        await SettingsRepositoryImpl(db).getSettings();
      },
    );
  }

  void scheduleBackgroundTasks(WidgetRef ref) {
    if (_backgroundScheduled) return;
    _backgroundScheduled = true;
    StartupLogger.info('Scheduling background startup tasks');
    unawaited(_runBackgroundTasks(ref));
  }

  Future<void> _runBackgroundTasks(WidgetRef ref) async {
    if (_backgroundRunning) return;
    _backgroundRunning = true;
    StartupLogger.info('Background startup beginning');

    if (_safeMode) {
      StartupLogger.skipped('Background startup', 'safe mode');
      _backgroundRunning = false;
      return;
    }

    await _runBackgroundStep('Storage initialization', () async {
      await DataStorageService.instance
          .initialize()
          .timeout(backgroundStepTimeout);
    });

    await _runBackgroundStep('Notification service', () async {
      await NotificationService.initialize().timeout(backgroundStepTimeout);
    });

    await _runBackgroundStep('Backup retention cleanup', () async {
      await BackupRetentionService.instance
          .cleanOldBackups()
          .timeout(backgroundStepTimeout);
    });

    await _runBackgroundStep('Automatic backup', () async {
      final repository = ref.read(backupRepositoryProvider);
      final result = await AutomaticBackupService.instance
          .maybeRunScheduledBackup(repository)
          .timeout(backgroundStepTimeout);
      if (result == null) {
        StartupLogger.skipped('Automatic backup', 'not due or disabled');
        return;
      }
      await BackupEventLogService.instance.record(
        type: BackupEventType.automaticBackup,
        title: result.verification.passed
            ? 'Automatic Backup Completed'
            : 'Automatic Backup (Verification Failed)',
        success: result.verification.passed,
        relatedPath: result.path,
      );
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
    });

    await _runBackgroundStep('Backup dashboard refresh', () async {
      invalidateBackupMonitoring(ref);
      await ref.read(backupDashboardProvider.future).timeout(
            backgroundStepTimeout,
          );
    });

    await _runBackgroundStep('Recovery readiness evaluation', () async {
      await RecoveryReadinessService.instance
          .evaluate()
          .timeout(backgroundStepTimeout);
      ref.invalidate(recoveryReadinessProvider);
    });

    await _runBackgroundStep('Storage accessibility test', () async {
      if (!DataStorageService.instance.isInitialized) {
        StartupLogger.skipped('Storage accessibility test', 'storage not ready');
        return;
      }
      await StorageTestService.instance.runTest().timeout(backgroundStepTimeout);
    });

    StartupLogger.info('Background startup complete');
    _backgroundRunning = false;
  }

  Future<void> enterSafeModeAndCompleteEssential() async {
    _safeMode = true;
    _database ??= AppDatabase();
    _essentialComplete = true;
    StartupLogger.info('Continuing in safe mode');
  }

  Future<void> _runStep(
    String step,
    List<StartupStepFailure> failures, {
    required bool required,
    required Future<void> Function() action,
  }) async {
    final stopwatch = Stopwatch()..start();
    StartupLogger.start(step);
    try {
      await action();
      StartupLogger.success(step, stopwatch.elapsed);
    } catch (e, st) {
      StartupLogger.failure(step, stopwatch.elapsed, e, st);
      failures.add(
        StartupStepFailure(
          step: step,
          error: e,
          stackTrace: st,
          elapsed: stopwatch.elapsed,
        ),
      );
      if (required) {
        rethrow;
      }
    }
  }

  Future<void> _runBackgroundStep(
    String step,
    Future<void> Function() action,
  ) async {
    final stopwatch = Stopwatch()..start();
    StartupLogger.start(step);
    try {
      await action();
      StartupLogger.success(step, stopwatch.elapsed);
    } on TimeoutException catch (e, st) {
      StartupLogger.failure(step, stopwatch.elapsed, e, st);
    } catch (e, st) {
      StartupLogger.failure(step, stopwatch.elapsed, e, st);
    }
  }
}
