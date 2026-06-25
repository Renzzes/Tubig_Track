import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../constants/app_constants.dart';
import '../database/app_database.dart';
import '../database/backup_metadata.dart';
import 'data_storage_service.dart';

/// Reads and writes backup metadata.json companion files.
class BackupMetadataService {
  BackupMetadataService._({DataStorageService? storage})
      : _storage = storage ?? DataStorageService.instance;

  static final BackupMetadataService instance =
      BackupMetadataService._();

  final DataStorageService _storage;

  String metadataPathFor(String dbPath) =>
      '${p.withoutExtension(dbPath)}_metadata.json';

  String legacyMetaPathFor(String dbPath) => '$dbPath.meta.json';

  Future<void> writeMetadata(String dbPath, BackupMetadata metadata) async {
    final path = metadataPathFor(dbPath);
    await File(path).writeAsString(
      const JsonEncoder.withIndent('  ').convert(metadata.toJson()),
    );
  }

  Future<BackupMetadata?> readMetadata(String dbPath) async {
    for (final path in [
      metadataPathFor(dbPath),
      legacyMetaPathFor(dbPath),
    ]) {
      final file = File(path);
      if (!await file.exists()) continue;
      try {
        final json =
            jsonDecode(await file.readAsString()) as Map<String, dynamic>;
        return BackupMetadata.fromJson(json);
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  Future<BackupMetadata> buildFromDatabase(
    AppDatabase db,
    String dbPath,
  ) async {
    final file = File(dbPath);
    final sizeBytes = await file.length();
    final customers = (await db.customersDao.getAll()).length;
    final deliveries = (await db.deliveriesDao.getAll()).length;
    final inventoryTransactions =
        (await db.bottleTransactionsDao.getAll()).length;

    return BackupMetadata(
      appVersion: AppConstants.appVersion,
      databaseSchema: AppDatabase.currentSchemaVersion,
      createdAt: DateTime.now(),
      customers: customers,
      deliveries: deliveries,
      inventoryTransactions: inventoryTransactions,
      databaseSize: _storage.formatBytes(sizeBytes),
      fileName: p.basename(dbPath),
    );
  }

  Future<void> writeMetadataForDatabase(
    AppDatabase db,
    String dbPath,
  ) async {
    final metadata = await buildFromDatabase(db, dbPath);
    await writeMetadata(dbPath, metadata);
  }

  Future<void> renameMetadata(String oldDbPath, String newDbPath) async {
    for (final resolver in [metadataPathFor, legacyMetaPathFor]) {
      final oldMeta = File(resolver(oldDbPath));
      if (await oldMeta.exists()) {
        await oldMeta.rename(resolver(newDbPath));
        return;
      }
    }
  }

  Future<void> deleteMetadata(String dbPath) async {
    for (final path in [
      metadataPathFor(dbPath),
      legacyMetaPathFor(dbPath),
    ]) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }
}
