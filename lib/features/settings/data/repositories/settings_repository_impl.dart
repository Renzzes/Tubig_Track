import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/services/csv_export_service.dart';
import '../../../../core/services/data_storage_service.dart';
import '../../../../core/services/business_package_export_service.dart';
import '../../../update/data/repositories/backup_repository_impl.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final AppDatabase _db;
  final DataStorageService _storage;

  SettingsRepositoryImpl(this._db, {DataStorageService? storage})
      : _storage = storage ?? DataStorageService.instance;

  int _parseInt(String? val, int fallback) =>
      int.tryParse(val ?? '') ?? fallback;

  @override
  Future<AppSettings> getSettings() async {
    final totalStr = await _db.settingsDao.getValue(
      AppConstants.settingTotalBottleInventory,
    );
    final thresholdStr = await _db.settingsDao.getValue(
      AppConstants.settingLowInventoryThreshold,
    );
    final minBottles = await _db.settingsDao.getValue(
      AppConstants.settingMinBottles,
    );
    final minGallons = await _db.settingsDao.getValue(
      AppConstants.settingMinGallons,
    );
    final minCaps = await _db.settingsDao.getValue(
      AppConstants.settingMinCaps,
    );
    final minWater = await _db.settingsDao.getValue(
      AppConstants.settingMinWaterStocks,
    );
    return AppSettings(
      totalBottleInventory: _parseInt(
        totalStr,
        AppConstants.defaultBottleInventory,
      ),
      lowInventoryThreshold: _parseInt(
        thresholdStr,
        AppConstants.defaultLowInventoryThreshold,
      ),
      minBottles: _parseInt(minBottles, AppConstants.defaultMinBottles),
      minGallons: _parseInt(minGallons, AppConstants.defaultMinGallons),
      minCaps: _parseInt(minCaps, AppConstants.defaultMinCaps),
      minWaterStocks: _parseInt(
        minWater,
        AppConstants.defaultMinWaterStocks,
      ),
    );
  }

  @override
  Future<void> updateSettings(AppSettings settings) async {
    await _db.settingsDao.setValue(
      AppConstants.settingTotalBottleInventory,
      settings.totalBottleInventory.toString(),
    );
    await _db.settingsDao.setValue(
      AppConstants.settingLowInventoryThreshold,
      settings.lowInventoryThreshold.toString(),
    );
    await _db.settingsDao.setValue(
      AppConstants.settingMinBottles,
      settings.minBottles.toString(),
    );
    await _db.settingsDao.setValue(
      AppConstants.settingMinGallons,
      settings.minGallons.toString(),
    );
    await _db.settingsDao.setValue(
      AppConstants.settingMinCaps,
      settings.minCaps.toString(),
    );
    await _db.settingsDao.setValue(
      AppConstants.settingMinWaterStocks,
      settings.minWaterStocks.toString(),
    );
  }

  @override
  Future<String> backupDatabase() async {
    final backupRepo = BackupRepositoryImpl(_db, storage: _storage);
    return backupRepo.createManualBackup();
  }

  @override
  Future<void> restoreDatabase(String backupPath) async {
    final backupRepo = BackupRepositoryImpl(_db, storage: _storage);
    await backupRepo.restoreBackup(backupPath);
  }

  @override
  Future<List<String>> exportCSV() async {
    final exporter = CsvExportService(_db, storage: _storage);
    return exporter.exportAllTables();
  }

  @override
  Future<bool> hasAnyBackup() async {
    final backupRepo = BackupRepositoryImpl(_db, storage: _storage);
    final recoveryBackups = await backupRepo.listBackups();
    return recoveryBackups.isNotEmpty;
  }

  @override
  Future<OperationalDataCounts> getOperationalDataCounts() {
    return _db.getOperationalDataCounts();
  }

  @override
  Future<String> createArchive() async {
    return createBusinessArchiveZip(
      db: _db,
      appVersion: AppConstants.appVersion,
    );
  }

  @override
  Future<void> archiveAndReset() async {
    await createArchive();
    await factoryReset();
  }

  @override
  Future<void> factoryReset() async {
    await _db.factoryReset();
  }

  @override
  Future<String> createEmergencyBackup() async {
    final backupRepo = BackupRepositoryImpl(_db, storage: _storage);
    return backupRepo.createEmergencyBackup();
  }
}
