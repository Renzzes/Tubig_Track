import '../entities/backup_file_info.dart';

abstract class BackupRepository {
  Future<bool> databaseExists();
  Future<String> createPreUpdateBackup();
  Future<String> createManualBackup();
  Future<List<BackupFileInfo>> listBackups();
  Future<void> deleteBackup(String path);
  Future<void> restoreBackup(String path);
  Future<BackupFileInfo?> findLatestPreUpdateBackup();
}
