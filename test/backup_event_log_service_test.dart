import 'package:flutter_test/flutter_test.dart';
import 'package:tubig_track/core/services/backup_event_log_service.dart';

void main() {
  test('BackupEvent serializes round trip', () {
    final event = BackupEvent(
      id: '1_manualBackup',
      type: BackupEventType.manualBackup,
      occurredAt: DateTime(2026, 6, 25, 22, 42),
      success: true,
      title: 'Manual Backup',
      detail: 'test.db',
    );

    final restored = BackupEvent.fromJson(event.toJson());
    expect(restored.type, BackupEventType.manualBackup);
    expect(restored.title, 'Manual Backup');
    expect(restored.success, isTrue);
  });
}
