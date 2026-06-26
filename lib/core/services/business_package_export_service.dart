import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../constants/app_constants.dart';
import '../database/app_database.dart';
import 'backup_metadata_service.dart';
import 'data_storage_service.dart';
import 'restore_log_service.dart';

/// Exports full business packages and lightweight archive zips.
class BusinessPackageExportService {
  BusinessPackageExportService._();

  static final BusinessPackageExportService instance =
      BusinessPackageExportService._();

  Future<String> exportBusinessPackage({required AppDatabase db}) async {
    final storage = DataStorageService.instance;
    await storage.ensureFolderStructure();

    final archiveDir = await storage.archivesDirectory();
    final now = DateTime.now();
    final dateStamp =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    var zipPath = p.join(
      archiveDir.path,
      'TubigTrack_Business_$dateStamp.zip',
    );
    if (await File(zipPath).exists()) {
      zipPath = p.join(
        archiveDir.path,
        'TubigTrack_Business_${storage.backupTimestampForFilename()}.zip',
      );
    }

    final encoder = ZipFileEncoder()..create(zipPath);
    try {
      await _addDatabase(encoder, db, zipPath);
      await _addCsvFolder(encoder, storage);
      await _addReportsFolder(encoder, storage);
      await _addBusinessSettings(encoder, db);
      await _addBackupMetadata(encoder, db);
      await _addRestoreLogs(encoder);
      await _addReadmePdf(encoder, zipPath);
    } finally {
      encoder.close();
    }

    return zipPath;
  }

  Future<String> exportArchiveZip({
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
    try {
      await _addDatabase(encoder, db, zipPath, metadataService: metadataService);
      await _addCsvFolder(encoder, storage);
      await _addReportsFolder(encoder, storage);
    } finally {
      encoder.close();
    }

    return zipPath;
  }

  Future<void> _addDatabase(
    ZipFileEncoder encoder,
    AppDatabase db,
    String zipPath, {
    BackupMetadataService? metadataService,
  }) async {
    final storage = DataStorageService.instance;
    final dbFile = await storage.resolveDatabaseFile();
    if (!await dbFile.exists()) return;

    encoder.addFile(dbFile, 'Database/${p.basename(dbFile.path)}');

    final metaService = metadataService ?? BackupMetadataService.instance;
    final meta = await metaService.buildFromDatabase(db, dbFile.path);
    final metaFile = File('${p.withoutExtension(zipPath)}_pkg_meta.json');
    await metaFile.writeAsString(
      JsonEncoder.withIndent('  ').convert(meta.toJson()),
    );
    encoder.addFile(metaFile, 'BackupMetadata.json');
    await metaFile.delete();
  }

  Future<void> _addCsvFolder(
    ZipFileEncoder encoder,
    DataStorageService storage,
  ) async {
    final csvDir = await storage.csvDirectory();
    if (!await csvDir.exists()) return;
    for (final entity in csvDir.listSync()) {
      if (entity is File && entity.path.endsWith('.csv')) {
        encoder.addFile(entity, 'CSV/${p.basename(entity.path)}');
      }
    }
  }

  Future<void> _addReportsFolder(
    ZipFileEncoder encoder,
    DataStorageService storage,
  ) async {
    final reportsDir = await storage.reportsDirectory();
    if (!await reportsDir.exists()) return;
    for (final entity in reportsDir.listSync()) {
      if (entity is File) {
        final ext = p.extension(entity.path).toLowerCase();
        if (ext == '.pdf' || ext == '.xlsx' || ext == '.csv') {
          encoder.addFile(entity, 'Reports/${p.basename(entity.path)}');
        }
      }
    }
  }

  Future<void> _addBusinessSettings(
    ZipFileEncoder encoder,
    AppDatabase db,
  ) async {
    final settings = <String, String?>{};
    for (final key in [
      AppConstants.settingTotalBottleInventory,
      AppConstants.settingLowInventoryThreshold,
      AppConstants.settingMinBottles,
      AppConstants.settingMinGallons,
      AppConstants.settingMinCaps,
      AppConstants.settingMinWaterStocks,
      AppConstants.settingCostPerBottle,
    ]) {
      settings[key] = await db.settingsDao.getValue(key);
    }

    final payload = {
      'exportedAt': DateTime.now().toIso8601String(),
      'appVersion': AppConstants.appVersion,
      'settings': settings,
    };

    final temp = File('${Directory.systemTemp.path}/tubigtrack_settings.json');
    await temp.writeAsString(JsonEncoder.withIndent('  ').convert(payload));
    encoder.addFile(temp, 'BusinessSettings.json');
    await temp.delete();
  }

  Future<void> _addBackupMetadata(
    ZipFileEncoder encoder,
    AppDatabase db,
  ) async {
    final storage = DataStorageService.instance;
    final dbFile = await storage.resolveDatabaseFile();
    if (!await dbFile.exists()) return;

    final meta = await BackupMetadataService.instance.buildFromDatabase(
      db,
      dbFile.path,
    );
    final temp = File('${Directory.systemTemp.path}/tubigtrack_backup_meta.json');
    await temp.writeAsString(
      JsonEncoder.withIndent('  ').convert(meta.toJson()),
    );
    encoder.addFile(temp, 'BackupMetadata.json');
    await temp.delete();
  }

  Future<void> _addRestoreLogs(ZipFileEncoder encoder) async {
    final logsDir = await RestoreLogService.instance.restoreLogsDirectory();
    if (!await logsDir.exists()) return;
    for (final entity in logsDir.listSync()) {
      if (entity is File && entity.path.endsWith('.json')) {
        encoder.addFile(
          entity,
          'RestoreLogs/${p.basename(entity.path)}',
        );
      }
    }
  }

  Future<void> _addReadmePdf(ZipFileEncoder encoder, String zipPath) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'TubigTrack — Restore Instructions',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 16),
            pw.Text('Package created: ${DateTime.now().toIso8601String()}'),
            pw.SizedBox(height: 12),
            pw.Text(
              'This package contains your business database, CSV exports, '
              'reports, settings, backup metadata, and restore logs.',
            ),
            pw.SizedBox(height: 12),
            pw.Text('To restore on a new phone:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Bullet(text: 'Install TubigTrack'),
            pw.Bullet(text: 'Open Settings → Data Management → Recovery Center'),
            pw.Bullet(text: 'Choose Recover My Business → I changed phones'),
            pw.Bullet(text: 'Import the Database file from this package'),
            pw.SizedBox(height: 12),
            pw.Text(
              'For corrupted databases, use Restore Database from a verified '
              'backup in TubigTrack/Backups.',
            ),
          ],
        ),
      ),
    );

    final bytes = await pdf.save();
    final temp = File('${p.withoutExtension(zipPath)}_readme.pdf');
    await temp.writeAsBytes(bytes);
    encoder.addFile(temp, 'README_Restore_Instructions.pdf');
    await temp.delete();
  }
}

/// Backward-compatible archive export used by Archive & Reset.
Future<String> createBusinessArchiveZip({
  required AppDatabase db,
  required String appVersion,
}) {
  return BusinessPackageExportService.instance.exportArchiveZip(
    db: db,
    appVersion: appVersion,
  );
}
