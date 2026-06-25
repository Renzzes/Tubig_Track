import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../constants/app_constants.dart';

/// Manages TubigTrack folder layout under app internal storage.
class DataStorageService {
  DataStorageService._();

  static final DataStorageService instance = DataStorageService._();

  Directory? _rootCache;

  /// Ensures TubigTrack/Backups, Archives, CSV, Reports, Recovery exist.
  Future<Directory> ensureFolderStructure() async {
    final root = await rootDirectory();
    for (final sub in AppConstants.tubigTrackSubfolders) {
      final dir = Directory(p.join(root.path, sub));
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
    }
    return root;
  }

  Future<Directory> rootDirectory() async {
    if (_rootCache != null) return _rootCache!;
    final docs = await getApplicationDocumentsDirectory();
    _rootCache = Directory(p.join(docs.path, AppConstants.tubigTrackRoot));
    if (!await _rootCache!.exists()) {
      await _rootCache!.create(recursive: true);
    }
    return _rootCache!;
  }

  Future<Directory> backupsDirectory() =>
      _subfolder(AppConstants.backupsSubfolder);

  Future<Directory> archivesDirectory() =>
      _subfolder(AppConstants.archivesSubfolder);

  Future<Directory> csvDirectory() => _subfolder(AppConstants.csvSubfolder);

  Future<Directory> reportsDirectory() =>
      _subfolder(AppConstants.reportsSubfolder);

  Future<Directory> recoveryDirectory() =>
      _subfolder(AppConstants.recoverySubfolder);

  Future<Directory> _subfolder(String name) async {
    await ensureFolderStructure();
    final root = await rootDirectory();
    final dir = Directory(p.join(root.path, name));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Resolves the live SQLite database file (`.sqlite` or extensionless).
  Future<File> resolveDatabaseFile() async {
    final docs = await getApplicationDocumentsDirectory();
    final candidates = [
      File(p.join(docs.path, '${AppConstants.dbFileName}.sqlite')),
      File(p.join(docs.path, AppConstants.dbFileName)),
    ];
    for (final file in candidates) {
      if (await file.exists()) return file;
    }
    return candidates.first;
  }

  String timestampForFilename() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    final h = now.hour.toString().padLeft(2, '0');
    final min = now.minute.toString().padLeft(2, '0');
    return '${y}_${m}_${d}_$h-$min';
  }

  /// Format used for manual database backups: 2026-06-25_10-30
  String backupTimestampForFilename() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    final h = now.hour.toString().padLeft(2, '0');
    final min = now.minute.toString().padLeft(2, '0');
    return '${y}-${m}-${d}_$h-$min';
  }

  String backupFileName({String prefix = 'TubigTrack_Backup'}) =>
      '${prefix}_${backupTimestampForFilename()}.db';

  String archiveZipFileName() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return 'BusinessArchive_$y-$m-$d.zip';
  }

  String emergencyBackupFileName() =>
      'Emergency_${timestampForFilename()}.db';

  /// Writes a JSON sidecar next to [filePath] with backup metadata.
  Future<void> writeMetadataSidecar(
    String filePath, {
    required String appVersion,
    required int databaseVersion,
    String type = 'backup',
  }) async {
    final metaPath = '$filePath.meta.json';
    final meta = {
      'type': type,
      'appVersion': appVersion,
      'databaseVersion': databaseVersion,
      'createdAt': DateTime.now().toIso8601String(),
      'fileName': p.basename(filePath),
    };
    await File(metaPath).writeAsString(jsonEncode(meta));
  }

  Future<Map<String, dynamic>?> readMetadataSidecar(String filePath) async {
    final metaFile = File('$filePath.meta.json');
    if (!await metaFile.exists()) return null;
    try {
      return jsonDecode(await metaFile.readAsString()) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<int> directorySizeBytes(Directory dir) async {
    if (!await dir.exists()) return 0;
    var total = 0;
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        total += await entity.length();
      }
    }
    return total;
  }

  Future<int> fileCountIn(Directory dir, {List<String>? extensions}) async {
    if (!await dir.exists()) return 0;
    var count = 0;
    await for (final entity in dir.list(followLinks: false)) {
      if (entity is! File) continue;
      if (extensions == null ||
          extensions.any((e) => entity.path.toLowerCase().endsWith(e))) {
        count++;
      }
    }
    return count;
  }

  Future<StorageSummary> getStorageSummary() async {
    await ensureFolderStructure();
    final backups = await backupsDirectory();
    final archives = await archivesDirectory();
    final csv = await csvDirectory();
    final reports = await reportsDirectory();
    final recovery = await recoveryDirectory();
    final root = await rootDirectory();

    return StorageSummary(
      rootPath: root.path,
      backupsPath: backups.path,
      archivesPath: archives.path,
      csvPath: csv.path,
      reportsPath: reports.path,
      recoveryPath: recovery.path,
      backupCount: await fileCountIn(backups, extensions: ['.db']),
      archiveCount: await fileCountIn(archives, extensions: ['.zip', '.db']),
      csvCount: await fileCountIn(csv, extensions: ['.csv']),
      reportCount: await fileCountIn(
        reports,
        extensions: ['.pdf', '.xlsx', '.csv'],
      ),
      recoveryCount: await fileCountIn(recovery, extensions: ['.db']),
      totalBytes: await directorySizeBytes(root),
    );
  }

  String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// User-facing relative path shown in dialogs.
  String displayPath(String absolutePath) {
    final idx = absolutePath.indexOf(AppConstants.tubigTrackRoot);
    if (idx >= 0) {
      return absolutePath.substring(idx).replaceAll('\\', '/');
    }
    return 'TubigTrack/${p.basename(absolutePath)}';
  }
}

class StorageSummary {
  final String rootPath;
  final String backupsPath;
  final String archivesPath;
  final String csvPath;
  final String reportsPath;
  final String recoveryPath;
  final int backupCount;
  final int archiveCount;
  final int csvCount;
  final int reportCount;
  final int recoveryCount;
  final int totalBytes;

  const StorageSummary({
    required this.rootPath,
    required this.backupsPath,
    required this.archivesPath,
    required this.csvPath,
    required this.reportsPath,
    required this.recoveryPath,
    required this.backupCount,
    required this.archiveCount,
    required this.csvCount,
    required this.reportCount,
    required this.recoveryCount,
    required this.totalBytes,
  });
}
