import '../../../../core/database/app_database.dart';
import '../entities/app_settings.dart';

abstract class SettingsRepository {
  Future<AppSettings> getSettings();
  Future<void> updateSettings(AppSettings settings);
  Future<String> backupDatabase();
  Future<void> restoreDatabase(String backupPath);
  Future<List<String>> exportCSV();
  Future<bool> hasAnyBackup();
  Future<OperationalDataCounts> getOperationalDataCounts();
  Future<String> createArchive();
  Future<void> archiveAndReset();
  Future<void> factoryReset();
  Future<String> createEmergencyBackup();
}
