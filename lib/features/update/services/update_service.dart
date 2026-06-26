import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/automatic_backup_service.dart';
import '../../../core/utils/version_utils.dart';
import '../domain/entities/update_channel.dart';
import '../domain/entities/update_fetch_result.dart';
import '../domain/entities/update_history_entry.dart';
import '../domain/entities/update_info.dart';
import '../domain/repositories/backup_repository.dart';
import '../domain/repositories/update_repository.dart';

enum UpdateCheckStatus {
  idle,
  checking,
  upToDate,
  updateAvailable,
  networkError,
  apiError,
}

class UpdateService {
  final UpdateRepository _updateRepository;
  final BackupRepository _backupRepository;
  final http.Client _httpClient;

  UpdateService({
    required UpdateRepository updateRepository,
    required BackupRepository backupRepository,
    http.Client? httpClient,
  })  : _updateRepository = updateRepository,
        _backupRepository = backupRepository,
        _httpClient = httpClient ?? http.Client();

  Future<PackageInfo> getPackageInfo() => PackageInfo.fromPlatform();

  Future<UpdateChannel> getChannel() => _updateRepository.getUpdateChannel();

  Future<void> setChannel(UpdateChannel channel) =>
      _updateRepository.setUpdateChannel(channel);

  Future<DateTime?> getLastCheckTime() => _updateRepository.getLastCheckTime();

  Future<List<UpdateHistoryEntry>> getHistory() =>
      _updateRepository.getUpdateHistory();

  UpdateFetchResult? get lastFetchResult => _updateRepository.lastFetchResult;

  Future<UpdateFetchResult> testGitHubConnection() async {
    final channel = await _updateRepository.getUpdateChannel();
    return _updateRepository.testGitHubConnection(channel);
  }

  Future<UpdateCheckResult> checkForUpdates() async {
    try {
      final packageInfo = await getPackageInfo();
      final currentVersion = VersionUtils.normalize(packageInfo.version);
      final currentBuild = int.tryParse(packageInfo.buildNumber) ?? 0;
      final channel = await _updateRepository.getUpdateChannel();

      debugPrint('[Update] Current installed version: $currentVersion');
      debugPrint('[Update] Current build: $currentBuild');
      debugPrint('[Update] Channel: ${channel.value}');

      final fetchResult = await _updateRepository.fetchLatestRelease(channel);
      await _updateRepository.saveLastCheckTime(DateTime.now());

      debugPrint('[Update] Fetch error: ${fetchResult.error}');
      debugPrint('[Update] GitHub latest version: ${fetchResult.latestVersion}');

      if (fetchResult.isNetworkError) {
        return UpdateCheckResult(
          status: UpdateCheckStatus.networkError,
          currentVersion: currentVersion,
          currentBuild: currentBuild,
          fetchResult: fetchResult,
        );
      }

      if (fetchResult.isApiError || fetchResult.updateInfo == null) {
        return UpdateCheckResult(
          status: UpdateCheckStatus.apiError,
          currentVersion: currentVersion,
          currentBuild: currentBuild,
          fetchResult: fetchResult,
        );
      }

      final updateInfo = fetchResult.updateInfo!;

      if (!updateInfo.isNewerThan(
        currentVersion: currentVersion,
        currentBuild: currentBuild,
      )) {
        debugPrint('[Update] Up to date — installed $currentVersion == latest ${updateInfo.version}');
        return UpdateCheckResult(
          status: UpdateCheckStatus.upToDate,
          currentVersion: currentVersion,
          currentBuild: currentBuild,
          latestVersion: updateInfo.version,
          fetchResult: fetchResult,
        );
      }

      debugPrint('[Update] Update available: ${updateInfo.version}');
      return UpdateCheckResult(
        status: UpdateCheckStatus.updateAvailable,
        currentVersion: currentVersion,
        currentBuild: currentBuild,
        latestVersion: updateInfo.version,
        updateInfo: updateInfo,
        fetchResult: fetchResult,
      );
    } catch (e, st) {
      debugPrint('[Update] checkForUpdates error: $e');
      debugPrint('[Update] Stack: $st');
      final packageInfo = await getPackageInfo();
      return UpdateCheckResult(
        status: UpdateCheckStatus.apiError,
        currentVersion: VersionUtils.normalize(packageInfo.version),
        currentBuild: int.tryParse(packageInfo.buildNumber) ?? 0,
      );
    }
  }

  Future<void> recordVersionIfUpdated() async {
    final packageInfo = await getPackageInfo();
    final currentBuild = int.tryParse(packageInfo.buildNumber) ?? 0;
    final recorded = await _updateRepository.getRecordedBuild();
    final pendingNotes = await _updateRepository.getPendingReleaseNotes();

    if (recorded == null) {
      await _updateRepository.setRecordedBuild(currentBuild);
      return;
    }

    if (currentBuild > recorded) {
      await _updateRepository.addUpdateHistoryEntry(
        UpdateHistoryEntry(
          version: packageInfo.version,
          build: currentBuild,
          installedAt: DateTime.now(),
          releaseNotes: pendingNotes,
        ),
      );
      await _updateRepository.setRecordedBuild(currentBuild);
      await _updateRepository.clearPendingReleaseNotes();
      await _updateRepository.setDismissedUpdateVersion('');
    }
  }

  Future<String> downloadAndInstall(
    UpdateInfo updateInfo, {
    required void Function(double progress) onProgress,
  }) async {
    final packageInfo = await getPackageInfo();
    final currentVersion = VersionUtils.normalize(packageInfo.version);
    final currentBuild = int.tryParse(packageInfo.buildNumber) ?? 0;

    if (!updateInfo.isNewerThan(
      currentVersion: currentVersion,
      currentBuild: currentBuild,
    )) {
      throw Exception('Cannot install: version is not newer than current');
    }

    debugPrint('[Update] Downloading APK from: ${updateInfo.apkUrl}');

    final preUpdateBackup =
        await AutomaticBackupService.instance.runBeforeUpdateBackup(
      _backupRepository,
    );
    if (preUpdateBackup != null) {
      debugPrint(
        '[Update] Pre-update backup created: ${preUpdateBackup.path} '
        '(verified=${preUpdateBackup.verification.passed})',
      );
    }
    onProgress(0.1);

    final tempDir = await getTemporaryDirectory();
    final apkPath = p.join(tempDir.path, 'tubigtrack_update.apk');
    final apkFile = File(apkPath);
    if (await apkFile.exists()) {
      await apkFile.delete();
    }

    final request = http.Request('GET', Uri.parse(updateInfo.apkUrl));
    request.headers['User-Agent'] = 'TubigTrack/${AppConstants.appVersion}';
    final response = await _httpClient.send(request);

    debugPrint('[Update] Download response status: ${response.statusCode}');

    if (response.statusCode != 200) {
      throw Exception('Download failed (${response.statusCode})');
    }

    final totalBytes = response.contentLength ?? 0;
    var receivedBytes = 0;
    final sink = apkFile.openWrite();

    await for (final chunk in response.stream) {
      receivedBytes += chunk.length;
      sink.add(chunk);
      if (totalBytes > 0) {
        final downloadProgress = 0.1 + (receivedBytes / totalBytes) * 0.8;
        onProgress(downloadProgress.clamp(0.1, 0.9));
      }
    }

    await sink.close();
    onProgress(0.95);

    final stat = await apkFile.stat();
    if (stat.size == 0) {
      throw Exception('Downloaded APK is empty');
    }

    debugPrint('[Update] APK downloaded: ${stat.size} bytes');

    onProgress(1.0);
    await _updateRepository.savePendingReleaseNotes(updateInfo.releaseNotes);
    await _installApk(apkPath);
    return apkPath;
  }

  Future<void> _installApk(String apkPath) async {
    if (Platform.isAndroid) {
      final status = await Permission.requestInstallPackages.request();
      if (!status.isGranted) {
        throw Exception('Install permission denied');
      }
    }

    final result = await OpenFilex.open(
      apkPath,
      type: 'application/vnd.android.package-archive',
    );

    if (result.type != ResultType.done) {
      throw Exception(result.message);
    }
  }
}

class UpdateCheckResult {
  final UpdateCheckStatus status;
  final String currentVersion;
  final int currentBuild;
  final String? latestVersion;
  final UpdateInfo? updateInfo;
  final UpdateFetchResult? fetchResult;

  const UpdateCheckResult({
    required this.status,
    required this.currentVersion,
    required this.currentBuild,
    this.latestVersion,
    this.updateInfo,
    this.fetchResult,
  });

  bool get isUpdateAvailable =>
      status == UpdateCheckStatus.updateAvailable && updateInfo != null;
}
