import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../constants/app_constants.dart';
import '../database/app_database.dart';
import '../database/backup_metadata.dart';
import '../database/backup_schema_reader.dart';
import 'backup_metadata_service.dart';

/// Analyzes backup compatibility and migrates copies without touching originals.
class BackupMigrationService {
  BackupMigrationService._({
    BackupMetadataService? metadataService,
  }) : _metadata = metadataService ?? BackupMetadataService.instance;

  static final BackupMigrationService instance = BackupMigrationService._();

  final BackupMetadataService _metadata;

  Future<BackupCompatibilityResult> analyzeBackup(String backupPath) async {
    final file = File(backupPath);
    if (!await file.exists()) {
      return BackupCompatibilityResult(
        status: BackupCompatibilityStatus.unsupported,
        backupPath: backupPath,
        currentSchema: AppDatabase.currentSchemaVersion,
        currentAppVersion: AppConstants.appVersion,
        reason: 'Backup file not found',
      );
    }

    final metadata = await _metadata.readMetadata(backupPath);
    final detectedSchema = await BackupSchemaReader.readUserVersion(file);
    final backupSchema = metadata?.databaseSchema ?? detectedSchema ?? 0;
    final currentSchema = AppDatabase.currentSchemaVersion;

    if (backupSchema <= 0) {
      final hasTables = await BackupSchemaReader.hasRequiredTables(file);
      return BackupCompatibilityResult(
        status: hasTables
            ? BackupCompatibilityStatus.unknown
            : BackupCompatibilityStatus.unsupported,
        backupPath: backupPath,
        metadata: metadata,
        detectedSchema: detectedSchema,
        currentSchema: currentSchema,
        currentAppVersion: AppConstants.appVersion,
        reason: hasTables
            ? 'Could not determine database schema version'
            : 'File does not appear to be a TubigTrack database',
      );
    }

    if (backupSchema > currentSchema) {
      return BackupCompatibilityResult(
        status: BackupCompatibilityStatus.newerThanApp,
        backupPath: backupPath,
        metadata: metadata,
        detectedSchema: detectedSchema,
        currentSchema: currentSchema,
        currentAppVersion: AppConstants.appVersion,
        reason:
            'Backup schema v$backupSchema is from a newer app version '
            '(current schema v$currentSchema)',
        migrationSteps: [],
      );
    }

    if (backupSchema == currentSchema) {
      return BackupCompatibilityResult(
        status: BackupCompatibilityStatus.compatible,
        backupPath: backupPath,
        metadata: metadata,
        detectedSchema: detectedSchema,
        currentSchema: currentSchema,
        currentAppVersion: AppConstants.appVersion,
        migrationSteps: [],
      );
    }

    if (!BackupSchemaReader.hasMigrationPath(backupSchema, currentSchema)) {
      return BackupCompatibilityResult(
        status: BackupCompatibilityStatus.unsupported,
        backupPath: backupPath,
        metadata: metadata,
        detectedSchema: detectedSchema,
        currentSchema: currentSchema,
        currentAppVersion: AppConstants.appVersion,
        reason:
            'Database schema v$backupSchema is too old for the current version',
        migrationSteps: [],
      );
    }

    final steps =
        BackupSchemaReader.migrationStepsFrom(backupSchema, currentSchema);
    return BackupCompatibilityResult(
      status: BackupCompatibilityStatus.migratable,
      backupPath: backupPath,
      metadata: metadata,
      detectedSchema: detectedSchema,
      currentSchema: currentSchema,
      currentAppVersion: AppConstants.appVersion,
      migrationSteps: steps,
    );
  }

  /// Copies [backupPath] to a temp file, runs Drift migrations, and validates.
  /// The original backup is never modified.
  Future<BackupMigrationResult> prepareRestoreCopy(String backupPath) async {
    final analysis = await analyzeBackup(backupPath);
    if (analysis.status == BackupCompatibilityStatus.unsupported ||
        analysis.status == BackupCompatibilityStatus.newerThanApp) {
      return BackupMigrationResult(
        success: false,
        errorMessage: analysis.reason ?? 'Backup cannot be restored',
      );
    }

    if (analysis.status == BackupCompatibilityStatus.compatible) {
      return _copyToTemp(backupPath, analysis.migrationSteps);
    }

    return _copyMigrateAndValidate(backupPath, analysis);
  }

  Future<BackupMigrationResult> _copyToTemp(
    String backupPath,
    List<int> steps,
  ) async {
    File? tempFile;
    AppDatabase? db;
    try {
      tempFile = await _copyToTemporaryFile(backupPath);
      db = AppDatabase.openAt(tempFile);
      final validation = await _validateDatabase(db);
      if (!validation.success) {
        await db.close();
        await tempFile.delete();
        return BackupMigrationResult(
          success: false,
          errorMessage: validation.errorMessage,
        );
      }
      await db.close();
      return BackupMigrationResult(
        success: true,
        migratedFilePath: tempFile.path,
        migrationStepsExecuted: steps,
        finalSchema: AppDatabase.currentSchemaVersion,
      );
    } catch (e) {
      await db?.close();
      if (tempFile != null && await tempFile.exists()) {
        await tempFile.delete();
      }
      return BackupMigrationResult(
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<BackupMigrationResult> _copyMigrateAndValidate(
    String backupPath,
    BackupCompatibilityResult analysis,
  ) async {
    File? tempFile;
    AppDatabase? db;
    try {
      tempFile = await _copyToTemporaryFile(backupPath);
      db = AppDatabase.openAt(tempFile);

      // Force connection and migration by reading from core tables.
      await db.customersDao.getAll();
      await db.deliveriesDao.getAll();
      await db.settingsDao.getAll();

      final validation = await _validateDatabase(db);
      if (!validation.success) {
        await db.close();
        await tempFile.delete();
        return BackupMigrationResult(
          success: false,
          errorMessage: validation.errorMessage,
          migrationStepsExecuted: analysis.migrationSteps,
        );
      }

      await db.close();
      return BackupMigrationResult(
        success: true,
        migratedFilePath: tempFile.path,
        migrationStepsExecuted: analysis.migrationSteps,
        finalSchema: AppDatabase.currentSchemaVersion,
      );
    } catch (e) {
      await db?.close();
      if (tempFile != null && await tempFile.exists()) {
        await tempFile.delete();
      }
      return BackupMigrationResult(
        success: false,
        errorMessage: 'Migration failed: $e',
        migrationStepsExecuted: analysis.migrationSteps,
      );
    }
  }

  Future<({bool success, String? errorMessage})> _validateDatabase(
    AppDatabase db,
  ) async {
    try {
      final versionRow =
          await db.customSelect('PRAGMA user_version').getSingle();
      final version = versionRow.read<int>('user_version');
      if (version != AppDatabase.currentSchemaVersion) {
        return (
          success: false,
          errorMessage:
              'Schema validation failed: expected v${AppDatabase.currentSchemaVersion}, '
              'got v$version',
        );
      }

      await db.customersDao.getAll();
      await db.deliveriesDao.getAll();
      await db.settingsDao.getAll();
      return (success: true, errorMessage: null);
    } catch (e) {
      return (success: false, errorMessage: 'Validation failed: $e');
    }
  }

  Future<File> _copyToTemporaryFile(String backupPath) async {
    final tempDir = await getTemporaryDirectory();
    final name =
        'tubig_restore_${DateTime.now().millisecondsSinceEpoch}.db';
    final tempFile = File(p.join(tempDir.path, name));
    await File(backupPath).copy(tempFile.path);
    return tempFile;
  }

  /// Opens a backup for read-only browsing using a temporary copy.
  /// The original backup file is never modified.
  Future<({AppDatabase db, File tempFile})> openReadOnlyCopy(
    String backupPath,
  ) async {
    final file = File(backupPath);
    if (!await file.exists()) {
      throw Exception('Backup file not found');
    }
    final tempFile = await _copyToTemporaryFile(backupPath);
    final db = AppDatabase.openAt(tempFile);
    try {
      await db.customersDao.getAll();
    } catch (_) {
      await db.close();
      await tempFile.delete();
      rethrow;
    }
    await db.close();
    final readDb = AppDatabase.openAt(tempFile, readOnly: true);
    return (db: readDb, tempFile: tempFile);
  }
}
