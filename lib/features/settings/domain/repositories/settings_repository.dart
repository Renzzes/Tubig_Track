import '../entities/app_settings.dart';

abstract class SettingsRepository {
  Future<AppSettings> getSettings();
  Future<void> updateSettings(AppSettings settings);
  Future<String> backupDatabase();
  Future<void> restoreDatabase(String backupPath);
  Future<String> exportCSV();
}
