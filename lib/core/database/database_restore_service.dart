import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../database/backup_metadata.dart';
import '../services/backup_migration_service.dart';
import '../services/data_storage_service.dart';
import '../services/restore_log_service.dart';
import 'database_provider.dart';
import 'database_refresh.dart';

/// Tracks whether the live DB was already closed before provider disposal.
bool skipDatabaseDisposeClose = false;

Future<RestoreOperationResult> _writeFailure({
  required RestoreLogService logService,
  required String backupFileName,
  required BackupCompatibilityResult compatibility,
  required List<int> migrationSteps,
  required List<String> events,
  required String errorMessage,
  bool rollbackFailed = false,
  String? safetyCopyPath,
  BackupMigrationResult? migration,
}) async {
  events.add('restore failed');
  final logPath = await logService.writeLog(
    backupFileName: backupFileName,
    backupAppVersion: compatibility.backupAppVersion,
    backupSchema: compatibility.backupSchema,
    currentSchema: compatibility.currentSchema,
    migrationStepsExecuted: migrationSteps,
    success: false,
    errorMessage: errorMessage,
    events: events,
    rollbackFailed: rollbackFailed,
    safetyCopyPath: safetyCopyPath,
  );
  return RestoreOperationResult(
    success: false,
    errorMessage: errorMessage,
    compatibility: compatibility,
    migration: migration,
    logPath: logPath,
    rollbackFailed: rollbackFailed,
    safetyCopyPath: safetyCopyPath,
  );
}

/// Safely restores a backup with migration, validation, rollback, and logging.
/// The original backup file is never modified.
Future<RestoreOperationResult> restoreDatabaseFromBackup(
  WidgetRef ref,
  String backupPath,
) async {
  final migrationService = BackupMigrationService.instance;
  final logService = RestoreLogService.instance;
  final storage = DataStorageService.instance;
  final backupFile = File(backupPath);
  final backupFileName = p.basename(backupPath);
  final events = <String>['restore started'];

  if (!await backupFile.exists()) {
    return RestoreOperationResult(
      success: false,
      errorMessage: 'Backup file not found',
    );
  }

  final compatibility = await migrationService.analyzeBackup(backupPath);

  if (compatibility.status == BackupCompatibilityStatus.unsupported ||
      compatibility.status == BackupCompatibilityStatus.newerThanApp) {
    return _writeFailure(
      logService: logService,
      backupFileName: backupFileName,
      compatibility: compatibility,
      migrationSteps: const [],
      events: events,
      errorMessage: compatibility.reason ?? 'Unsupported backup',
    );
  }

  events.add('migration started');
  final migration = await migrationService.prepareRestoreCopy(backupPath);
  if (!migration.success || migration.migratedFilePath == null) {
    return _writeFailure(
      logService: logService,
      backupFileName: backupFileName,
      compatibility: compatibility,
      migrationSteps: migration.migrationStepsExecuted,
      events: events,
      errorMessage: migration.errorMessage ?? 'Migration failed',
      migration: migration,
    );
  }
  events.add('migration completed');
  events.add('validation passed');

  final migratedFile = File(migration.migratedFilePath!);
  final liveTarget = await storage.resolveDatabaseFile();
  File? safetyCopy;

  try {
    if (await liveTarget.exists()) {
      safetyCopy = File('${liveTarget.path}.pre_restore_safety');
      await liveTarget.copy(safetyCopy.path);
    }

    final db = ref.read(databaseProvider);
    skipDatabaseDisposeClose = true;
    try {
      await db.close();
    } finally {
      await Future<void>.delayed(const Duration(milliseconds: 150));
    }

    await migratedFile.copy(liveTarget.path);

    invalidateAllDataProviders(ref);
    skipDatabaseDisposeClose = false;
    ref.read(databaseProvider);

    if (safetyCopy != null && await safetyCopy.exists()) {
      await safetyCopy.delete();
    }
    if (await migratedFile.exists()) {
      await migratedFile.delete();
    }

    events.add('restore completed');
    final logPath = await logService.writeLog(
      backupFileName: backupFileName,
      backupAppVersion: compatibility.backupAppVersion,
      backupSchema: compatibility.backupSchema,
      currentSchema: compatibility.currentSchema,
      migrationStepsExecuted: migration.migrationStepsExecuted,
      success: true,
      events: events,
    );

    return RestoreOperationResult(
      success: true,
      compatibility: compatibility,
      migration: migration,
      logPath: logPath,
    );
  } catch (e) {
    skipDatabaseDisposeClose = false;

    var rollbackFailed = false;
    String? preservedSafetyPath;
    final restoreError = e.toString();

    if (safetyCopy != null && await safetyCopy.exists()) {
      events.add('rollback started');
      try {
        await safetyCopy.copy(liveTarget.path);
        events.add('rollback completed');
        await safetyCopy.delete();
      } catch (rollbackError) {
        events.add('rollback failed');
        events.add('safety copy preserved');
        rollbackFailed = true;
        preservedSafetyPath = safetyCopy.path;
      }
    }

    ref.invalidate(databaseProvider);
    ref.read(databaseProvider);

    if (await migratedFile.exists()) {
      await migratedFile.delete();
    }

    final errorMessage = rollbackFailed
        ? 'Restore failed and automatic rollback could not complete. '
            'Safety backup preserved at: $preservedSafetyPath'
        : restoreError;

    return _writeFailure(
      logService: logService,
      backupFileName: backupFileName,
      compatibility: compatibility,
      migrationSteps: migration.migrationStepsExecuted,
      events: events,
      errorMessage: errorMessage,
      rollbackFailed: rollbackFailed,
      safetyCopyPath: preservedSafetyPath,
      migration: migration,
    );
  }
}
