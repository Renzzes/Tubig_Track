import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import 'backup_metadata_service.dart';
import 'data_storage_service.dart';

/// How many database backups to retain in TubigTrack/Backups/.
enum BackupKeepCount {
  ten(10),
  twenty(20),
  unlimited(null);

  const BackupKeepCount(this.maxCount);
  final int? maxCount;
}

/// Delete backups older than this age, or never.
enum BackupMaxAge {
  days30(30),
  days90(90),
  never(null);

  const BackupMaxAge(this.days);
  final int? days;
}

class BackupRetentionSettings {
  final BackupKeepCount keepCount;
  final BackupMaxAge maxAge;

  const BackupRetentionSettings({
    this.keepCount = BackupKeepCount.twenty,
    this.maxAge = BackupMaxAge.never,
  });
}

class BackupCleanupResult {
  final int deletedCount;
  final List<String> deletedFiles;

  const BackupCleanupResult({
    required this.deletedCount,
    required this.deletedFiles,
  });
}

class BackupRetentionService {
  BackupRetentionService._({
    DataStorageService? storage,
    BackupMetadataService? metadata,
  })  : _storage = storage ?? DataStorageService.instance,
        _metadata = metadata ?? BackupMetadataService.instance;

  static final BackupRetentionService instance = BackupRetentionService._();

  final DataStorageService _storage;
  final BackupMetadataService _metadata;

  Future<BackupRetentionSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final keepName = prefs.getString(AppConstants.prefBackupKeepCount);
    final ageName = prefs.getString(AppConstants.prefBackupMaxAge);

    return BackupRetentionSettings(
      keepCount: BackupKeepCount.values.firstWhere(
        (v) => v.name == keepName,
        orElse: () => BackupKeepCount.twenty,
      ),
      maxAge: BackupMaxAge.values.firstWhere(
        (v) => v.name == ageName,
        orElse: () => BackupMaxAge.never,
      ),
    );
  }

  Future<void> saveSettings(BackupRetentionSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.prefBackupKeepCount,
      settings.keepCount.name,
    );
    await prefs.setString(
      AppConstants.prefBackupMaxAge,
      settings.maxAge.name,
    );
  }

  /// Deletes old backups in Backups/ according to saved retention rules.
  Future<BackupCleanupResult> cleanOldBackups() async {
    final settings = await loadSettings();
    final backupDir = await _storage.backupsDirectory();
    if (!await backupDir.exists()) {
      return const BackupCleanupResult(deletedCount: 0, deletedFiles: []);
    }

    final files = backupDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.toLowerCase().endsWith('.db'))
        .toList();

    files.sort(
      (a, b) => b.statSync().modified.compareTo(a.statSync().modified),
    );

    final now = DateTime.now();
    final toDelete = <File>[];

    for (var i = 0; i < files.length; i++) {
      final file = files[i];
      var shouldDelete = false;

      final maxCount = settings.keepCount.maxCount;
      if (maxCount != null && i >= maxCount) {
        shouldDelete = true;
      }

      final maxAgeDays = settings.maxAge.days;
      if (maxAgeDays != null) {
        final age = now.difference(file.statSync().modified).inDays;
        if (age > maxAgeDays) {
          shouldDelete = true;
        }
      }

      if (shouldDelete) {
        toDelete.add(file);
      }
    }

    final deletedNames = <String>[];
    for (final file in toDelete) {
      await _metadata.deleteMetadata(file.path);
      await file.delete();
      deletedNames.add(p.basename(file.path));
    }

    return BackupCleanupResult(
      deletedCount: deletedNames.length,
      deletedFiles: deletedNames,
    );
  }
}
