import 'dart:convert';

import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/backup_metadata.dart';
import '../../../../core/services/backup_metadata_service.dart';
import '../../../../core/services/backup_migration_service.dart';
import '../../../../core/services/data_storage_service.dart';
import '../../domain/entities/backup_file_info.dart';
import '../../domain/entities/recovery_file_info.dart';
import '../../domain/repositories/backup_repository.dart';

class BackupRepositoryImpl implements BackupRepository {
  final AppDatabase _db;
  final DataStorageService _storage;
  final BackupMetadataService _metadataService;

  BackupRepositoryImpl(
    this._db, {
    DataStorageService? storage,
    BackupMetadataService? metadataService,
  })  : _storage = storage ?? DataStorageService.instance,
        _metadataService = metadataService ?? BackupMetadataService.instance;

  Future<File> _requireDatabaseFile() async {
    final file = await _storage.resolveDatabaseFile();
    if (!await file.exists()) {
      throw Exception('Database file not found');
    }
    return file;
  }

  Future<String> _copyDatabaseTo(
    Directory targetDir,
    String fileName, {
    bool writeMetadata = true,
  }) async {
    await _storage.ensureFolderStructure();
    final source = await _requireDatabaseFile();
    final target = File(p.join(targetDir.path, fileName));
    await source.copy(target.path);
    if (writeMetadata) {
      await _metadataService.writeMetadataForDatabase(_db, target.path);
    }
    return target.path;
  }

  RecoveryFileInfo _toRecoveryInfo({
    required File entity,
    required RecoveryFileCategory category,
    required BackupMetadata? metadata,
    required FileStat stat,
  }) {
    final name = p.basename(entity.path);
    return RecoveryFileInfo(
      path: entity.path,
      fileName: name,
      modifiedAt: metadata?.createdAt ?? stat.modified,
      sizeBytes: stat.size,
      category: category,
      isPreUpdate: name.startsWith(AppConstants.preUpdateBackupPrefix),
      appVersion: metadata?.appVersion,
      databaseVersion: metadata?.databaseSchema,
      customers: metadata?.customers,
      deliveries: metadata?.deliveries,
      inventoryTransactions: metadata?.inventoryTransactions,
      databaseSize: metadata?.databaseSize ?? _storage.formatBytes(stat.size),
      metadataCreatedAt: metadata?.createdAt,
    );
  }

  @override
  Future<bool> databaseExists() async {
    final file = await _storage.resolveDatabaseFile();
    return file.exists();
  }

  @override
  Future<String> createPreUpdateBackup() async {
    final backupDir = await _storage.backupsDirectory();
    final fileName =
        '${AppConstants.preUpdateBackupPrefix}${_storage.timestampForFilename()}.db';
    return _copyDatabaseTo(backupDir, fileName);
  }

  @override
  Future<String> createManualBackup() async {
    final backupDir = await _storage.backupsDirectory();
    return _copyDatabaseTo(
      backupDir,
      _storage.backupFileName(),
    );
  }

  @override
  Future<String> createEmergencyBackup() async {
    final recoveryDir = await _storage.recoveryDirectory();
    return _copyDatabaseTo(
      recoveryDir,
      _storage.emergencyBackupFileName(),
    );
  }

  @override
  Future<List<BackupFileInfo>> listBackups() async {
    final files = await listRecoveryFiles(
      categories: {RecoveryFileCategory.databaseBackup},
    );
    return files
        .map(
          (f) => BackupFileInfo(
            path: f.path,
            fileName: f.fileName,
            modifiedAt: f.modifiedAt,
            sizeBytes: f.sizeBytes,
            isPreUpdate: f.isPreUpdate,
            appVersion: f.appVersion,
            databaseVersion: f.databaseVersion,
            customers: f.customers,
            deliveries: f.deliveries,
            inventoryTransactions: f.inventoryTransactions,
            databaseSize: f.databaseSize,
          ),
        )
        .toList();
  }

  @override
  Future<List<RecoveryFileInfo>> listRecoveryFiles({
    Set<RecoveryFileCategory>? categories,
  }) async {
    await _storage.ensureFolderStructure();
    final wanted = categories ??
        {
          RecoveryFileCategory.databaseBackup,
          RecoveryFileCategory.archive,
          RecoveryFileCategory.csvExport,
          RecoveryFileCategory.report,
          RecoveryFileCategory.emergencyRecovery,
        };

    final results = <RecoveryFileInfo>[];

    Future<void> scanDir(
      Directory dir,
      RecoveryFileCategory category,
      List<String> extensions,
    ) async {
      if (!await dir.exists()) return;
      for (final entity in dir.listSync(followLinks: false)) {
        if (entity is! File) continue;
        final ext = p.extension(entity.path).toLowerCase();
        if (!extensions.contains(ext)) continue;
        if (entity.path.contains('_metadata.json') ||
            entity.path.endsWith('.meta.json')) {
          continue;
        }

        final stat = await entity.stat();
        BackupMetadata? metadata;
        if (ext == '.db') {
          metadata = await _metadataService.readMetadata(entity.path);
        }
        results.add(
          _toRecoveryInfo(
            entity: entity,
            category: category,
            metadata: metadata,
            stat: stat,
          ),
        );
      }
    }

    if (wanted.contains(RecoveryFileCategory.databaseBackup)) {
      await scanDir(
        await _storage.backupsDirectory(),
        RecoveryFileCategory.databaseBackup,
        ['.db'],
      );
    }
    if (wanted.contains(RecoveryFileCategory.emergencyRecovery)) {
      await scanDir(
        await _storage.recoveryDirectory(),
        RecoveryFileCategory.emergencyRecovery,
        ['.db'],
      );
    }
    if (wanted.contains(RecoveryFileCategory.archive)) {
      await scanDir(
        await _storage.archivesDirectory(),
        RecoveryFileCategory.archive,
        ['.zip', '.db'],
      );
    }
    if (wanted.contains(RecoveryFileCategory.csvExport)) {
      await scanDir(
        await _storage.csvDirectory(),
        RecoveryFileCategory.csvExport,
        ['.csv'],
      );
    }
    if (wanted.contains(RecoveryFileCategory.report)) {
      await scanDir(
        await _storage.reportsDirectory(),
        RecoveryFileCategory.report,
        ['.pdf', '.xlsx', '.csv'],
      );
    }

    results.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
    return results;
  }

  @override
  Future<void> deleteBackup(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
    await _metadataService.deleteMetadata(path);
  }

  @override
  Future<String> renameBackup(String path, String newFileName) async {
    final file = File(path);
    if (!await file.exists()) {
      throw Exception('File not found');
    }
    final sanitized = newFileName.trim();
    if (sanitized.isEmpty) {
      throw Exception('Name cannot be empty');
    }
    final newPath = p.join(p.dirname(path), sanitized);
    if (await File(newPath).exists()) {
      throw Exception('A file with that name already exists');
    }
    await file.rename(newPath);
    await _metadataService.renameMetadata(path, newPath);
    return newPath;
  }

  @override
  Future<void> restoreBackup(String backupPath) async {
    final backupFile = File(backupPath);
    if (!await backupFile.exists()) {
      throw Exception('Backup file not found');
    }
    final target = await _storage.resolveDatabaseFile();
    await _db.close();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await backupFile.copy(target.path);
  }

  @override
  Future<BackupFileInfo?> findLatestPreUpdateBackup() async {
    final backups = await listBackups();
    for (final backup in backups) {
      if (backup.isPreUpdate) return backup;
    }
    return null;
  }

  @override
  Future<RecoveryFileInfo?> getFileMetadata(String path) async {
    final file = File(path);
    if (!await file.exists()) return null;
    final stat = await file.stat();
    final meta = await _metadataService.readMetadata(path);
    RecoveryFileCategory category;
    if (path.contains(AppConstants.recoverySubfolder)) {
      category = RecoveryFileCategory.emergencyRecovery;
    } else if (path.contains(AppConstants.archivesSubfolder)) {
      category = RecoveryFileCategory.archive;
    } else if (path.contains(AppConstants.csvSubfolder)) {
      category = RecoveryFileCategory.csvExport;
    } else if (path.contains(AppConstants.reportsSubfolder)) {
      category = RecoveryFileCategory.report;
    } else {
      category = RecoveryFileCategory.databaseBackup;
    }
    return _toRecoveryInfo(
      entity: file,
      category: category,
      metadata: meta,
      stat: stat,
    );
  }

  @override
  Future<BackupCompatibilityResult> checkCompatibility(String backupPath) {
    return BackupMigrationService.instance.analyzeBackup(backupPath);
  }

  @override
  Future<BackupMetadata?> readBackupMetadata(String backupPath) {
    return _metadataService.readMetadata(backupPath);
  }
}

/// Creates a zip archive with database, CSV exports, reports, and metadata.
Future<String> createBusinessArchiveZip({
  required AppDatabase db,
  required String appVersion,
}) async {
  final storage = DataStorageService.instance;
  final metadataService = BackupMetadataService.instance;
  await storage.ensureFolderStructure();

  final archiveDir = await storage.archivesDirectory();
  var zipPath = p.join(archiveDir.path, storage.archiveZipFileName());
  if (await File(zipPath).exists()) {
    final stamp = storage.timestampForFilename();
    zipPath = p.join(
      archiveDir.path,
      'BusinessArchive_${storage.backupTimestampForFilename()}_$stamp.zip',
    );
  }
  final encoder = ZipFileEncoder()..create(zipPath);

  final dbFile = await storage.resolveDatabaseFile();
  if (await dbFile.exists()) {
    encoder.addFile(dbFile, 'database/${p.basename(dbFile.path)}');
    final meta = await metadataService.buildFromDatabase(db, dbFile.path);
    final metaFile = File('${p.withoutExtension(zipPath)}_metadata.json');
    await metaFile.writeAsString(
      JsonEncoder.withIndent('  ').convert(meta.toJson()),
    );
    encoder.addFile(metaFile, 'metadata.json');
    await metaFile.delete();
  }

  final csvDir = await storage.csvDirectory();
  if (await csvDir.exists()) {
    for (final entity in csvDir.listSync()) {
      if (entity is File && entity.path.endsWith('.csv')) {
        encoder.addFile(entity, 'csv/${p.basename(entity.path)}');
      }
    }
  }

  final reportsDir = await storage.reportsDirectory();
  if (await reportsDir.exists()) {
    for (final entity in reportsDir.listSync()) {
      if (entity is File) {
        final ext = p.extension(entity.path).toLowerCase();
        if (ext == '.pdf' || ext == '.xlsx' || ext == '.csv') {
          encoder.addFile(entity, 'reports/${p.basename(entity.path)}');
        }
      }
    }
  }

  encoder.close();
  return zipPath;
}
