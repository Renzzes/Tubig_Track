import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../update/data/repositories/backup_repository_impl.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final AppDatabase _db;

  SettingsRepositoryImpl(this._db);

  Future<File> _resolveDatabaseFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final candidates = [
      File(p.join(dir.path, '${AppConstants.dbFileName}.sqlite')),
      File(p.join(dir.path, AppConstants.dbFileName)),
    ];
    for (final file in candidates) {
      if (await file.exists()) return file;
    }
    throw Exception('Database file not found');
  }

  Future<Directory> _archivesDirectory() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, AppConstants.archivesFolderName));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  String _backupFileName() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    final h = now.hour.toString().padLeft(2, '0');
    final min = now.minute.toString().padLeft(2, '0');
    return 'tubigtrack_backup_${y}_${m}_${d}_$h$min.db';
  }

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
    final source = await _resolveDatabaseFile();
    final backupPath = p.join(p.dirname(source.path), _backupFileName());
    await source.copy(backupPath);
    return backupPath;
  }

  @override
  Future<void> restoreDatabase(String backupPath) async {
    final backupFile = File(backupPath);
    if (!await backupFile.exists()) {
      throw Exception('Backup file not found');
    }
    final target = await _resolveDatabaseFile();
    await _db.close();
    await backupFile.copy(target.path);
  }

  @override
  Future<String> exportCSV() async {
    final dbFile = await _resolveDatabaseFile();
    final dir = p.dirname(dbFile.path);
    final buffer = StringBuffer();

    buffer.writeln('=== CUSTOMERS ===');
    buffer.writeln('ID,Name,Phone,Address,Notes,Created');
    for (final c in await _db.customersDao.getAll()) {
      buffer.writeln(
        '"${c.id}","${c.name}","${c.phone ?? ''}","${c.address ?? ''}","${c.notes ?? ''}","${c.createdAt.toIso8601String()}"',
      );
    }
    buffer.writeln();

    buffer.writeln('=== DELIVERIES ===');
    buffer.writeln(
      'ID,CustomerID,Quantity,PricePerBottle,Total,PaymentStatus,AmountPaid,Balance,Date,Time,DeliveryStatus,Notes,ReceiptNumber',
    );
    for (final d in await _db.deliveriesDao.getAll()) {
      buffer.writeln(
        '"${d.id}","${d.customerId}",${d.quantity},${d.pricePerBottle},${d.totalAmount},"${d.paymentStatus}",${d.amountPaid},${d.remainingBalance},"${d.deliveryDate.toIso8601String()}","${d.deliveryTime ?? ''}","${d.deliveryStatus}","${d.notes ?? ''}","${d.receiptNumber ?? ''}"',
      );
    }
    buffer.writeln();

    buffer.writeln('=== PAYMENTS ===');
    buffer.writeln('ID,CustomerID,DeliveryID,Amount,Date,Notes');
    for (final pmt in await _db.paymentsDao.getAll()) {
      buffer.writeln(
        '"${pmt.id}","${pmt.customerId}","${pmt.deliveryId ?? ''}",${pmt.amount},"${pmt.paymentDate.toIso8601String()}","${pmt.notes ?? ''}"',
      );
    }
    buffer.writeln();

    buffer.writeln('=== BOTTLE TRANSACTIONS ===');
    buffer.writeln('ID,CustomerID,Type,Quantity,Date,Notes');
    for (final t in await _db.bottleTransactionsDao.getAll()) {
      buffer.writeln(
        '"${t.id}","${t.customerId ?? ''}","${t.transactionType}",${t.quantity},"${t.date.toIso8601String()}","${t.notes ?? ''}"',
      );
    }
    buffer.writeln();

    buffer.writeln('=== EXPENSES ===');
    buffer.writeln('ID,Category,Amount,Date,Notes');
    for (final e in await _db.expensesDao.getAll()) {
      buffer.writeln(
        '"${e.id}","${e.category}",${e.amount},"${e.date.toIso8601String()}","${e.notes ?? ''}"',
      );
    }
    buffer.writeln();

    buffer.writeln('=== DISPENSER SALES ===');
    buffer.writeln('ID,Amount,Date,Notes');
    for (final s in await _db.dispenserSalesDao.getAll()) {
      buffer.writeln(
        '"${s.id}",${s.amount},"${s.date.toIso8601String()}","${s.notes ?? ''}"',
      );
    }
    buffer.writeln();

    buffer.writeln('=== SETTINGS ===');
    buffer.writeln('Key,Value');
    for (final s in await _db.settingsDao.getAll()) {
      buffer.writeln('"${s.key}","${s.value}"');
    }

    final csvPath =
        p.join(dir, 'tubigtrack_export_${DateTime.now().millisecondsSinceEpoch}.csv');
    await File(csvPath).writeAsString(buffer.toString());
    return csvPath;
  }

  @override
  Future<bool> hasAnyBackup() async {
    final backupRepo = BackupRepositoryImpl(_db);
    final recoveryBackups = await backupRepo.listBackups();
    if (recoveryBackups.isNotEmpty) return true;

    final dir = await getApplicationDocumentsDirectory();
    final files = Directory(dir.path).listSync().whereType<File>();
    return files.any(
      (f) =>
          p.basename(f.path).startsWith('tubigtrack_backup_') &&
          f.path.endsWith('.db'),
    );
  }

  @override
  Future<OperationalDataCounts> getOperationalDataCounts() {
    return _db.getOperationalDataCounts();
  }

  @override
  Future<String> createArchive() async {
    final source = await _resolveDatabaseFile();
    final archiveDir = await _archivesDirectory();
    final year = DateTime.now().year;
    final fileName = 'TubigTrack_Archive_$year.db';
    final target = File(p.join(archiveDir.path, fileName));
    if (await target.exists()) {
      final ts = DateTime.now().millisecondsSinceEpoch;
      final alt = File(p.join(archiveDir.path, 'TubigTrack_Archive_${year}_$ts.db'));
      await source.copy(alt.path);
      return alt.path;
    }
    await source.copy(target.path);
    return target.path;
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
}
