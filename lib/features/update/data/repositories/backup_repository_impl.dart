import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/backup_file_info.dart';
import '../../domain/repositories/backup_repository.dart';

class BackupRepositoryImpl implements BackupRepository {
  final AppDatabase _db;

  BackupRepositoryImpl(this._db);

  Future<Directory> _backupsDirectory() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, AppConstants.backupsFolderName));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<File?> _resolveDatabaseFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final candidates = [
      File(p.join(dir.path, '${AppConstants.dbFileName}.sqlite')),
      File(p.join(dir.path, AppConstants.dbFileName)),
    ];
    for (final file in candidates) {
      if (await file.exists()) return file;
    }
    return null;
  }

  String _timestamp() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    final h = now.hour.toString().padLeft(2, '0');
    final min = now.minute.toString().padLeft(2, '0');
    return '${y}_${m}_${d}_$h$min';
  }

  @override
  Future<bool> databaseExists() async {
    final file = await _resolveDatabaseFile();
    return file != null;
  }

  @override
  Future<String> createPreUpdateBackup() async {
    final source = await _resolveDatabaseFile();
    if (source == null) {
      throw Exception('Database file not found');
    }
    final backupDir = await _backupsDirectory();
    final fileName = '${AppConstants.preUpdateBackupPrefix}${_timestamp()}.db';
    final target = File(p.join(backupDir.path, fileName));
    await source.copy(target.path);
    return target.path;
  }

  @override
  Future<String> createManualBackup() async {
    final source = await _resolveDatabaseFile();
    if (source == null) {
      throw Exception('Database file not found');
    }
    final backupDir = await _backupsDirectory();
    final fileName = 'tubigtrack_backup_${_timestamp()}.db';
    final target = File(p.join(backupDir.path, fileName));
    await source.copy(target.path);
    return target.path;
  }

  @override
  Future<List<BackupFileInfo>> listBackups() async {
    final backupDir = await _backupsDirectory();
    final files = backupDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.db'))
        .toList();

    final backups = <BackupFileInfo>[];
    for (final file in files) {
      final stat = await file.stat();
      final name = p.basename(file.path);
      backups.add(
        BackupFileInfo(
          path: file.path,
          fileName: name,
          modifiedAt: stat.modified,
          isPreUpdate: name.startsWith(AppConstants.preUpdateBackupPrefix),
        ),
      );
    }

    backups.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
    return backups;
  }

  @override
  Future<void> deleteBackup(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  @override
  Future<void> restoreBackup(String backupPath) async {
    final backupFile = File(backupPath);
    if (!await backupFile.exists()) {
      throw Exception('Backup file not found');
    }

    final dir = await getApplicationDocumentsDirectory();
    final targetPath = p.join(dir.path, '${AppConstants.dbFileName}.sqlite');
    await _db.close();
    await backupFile.copy(targetPath);
  }

  @override
  Future<BackupFileInfo?> findLatestPreUpdateBackup() async {
    final backups = await listBackups();
    for (final backup in backups) {
      if (backup.isPreUpdate) return backup;
    }
    return null;
  }
}
