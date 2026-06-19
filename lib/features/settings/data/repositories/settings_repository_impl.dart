import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/app_database.dart';
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

  String _backupFileName() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    final h = now.hour.toString().padLeft(2, '0');
    final min = now.minute.toString().padLeft(2, '0');
    return 'tubigtrack_backup_${y}_${m}_${d}_$h$min.db';
  }

  @override
  Future<AppSettings> getSettings() async {
    final totalStr = await _db.settingsDao.getValue(
      AppConstants.settingTotalBottleInventory,
    );
    final thresholdStr = await _db.settingsDao.getValue(
      AppConstants.settingLowInventoryThreshold,
    );
    return AppSettings(
      totalBottleInventory: int.tryParse(totalStr ?? '') ??
          AppConstants.defaultBottleInventory,
      lowInventoryThreshold: int.tryParse(thresholdStr ?? '') ??
          AppConstants.defaultLowInventoryThreshold,
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
      'ID,CustomerID,Quantity,PricePerBottle,Total,PaymentStatus,AmountPaid,Balance,Date,Time,DeliveryStatus,Notes',
    );
    for (final d in await _db.deliveriesDao.getAll()) {
      buffer.writeln(
        '"${d.id}","${d.customerId}",${d.quantity},${d.pricePerBottle},${d.totalAmount},"${d.paymentStatus}",${d.amountPaid},${d.remainingBalance},"${d.deliveryDate.toIso8601String()}","${d.deliveryTime ?? ''}","${d.deliveryStatus}","${d.notes ?? ''}"',
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
}
