import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import 'data_storage_service.dart';

/// Result of a storage health check run from Settings → Storage.
class StorageTestResult {
  final bool writePermission;
  final bool readPermission;
  final bool folderExists;
  final int backupCount;
  final bool reportsAccessible;
  final bool csvAccessible;
  final DateTime testedAt;
  final String locationLabel;

  const StorageTestResult({
    required this.writePermission,
    required this.readPermission,
    required this.folderExists,
    required this.backupCount,
    required this.reportsAccessible,
    required this.csvAccessible,
    required this.testedAt,
    required this.locationLabel,
  });

  bool get allPassed =>
      writePermission &&
      readPermission &&
      folderExists &&
      reportsAccessible &&
      csvAccessible;
}

class StorageTestService {
  StorageTestService._();

  static final StorageTestService instance = StorageTestService._();

  static const _prefix = 'tubigtrack_storage_test_';

  Future<StorageTestResult> runTest() async {
    final storage = DataStorageService.instance;
    await storage.ensureFolderStructure();
    final root = await storage.rootDirectory();
    final testedAt = DateTime.now();

    var writeOk = false;
    var readOk = false;
    try {
      final probe = File(
        p.join(root.path, '.tubigtrack_test_${testedAt.millisecondsSinceEpoch}'),
      );
      await probe.writeAsString('test');
      writeOk = await probe.exists();
      readOk = await probe.readAsString() == 'test';
      await probe.delete();
    } catch (_) {
      writeOk = false;
      readOk = false;
    }

    final folderExists = await root.exists();
    final backups = await storage.backupsDirectory();
    final reports = await storage.reportsDirectory();
    final csv = await storage.csvDirectory();

    final result = StorageTestResult(
      writePermission: writeOk,
      readPermission: readOk,
      folderExists: folderExists,
      backupCount: await storage.fileCountIn(backups, extensions: ['.db']),
      reportsAccessible: await _dirAccessible(reports),
      csvAccessible: await _dirAccessible(csv),
      testedAt: testedAt,
      locationLabel: storage.friendlyLocationLabel(),
    );

    await _persistResult(result);
    return result;
  }

  Future<StorageTestResult?> loadLastTest() async {
    final prefs = await SharedPreferences.getInstance();
    final testedAtStr = prefs.getString(AppConstants.prefStorageLastTestAt);
    if (testedAtStr == null) return null;

    final testedAt = DateTime.tryParse(testedAtStr);
    if (testedAt == null) return null;

    return StorageTestResult(
      writePermission: prefs.getBool('${_prefix}write') ?? false,
      readPermission: prefs.getBool('${_prefix}read') ?? false,
      folderExists: prefs.getBool('${_prefix}folder') ?? false,
      backupCount: prefs.getInt('${_prefix}backups') ?? 0,
      reportsAccessible: prefs.getBool('${_prefix}reports') ?? false,
      csvAccessible: prefs.getBool('${_prefix}csv') ?? false,
      testedAt: testedAt,
      locationLabel: prefs.getString('${_prefix}location') ??
          DataStorageService.instance.friendlyLocationLabel(),
    );
  }

  Future<void> _persistResult(StorageTestResult r) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefStorageLastTestAt, r.testedAt.toIso8601String());
    await prefs.setBool('${_prefix}write', r.writePermission);
    await prefs.setBool('${_prefix}read', r.readPermission);
    await prefs.setBool('${_prefix}folder', r.folderExists);
    await prefs.setInt('${_prefix}backups', r.backupCount);
    await prefs.setBool('${_prefix}reports', r.reportsAccessible);
    await prefs.setBool('${_prefix}csv', r.csvAccessible);
    await prefs.setString('${_prefix}location', r.locationLabel);
  }

  Future<bool> _dirAccessible(Directory dir) async {
    try {
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      final probe = File(p.join(dir.path, '.access_probe'));
      await probe.writeAsString('ok');
      final ok = await probe.readAsString() == 'ok';
      await probe.delete();
      return ok;
    } catch (_) {
      return false;
    }
  }
}
