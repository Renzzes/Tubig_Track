import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/update_channel.dart';
import '../../domain/entities/update_history_entry.dart';
import '../../domain/entities/update_info.dart';
import '../../domain/repositories/update_repository.dart';

class UpdateRepositoryImpl implements UpdateRepository {
  static const _keyLastCheck = 'update_last_check';
  static const _keyChannel = 'update_channel';
  static const _keyHistory = 'update_history';
  static const _keyRecordedBuild = 'update_recorded_build';
  static const _keyPendingNotes = 'update_pending_notes';

  final http.Client _client;

  UpdateRepositoryImpl({http.Client? client}) : _client = client ?? http.Client();

  @override
  Future<UpdateInfo?> fetchLatestUpdate(UpdateChannel channel) async {
    final url = channel == UpdateChannel.beta
        ? AppConstants.updateManifestUrlBeta
        : AppConstants.updateManifestUrlStable;

    final response = await _client
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) return null;

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return UpdateInfo.fromJson(json);
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
