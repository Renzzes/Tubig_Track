import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../constants/app_constants.dart';
import 'data_storage_service.dart';

enum BackupEventType {
  manualBackup,
  automaticBackup,
  restore,
  archive,
  reset,
  verification,
  migration,
  rollback,
  storageTest,
  storageLocationChanged,
  backupCleanup,
}

class BackupEvent {
  final String id;
  final BackupEventType type;
  final DateTime occurredAt;
  final bool success;
  final String title;
  final String? detail;
  final String? relatedPath;

  const BackupEvent({
    required this.id,
    required this.type,
    required this.occurredAt,
    required this.success,
    required this.title,
    this.detail,
    this.relatedPath,
  });

  factory BackupEvent.fromJson(Map<String, dynamic> json) {
    return BackupEvent(
      id: json['id'] as String,
      type: BackupEventType.values.firstWhere(
        (value) => value.name == json['type'],
        orElse: () => BackupEventType.manualBackup,
      ),
      occurredAt: DateTime.parse(json['occurredAt'] as String),
      success: json['success'] as bool? ?? true,
      title: json['title'] as String,
      detail: json['detail'] as String?,
      relatedPath: json['relatedPath'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'occurredAt': occurredAt.toIso8601String(),
        'success': success,
        'title': title,
        if (detail != null) 'detail': detail,
        if (relatedPath != null) 'relatedPath': relatedPath,
      };
}

class BackupEventLogService {
  BackupEventLogService._({DataStorageService? storage})
      : _storage = storage ?? DataStorageService.instance;

  static final BackupEventLogService instance = BackupEventLogService._();

  final DataStorageService _storage;

  Future<Directory> eventsDirectory() async {
    await _storage.ensureFolderStructure();
    final recovery = await _storage.recoveryDirectory();
    final dir = Directory(
      p.join(recovery.path, AppConstants.backupEventsSubfolder),
    );
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<BackupEvent> record({
    required BackupEventType type,
    required String title,
    bool success = true,
    String? detail,
    String? relatedPath,
    DateTime? occurredAt,
  }) async {
    final when = occurredAt ?? DateTime.now();
    final event = BackupEvent(
      id: '${when.millisecondsSinceEpoch}_${type.name}',
      type: type,
      occurredAt: when,
      success: success,
      title: title,
      detail: detail,
      relatedPath: relatedPath,
    );

    final dir = await eventsDirectory();
    final file = File(p.join(dir.path, '${event.id}.json'));
    await file.writeAsString(JsonEncoder.withIndent('  ').convert(event.toJson()));
    return event;
  }

  Future<List<BackupEvent>> listEvents({int limit = 300}) async {
    final dir = await eventsDirectory();
    if (!await dir.exists()) return [];

    final events = <BackupEvent>[];
    for (final entity in dir.listSync(followLinks: false)) {
      if (entity is! File || !entity.path.endsWith('.json')) continue;
      try {
        final json =
            jsonDecode(await entity.readAsString()) as Map<String, dynamic>;
        events.add(BackupEvent.fromJson(json));
      } catch (_) {
        continue;
      }
    }

    events.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    if (events.length > limit) {
      return events.sublist(0, limit);
    }
    return events;
  }

  Future<BackupEvent?> latestEvent({
    BackupEventType? type,
    bool? success,
  }) async {
    final events = await listEvents();
    for (final event in events) {
      if (type != null && event.type != type) continue;
      if (success != null && event.success != success) continue;
      return event;
    }
    return null;
  }

  Future<BackupEvent?> latestBackupEvent() async {
    final events = await listEvents();
    for (final event in events) {
      if (event.type == BackupEventType.manualBackup ||
          event.type == BackupEventType.automaticBackup) {
        return event;
      }
    }
    return null;
  }
}
