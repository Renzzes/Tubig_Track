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

  if (!await backupFile.exists()) {
    return RestoreOperationResult(
      success: false,
      errorMessage: 'Backup file not found',
    );
  }

  final compatibility = await migrationService.analyzeBackup(backupPath);

  if (compatibility.status == BackupCompatibilityStatus.unsupported ||
      compatibility.status == BackupCompatibilityStatus.newerThanApp) {
    final logPath = await logService.writeLog(
      backupFileName: backupFileName,
      backupAppVersion: compatibility.backupAppVersion,
      backupSchema: compatibility.backupSchema,
      currentSchema: compatibility.currentSchema,
      migrationStepsExecuted: [],
      success: false,
      errorMessage: compatibility.reason,
    );
    return RestoreOperationResult(
      success: false,
      errorMessage: compatibility.reason,
      compatibility: compatibility,
      logPath: logPath,
    );
  }

  final migration = await migrationService.prepareRestoreCopy(backupPath);
  if (!migration.success || migration.migratedFilePath == null) {
    final logPath = await logService.writeLog(
      backupFileName: backupFileName,
      backupAppVersion: compatibility.backupAppVersion,
      backupSchema: compatibility.backupSchema,
      currentSchema: compatibility.currentSchema,
      migrationStepsExecuted: migration.migrationStepsExecuted,
      success: false,
      errorMessage: migration.errorMessage,
    );
    return RestoreOperationResult(
      success: false,
      errorMessage: migration.errorMessage ?? 'Migration failed',
      compatibility: compatibility,
      migration: migration,
      logPath: logPath,
    );
  }

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

    final logPath = await logService.writeLog(
      backupFileName: backupFileName,
      backupAppVersion: compatibility.backupAppVersion,
      backupSchema: compatibility.backupSchema,
      currentSchema: compatibility.currentSchema,
      migrationStepsExecuted: migration.migrationStepsExecuted,
      success: true,
    );

    return RestoreOperationResult(
      success: true,
      compatibility: compatibility,
      migration: migration,
      logPath: logPath,
    );
  } catch (e) {
    skipDatabaseDisposeClose = false;

    if (safetyCopy != null && await safetyCopy.exists()) {
      try {
        await safetyCopy.copy(liveTarget.path);
      } catch (_) {
        // Best-effort rollback.
      }
      await safetyCopy.delete();
    }

    ref.invalidate(databaseProvider);
    ref.read(databaseProvider);

    if (await migratedFile.exists()) {
      await migratedFile.delete();
    }

    final logPath = await logService.writeLog(
      backupFileName: backupFileName,
      backupAppVersion: compatibility.backupAppVersion,
      backupSchema: compatibility.backupSchema,
      currentSchema: compatibility.currentSchema,
      migrationStepsExecuted: migration.migrationStepsExecuted,
      success: false,
      errorMessage: e.toString(),
    );

    return RestoreOperationResult(
      success: false,
      errorMessage: e.toString(),
      compatibility: compatibility,
      migration: migration,
      logPath: logPath,
    );
  }
}
