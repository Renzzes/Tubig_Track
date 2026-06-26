import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import 'tubig_track_storage_channel.dart';

enum StorageLocationKind {
  /// Internal Storage/TubigTrack (user-visible).
  publicPrimary,

  /// User-granted folder via Storage Access Framework.
  publicSaf,

  /// App-private documents/TubigTrack fallback.
  privateFallback,
}

/// Manages TubigTrack folder layout under public or private storage.
class DataStorageService {
  DataStorageService._();

  static final DataStorageService instance = DataStorageService._();

  Directory? _rootCache;
  StorageLocationKind _kind = StorageLocationKind.privateFallback;
  String? _persistedRootPath;
  bool _initialized = false;

  StorageLocationKind get storageKind => _kind;

  bool get isPublicStorage =>
      _kind == StorageLocationKind.publicPrimary ||
      _kind == StorageLocationKind.publicSaf;

  bool get isInitialized => _initialized;

  /// Initializes storage on first launch: public TubigTrack when possible, else private.
  Future<StorageInitResult> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _persistedRootPath = prefs.getString(AppConstants.prefStorageRootPath);
    final savedKindName = prefs.getString(AppConstants.prefStorageKind);

    if (_persistedRootPath != null) {
      final savedRoot = Directory(_persistedRootPath!);
      if (await _verifyWritableRoot(savedRoot)) {
        _applyRoot(savedRoot, _kindFromName(savedKindName));
        await ensureFolderStructure();
        _initialized = true;
        return StorageInitResult(
          kind: _kind,
          rootPath: savedRoot.path,
          isNewSetup: false,
        );
      }
    }

    if (Platform.isAndroid) {
      await _requestAndroidStoragePermissions();
      final publicPath = await TubigTrackStorageChannel.initPublicStorage();
      if (publicPath != null) {
        final root = Directory(publicPath);
        if (await _verifyWritableRoot(root)) {
          await _applyAndPersist(root, StorageLocationKind.publicPrimary);
          _initialized = true;
          return StorageInitResult(
            kind: _kind,
            rootPath: root.path,
            isNewSetup: true,
          );
        }
      }
    }

    final privateRoot = await _privateRootDirectory();
    await _applyAndPersist(privateRoot, StorageLocationKind.privateFallback);
    _initialized = true;
    return StorageInitResult(
      kind: _kind,
      rootPath: privateRoot.path,
      isNewSetup: true,
      usedFallback: true,
    );
  }

  /// Lets the owner pick a public TubigTrack folder via SAF (Android 11+).
  Future<bool> requestPublicFolderViaSaf() => changeStorageLocation();

  /// Pick a new storage root (Internal Storage, SD card, Documents, synced folders, etc.).
  Future<bool> changeStorageLocation() async {
    final picked = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Choose folder for TubigTrack data',
    );
    if (picked == null || picked.isEmpty) return false;

    final root = await _resolveTubigTrackRoot(picked);
    if (!await _verifyWritableRoot(root)) return false;

    final kind = await _kindForRoot(root);
    await _applyAndPersist(root, kind);
    return true;
  }

  Future<Directory> _resolveTubigTrackRoot(String pickedPath) async {
    final normalized = pickedPath.replaceAll('\\', '/');
    final baseName = p.basename(normalized);
    if (baseName.toLowerCase() == AppConstants.tubigTrackRoot.toLowerCase()) {
      final root = Directory(pickedPath);
      if (!await root.exists()) {
        await root.create(recursive: true);
      }
      return root;
    }

    final root = Directory(p.join(pickedPath, AppConstants.tubigTrackRoot));
    if (!await root.exists()) {
      await root.create(recursive: true);
    }
    return root;
  }

  Future<StorageLocationKind> _kindForRoot(Directory root) async {
    if (Platform.isAndroid) {
      final primaryPath = await TubigTrackStorageChannel.initPublicStorage();
      if (primaryPath != null &&
          _normalizePath(root.path) == _normalizePath(primaryPath)) {
        return StorageLocationKind.publicPrimary;
      }
    }

    final docs = await getApplicationDocumentsDirectory();
    if (_normalizePath(root.path).startsWith(_normalizePath(docs.path))) {
      return StorageLocationKind.privateFallback;
    }

    return StorageLocationKind.publicSaf;
  }

  String _normalizePath(String path) =>
      path.replaceAll('\\', '/').replaceAll(RegExp(r'/+$'), '');

  Future<void> _applyAndPersist(
    Directory root,
    StorageLocationKind kind,
  ) async {
    _applyRoot(root, kind);
    await ensureFolderStructure();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefStorageRootPath, root.path);
    await prefs.setString(AppConstants.prefStorageKind, kind.name);
  }

  void _applyRoot(Directory root, StorageLocationKind kind) {
    _rootCache = root;
    _kind = kind;
    _persistedRootPath = root.path;
  }

  StorageLocationKind _kindFromName(String? name) {
    return StorageLocationKind.values.firstWhere(
      (k) => k.name == name,
      orElse: () => StorageLocationKind.privateFallback,
    );
  }

  Future<void> _requestAndroidStoragePermissions() async {
    if (!Platform.isAndroid) return;
    await Permission.storage.request();
  }

  Future<Directory> _privateRootDirectory() async {
    final docs = await getApplicationDocumentsDirectory();
    final root = Directory(p.join(docs.path, AppConstants.tubigTrackRoot));
    if (!await root.exists()) {
      await root.create(recursive: true);
    }
    return root;
  }

  Future<bool> _verifyWritableRoot(Directory root) async {
    try {
      if (!await root.exists()) {
        await root.create(recursive: true);
      }
      final probe = File(p.join(root.path, '.tubigtrack_probe'));
      await probe.writeAsString('ok');
      await probe.delete();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Ensures TubigTrack/Backups, Archives, CSV, Reports, Recovery, Recovery/RestoreLogs.
  Future<Directory> ensureFolderStructure() async {
    final root = await rootDirectory();
    return ensureFolderStructureAt(root);
  }

  Future<Directory> ensureFolderStructureAt(Directory root) async {
    for (final sub in AppConstants.tubigTrackSubfolders) {
      final dir = Directory(p.join(root.path, sub));
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
    }
    final restoreLogs = Directory(
      p.join(
        root.path,
        AppConstants.recoverySubfolder,
        AppConstants.restoreLogsSubfolder,
      ),
    );
    if (!await restoreLogs.exists()) {
      await restoreLogs.create(recursive: true);
    }
    return root;
  }

  Future<Directory> rootDirectory() async {
    if (!_initialized) {
      await initialize();
    }
    if (_rootCache != null) return _rootCache!;
    final privateRoot = await _privateRootDirectory();
    _rootCache = privateRoot;
    return privateRoot;
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

  /// Live SQLite database always lives in app-private documents (not moved).
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

  /// Relative TubigTrack subfolder for [absoluteFolderPath], e.g. `Backups`.
  String? relativeSubfolderPath(String absoluteFolderPath) {
    final normalized = absoluteFolderPath.replaceAll('\\', '/');
    final root = _persistedRootPath?.replaceAll('\\', '/');
    if (root != null && normalized.startsWith(root)) {
      return normalized.substring(root.length).replaceFirst(RegExp('^/'), '');
    }
    final idx = normalized.indexOf(AppConstants.tubigTrackRoot);
    if (idx >= 0) {
      return normalized
          .substring(idx + AppConstants.tubigTrackRoot.length)
          .replaceFirst(RegExp('^/'), '');
    }
    return null;
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
      isPublicStorage: isPublicStorage,
      locationLabel: friendlyLocationLabel(),
    );
  }

  String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// User-facing location label for the TubigTrack root folder.
  String friendlyLocationLabel() {
    if (_kind == StorageLocationKind.privateFallback) {
      return 'App private storage/${AppConstants.tubigTrackRoot}';
    }

    final path = _normalizePath(_persistedRootPath ?? '');
    if (path.isEmpty) {
      return '${AppConstants.tubigTrackRoot}';
    }

    if (path.endsWith('/storage/emulated/0/${AppConstants.tubigTrackRoot}') ||
        path == '/storage/emulated/0/${AppConstants.tubigTrackRoot}') {
      return 'Internal Storage/${AppConstants.tubigTrackRoot}';
    }

    final segments =
        path.split('/').where((segment) => segment.isNotEmpty).toList();
    final tubigIndex = segments.lastIndexWhere(
      (segment) =>
          segment.toLowerCase() == AppConstants.tubigTrackRoot.toLowerCase(),
    );
    if (tubigIndex >= 0) {
      var start = tubigIndex;
      if (start > 0) {
        final parent = segments[start - 1].toLowerCase();
        if (parent == '0' && start > 1 && segments[start - 2] == 'emulated') {
          start -= 2;
          if (start > 0 && segments[start - 1] == 'storage') {
            start -= 1;
          }
        } else if (parent == 'emulated') {
          start -= 1;
          if (start > 0 && segments[start - 1] == 'storage') {
            start -= 1;
          }
        } else if (RegExp(r'^[0-9A-Fa-f-]{8,}$').hasMatch(segments[start - 1])) {
          return 'SD Card/${segments.sublist(start).join('/')}';
        }
      }

      final labelSegments = segments.sublist(start);
      if (labelSegments.isNotEmpty &&
          labelSegments.first.toLowerCase() == 'storage' &&
          labelSegments.length > 1) {
        if (labelSegments.length >= 3 &&
            labelSegments[1] == 'emulated' &&
            labelSegments[2] == '0') {
          return 'Internal Storage/${labelSegments.sublist(3).join('/')}';
        }
        return 'SD Card/${labelSegments.sublist(1).join('/')}';
      }

      return labelSegments.join('/');
    }

    return path;
  }

  /// User-facing location label (alias for dialogs and paths).
  String displayRootPath() => friendlyLocationLabel();

  /// User-facing relative path shown in dialogs.
  String displayPath(String absolutePath) {
    final relative = relativeSubfolderPath(absolutePath);
    if (relative != null && relative.isNotEmpty) {
      return '${displayRootPath()}/$relative'.replaceAll('\\', '/');
    }
    final idx = absolutePath.indexOf(AppConstants.tubigTrackRoot);
    if (idx >= 0) {
      return absolutePath.substring(idx).replaceAll('\\', '/');
    }
    return '${displayRootPath()}/${p.basename(absolutePath)}';
  }
}

class StorageInitResult {
  final StorageLocationKind kind;
  final String rootPath;
  final bool isNewSetup;
  final bool usedFallback;

  const StorageInitResult({
    required this.kind,
    required this.rootPath,
    this.isNewSetup = false,
    this.usedFallback = false,
  });
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
  final bool isPublicStorage;
  final String locationLabel;

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
    this.isPublicStorage = false,
    this.locationLabel = 'Internal Storage/TubigTrack',
  });
}
