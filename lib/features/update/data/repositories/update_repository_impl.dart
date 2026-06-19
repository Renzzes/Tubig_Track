import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/update_channel.dart';
import '../../domain/entities/update_fetch_result.dart';
import '../../domain/entities/update_history_entry.dart';
import '../../domain/repositories/update_repository.dart';
import '../github_release_parser.dart';

class UpdateRepositoryImpl implements UpdateRepository {
  static const _keyLastCheck = 'update_last_check';
  static const _keyChannel = 'update_channel';
  static const _keyHistory = 'update_history';
  static const _keyRecordedBuild = 'update_recorded_build';
  static const _keyPendingNotes = 'update_pending_notes';

  final http.Client _client;
  UpdateFetchResult? _lastFetchResult;

  UpdateRepositoryImpl({http.Client? client}) : _client = client ?? http.Client();

  @override
  UpdateFetchResult? get lastFetchResult => _lastFetchResult;

  Map<String, String> get _githubHeaders => {
        'Accept': 'application/vnd.github+json',
        'User-Agent': 'TubigTrack/${AppConstants.appVersion}',
      };

  @override
  Future<UpdateFetchResult> fetchLatestRelease(UpdateChannel channel) async {
    final result = channel == UpdateChannel.beta
        ? await _fetchBetaRelease()
        : await _fetchLatestRelease();
    _lastFetchResult = result;
    return result;
  }

  @override
  Future<UpdateFetchResult> testGitHubConnection(UpdateChannel channel) async {
    return fetchLatestRelease(channel);
  }

  Future<UpdateFetchResult> _fetchLatestRelease() async {
    final apiUrl = AppConstants.githubLatestReleaseUrl;
    debugPrint('[Update] API URL: $apiUrl');

    try {
      final response = await _client
          .get(Uri.parse(apiUrl), headers: _githubHeaders)
          .timeout(const Duration(seconds: 20));

      debugPrint('[Update] API response status: ${response.statusCode}');

      if (response.statusCode != 200) {
        debugPrint('[Update] API error body: ${response.body}');
        return UpdateFetchResult(
          statusCode: response.statusCode,
          apiUrl: apiUrl,
          error: UpdateFetchError.api,
          errorDetail: 'HTTP ${response.statusCode}',
        );
      }

      return _parseGitHubResponse(apiUrl, response.statusCode, response.body);
    } on SocketException catch (e, st) {
      debugPrint('[Update] Network error: $e');
      debugPrint('[Update] Stack: $st');
      return UpdateFetchResult(
        apiUrl: apiUrl,
        error: UpdateFetchError.network,
        errorDetail: e.message,
      );
    } on TimeoutException catch (e, st) {
      debugPrint('[Update] Timeout error: $e');
      debugPrint('[Update] Stack: $st');
      return UpdateFetchResult(
        apiUrl: apiUrl,
        error: UpdateFetchError.network,
        errorDetail: 'Request timed out',
      );
    } on http.ClientException catch (e, st) {
      debugPrint('[Update] Client error: $e');
      debugPrint('[Update] Stack: $st');
      return UpdateFetchResult(
        apiUrl: apiUrl,
        error: UpdateFetchError.network,
        errorDetail: e.message,
      );
    } catch (e, st) {
      debugPrint('[Update] Unexpected error: $e');
      debugPrint('[Update] Stack: $st');
      return UpdateFetchResult(
        apiUrl: apiUrl,
        error: UpdateFetchError.api,
        errorDetail: e.toString(),
      );
    }
  }

  Future<UpdateFetchResult> _fetchBetaRelease() async {
    final apiUrl = AppConstants.githubReleasesUrl;
    debugPrint('[Update] Beta API URL: $apiUrl');

    try {
      final response = await _client
          .get(Uri.parse(apiUrl), headers: _githubHeaders)
          .timeout(const Duration(seconds: 20));

      debugPrint('[Update] Beta API response status: ${response.statusCode}');

      if (response.statusCode != 200) {
        return UpdateFetchResult(
          statusCode: response.statusCode,
          apiUrl: apiUrl,
          error: UpdateFetchError.api,
          errorDetail: 'HTTP ${response.statusCode}',
        );
      }

      final releases = jsonDecode(response.body) as List<dynamic>;
      Map<String, dynamic>? betaRelease;

      for (final item in releases) {
        if (item is Map<String, dynamic> && item['prerelease'] == true) {
          betaRelease = item;
          break;
        }
      }

      betaRelease ??= releases.isNotEmpty && releases.first is Map<String, dynamic>
          ? releases.first as Map<String, dynamic>
          : null;

      if (betaRelease == null) {
        return UpdateFetchResult(
          statusCode: response.statusCode,
          apiUrl: apiUrl,
          error: UpdateFetchError.api,
          errorDetail: 'No beta releases found',
        );
      }

      return _parseGitHubResponse(
        apiUrl,
        response.statusCode,
        jsonEncode(betaRelease),
      );
    } on SocketException catch (e, st) {
      debugPrint('[Update] Beta network error: $e\n$st');
      return UpdateFetchResult(
        apiUrl: apiUrl,
        error: UpdateFetchError.network,
        errorDetail: e.message,
      );
    } on TimeoutException catch (e, st) {
      debugPrint('[Update] Beta timeout error: $e\n$st');
      return UpdateFetchResult(
        apiUrl: apiUrl,
        error: UpdateFetchError.network,
        errorDetail: 'Request timed out',
      );
    } on http.ClientException catch (e, st) {
      debugPrint('[Update] Beta client error: $e\n$st');
      return UpdateFetchResult(
        apiUrl: apiUrl,
        error: UpdateFetchError.network,
        errorDetail: e.message,
      );
    } catch (e, st) {
      debugPrint('[Update] Beta unexpected error: $e\n$st');
      return UpdateFetchResult(
        apiUrl: apiUrl,
        error: UpdateFetchError.api,
        errorDetail: e.toString(),
      );
    }
  }

  UpdateFetchResult _parseGitHubResponse(
    String apiUrl,
    int statusCode,
    String body,
  ) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      final assetCount = GitHubReleaseParser.countAssets(json);
      final latestVersion = GitHubReleaseParser.extractTagName(json);

      debugPrint('[Update] GitHub latest version: $latestVersion');
      debugPrint('[Update] Asset count: $assetCount');

      final updateInfo = GitHubReleaseParser.parseRelease(json);

      if (updateInfo == null) {
        final hasApk = (json['assets'] as List<dynamic>? ?? []).any(
          (a) =>
              a is Map<String, dynamic> &&
              a['name'] == GitHubReleaseParser.apkAssetName,
        );

        debugPrint(
          '[Update] Parse failed — app-release.apk found: $hasApk',
        );

        return UpdateFetchResult(
          statusCode: statusCode,
          apiUrl: apiUrl,
          latestVersion: latestVersion,
          assetCount: assetCount,
          error: hasApk ? UpdateFetchError.parse : UpdateFetchError.noApkAsset,
          errorDetail: hasApk
              ? 'Failed to parse release data'
              : '${GitHubReleaseParser.apkAssetName} not found in release assets',
        );
      }

      debugPrint('[Update] Download URL: ${updateInfo.apkUrl}');

      return UpdateFetchResult(
        updateInfo: updateInfo,
        statusCode: statusCode,
        apiUrl: apiUrl,
        latestVersion: latestVersion,
        downloadUrl: updateInfo.apkUrl,
        assetCount: assetCount,
      );
    } catch (e, st) {
      debugPrint('[Update] JSON parse error: $e');
      debugPrint('[Update] Stack: $st');
      return UpdateFetchResult(
        statusCode: statusCode,
        apiUrl: apiUrl,
        error: UpdateFetchError.parse,
        errorDetail: e.toString(),
      );
    }
  }

  @override
  Future<void> saveLastCheckTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastCheck, time.toIso8601String());
  }

  @override
  Future<DateTime?> getLastCheckTime() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_keyLastCheck);
    if (value == null) return null;
    return DateTime.tryParse(value);
  }

  @override
  Future<UpdateChannel> getUpdateChannel() async {
    final prefs = await SharedPreferences.getInstance();
    return UpdateChannel.fromString(prefs.getString(_keyChannel));
  }

  @override
  Future<void> setUpdateChannel(UpdateChannel channel) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyChannel, channel.value);
  }

  @override
  Future<List<UpdateHistoryEntry>> getUpdateHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyHistory);
    if (raw == null) return [];

    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => UpdateHistoryEntry.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.installedAt.compareTo(a.installedAt));
  }

  @override
  Future<void> addUpdateHistoryEntry(UpdateHistoryEntry entry) async {
    final history = await getUpdateHistory();
    history.removeWhere((e) => e.build == entry.build);
    history.insert(0, entry);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyHistory,
      jsonEncode(history.map((e) => e.toJson()).toList()),
    );
  }

  @override
  Future<int?> getRecordedBuild() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyRecordedBuild);
  }

  @override
  Future<void> setRecordedBuild(int build) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyRecordedBuild, build);
  }

  @override
  Future<void> savePendingReleaseNotes(List<String> notes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPendingNotes, jsonEncode(notes));
  }

  @override
  Future<List<String>> getPendingReleaseNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyPendingNotes);
    if (raw == null) return [];
    return (jsonDecode(raw) as List<dynamic>).map((e) => e.toString()).toList();
  }

  @override
  Future<void> clearPendingReleaseNotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPendingNotes);
  }
}
