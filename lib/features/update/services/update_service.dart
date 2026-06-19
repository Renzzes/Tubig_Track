import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../domain/entities/update_channel.dart';
import '../domain/entities/update_history_entry.dart';
import '../domain/entities/update_info.dart';
import '../domain/repositories/backup_repository.dart';
import '../domain/repositories/update_repository.dart';

enum UpdateCheckStatus {
  idle,
  checking,
  upToDate,
  updateAvailable,
  offline,
  error,
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

  Future<UpdateCheckResult> checkForUpdates() async {
    try {
      final packageInfo = await getPackageInfo();
      final currentBuild = int.tryParse(packageInfo.buildNumber) ?? 0;
      final channel = await _updateRepository.getUpdateChannel();

      final updateInfo = await _updateRepository.fetchLatestUpdate(channel);
      await _updateRepository.saveLastCheckTime(DateTime.now());

      if (updateInfo == null) {
        return UpdateCheckResult(
          status: UpdateCheckStatus.offline,
          currentVersion: packageInfo.version,
          currentBuild: currentBuild,
        );
      }

      if (!updateInfo.isNewerThan(currentBuild: currentBuild)) {
        return UpdateCheckResult(
          status: UpdateCheckStatus.upToDate,
          currentVersion: packageInfo.version,
          currentBuild: currentBuild,
        );
      }

      return UpdateCheckResult(
        status: UpdateCheckStatus.updateAvailable,
        currentVersion: packageInfo.version,
        currentBuild: currentBuild,
        updateInfo: updateInfo,
      );
    } on SocketException {
      await _updateRepository.saveLastCheckTime(DateTime.now());
      final packageInfo = await getPackageInfo();
      return UpdateCheckResult(
        status: UpdateCheckStatus.offline,
        currentVersion: packageInfo.version,
        currentBuild: int.tryParse(packageInfo.buildNumber) ?? 0,
      );
    } on http.ClientException {
      await _updateRepository.saveLastCheckTime(DateTime.now());
      final packageInfo = await getPackageInfo();
      return UpdateCheckResult(
        status: UpdateCheckStatus.offline,
        currentVersion: packageInfo.version,
        currentBuild: int.tryParse(packageInfo.buildNumber) ?? 0,
      );
    } catch (_) {
      final packageInfo = await getPackageInfo();
      return UpdateCheckResult(
        status: UpdateCheckStatus.error,
        currentVersion: packageInfo.version,
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
    }
  }

  Future<String> downloadAndInstall(
    UpdateInfo updateInfo, {
    required void Function(double progress) onProgress,
  }) async {
    final packageInfo = await getPackageInfo();
    final currentBuild = int.tryParse(packageInfo.buildNumber) ?? 0;

    if (!updateInfo.isNewerThan(currentBuild: currentBuild)) {
      throw Exception('Cannot install: version is not newer than current');
    }

    await _backupRepository.createPreUpdateBackup();
    onProgress(0.1);

    final tempDir = await getTemporaryDirectory();
    final apkPath = p.join(tempDir.path, 'tubigtrack_update.apk');
    final apkFile = File(apkPath);
    if (await apkFile.exists()) {
      await apkFile.delete();
    }

    final request = http.Request('GET', Uri.parse(updateInfo.apkUrl));
    final response = await _httpClient.send(request);

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
  final UpdateInfo? updateInfo;

  const UpdateCheckResult({
    required this.status,
    required this.currentVersion,
    required this.currentBuild,
    this.updateInfo,
  });
}
