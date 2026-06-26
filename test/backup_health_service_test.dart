import 'package:flutter_test/flutter_test.dart';
import 'package:tubig_track/core/services/backup_health_service.dart';

void main() {
  group('BackupHealthTier', () {
    test('stars map to five levels', () {
      expect(BackupHealthTier.excellent, isNot(BackupHealthTier.damaged));
      const info = BackupHealthInfo(
        tier: BackupHealthTier.excellent,
        stars: 5,
        label: 'Excellent',
        subtitle: 'Verified',
        verificationPassed: true,
      );
      expect(info.stars, 5);
    });
  });
}
