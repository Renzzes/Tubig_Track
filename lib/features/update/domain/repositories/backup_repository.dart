import '../entities/backup_file_info.dart';
import '../entities/recovery_file_info.dart';
import '../../../../core/database/backup_metadata.dart';
import '../../../../core/services/backup_verification_service.dart';

abstract class BackupRepository {
  Future<bool> databaseExists();
  Future<String> createPreUpdateBackup();
  Future<String> createAutomaticBackup();
  Future<String> createManualBackup();
  Future<VerifiedBackupResult> createVerifiedManualBackup();
  Future<VerifiedBackupResult> createVerifiedAutomaticBackup();
  Future<VerifiedBackupResult> createVerifiedPreUpdateBackup();
  Future<String> createEmergencyBackup();
  Future<List<BackupFileInfo>> listBackups();
  Future<List<RecoveryFileInfo>> listRecoveryFiles({
    Set<RecoveryFileCategory>? categories,
  });
  Future<void> deleteBackup(String path);
  Future<String> renameBackup(String path, String newFileName);
  Future<void> restoreBackup(String path);
  Future<BackupFileInfo?> findLatestPreUpdateBackup();
  Future<RecoveryFileInfo?> getFileMetadata(String path);
  Future<BackupCompatibilityResult> checkCompatibility(String backupPath);
  Future<BackupMetadata?> readBackupMetadata(String backupPath);
}
