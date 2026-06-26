import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../constants/app_constants.dart';
import 'data_storage_service.dart';

/// Persists restore operation logs under TubigTrack/Recovery/RestoreLogs/.
class RestoreLogService {
  RestoreLogService._({DataStorageService? storage})
      : _storage = storage ?? DataStorageService.instance;

  static final RestoreLogService instance = RestoreLogService._();

  final DataStorageService _storage;

  Future<Directory> restoreLogsDirectory() async {
    await _storage.ensureFolderStructure();
    final recovery = await _storage.recoveryDirectory();
    final dir = Directory(
      p.join(recovery.path, AppConstants.restoreLogsSubfolder),
    );
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<String> writeLog({
    required String backupFileName,
    required String backupAppVersion,
    required int backupSchema,
    required int currentSchema,
    required List<int> migrationStepsExecuted,
    required bool success,
    String? errorMessage,
    DateTime? restoreTime,
    List<String> events = const [],
    bool rollbackFailed = false,
    String? safetyCopyPath,
  }) async {
    final dir = await restoreLogsDirectory();
    final time = restoreTime ?? DateTime.now();
    final stamp = _storage.timestampForFilename();
    final logPath = p.join(dir.path, 'restore_$stamp.log.json');

    final payload = {
      'restoreTime': time.toIso8601String(),
      'backupFileName': backupFileName,
      'backupAppVersion': backupAppVersion,
      'backupSchema': backupSchema,
      'currentAppVersion': AppConstants.appVersion,
      'currentSchema': currentSchema,
      'migrationStepsExecuted': migrationStepsExecuted,
      'success': success,
      if (errorMessage != null) 'errorMessage': errorMessage,
      if (events.isNotEmpty) 'events': events,
      if (rollbackFailed) 'rollbackFailed': true,
      if (safetyCopyPath != null) 'safetyCopyPath': safetyCopyPath,
    };

    await File(logPath).writeAsString(
      JsonEncoder.withIndent('  ').convert(payload),
    );
    return logPath;
  }
}
