import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

enum BackupNotificationKind {
  automaticBackupSuccess,
  manualBackupSuccess,
  verificationFailed,
  automaticBackupFailed,
  storageChanged,
}

class BackupNotificationPayload {
  final BackupNotificationKind kind;
  final String title;
  final String body;
  final String? backupPath;
  final String? storageLocation;
  final DateTime createdAt;

  const BackupNotificationPayload({
    required this.kind,
    required this.title,
    required this.body,
    this.backupPath,
    this.storageLocation,
    required this.createdAt,
  });

  factory BackupNotificationPayload.fromJson(Map<String, dynamic> json) {
    return BackupNotificationPayload(
      kind: BackupNotificationKind.values.firstWhere(
        (value) => value.name == json['kind'],
        orElse: () => BackupNotificationKind.manualBackupSuccess,
      ),
      title: json['title'] as String,
      body: json['body'] as String,
      backupPath: json['backupPath'] as String?,
      storageLocation: json['storageLocation'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'kind': kind.name,
        'title': title,
        'body': body,
        if (backupPath != null) 'backupPath': backupPath,
        if (storageLocation != null) 'storageLocation': storageLocation,
        'createdAt': createdAt.toIso8601String(),
      };
}

/// Queues backup notifications to show after real events (not on app launch).
class BackupNotificationQueue {
  BackupNotificationQueue._();

  static final BackupNotificationQueue instance = BackupNotificationQueue._();

  static const _prefKey = 'tubigtrack_pending_backup_notification';

  Future<void> enqueue(BackupNotificationPayload payload) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, jsonEncode(payload.toJson()));
  }

  Future<BackupNotificationPayload?> peek() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefKey);
    if (raw == null) return null;
    try {
      return BackupNotificationPayload.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
  }
}
