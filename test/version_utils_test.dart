import 'package:flutter_test/flutter_test.dart';
import 'package:tubig_track/core/utils/version_utils.dart';
import 'package:tubig_track/features/update/domain/entities/update_info.dart';

void main() {
  group('VersionUtils', () {
    test('equal versions are not newer', () {
      expect(VersionUtils.isNewer('1.6.3', '1.6.3'), isFalse);
      expect(VersionUtils.compare('1.6.3', '1.6.3'), 0);
    });

    test('latest greater than current', () {
      expect(VersionUtils.isNewer('1.6.4', '1.6.3'), isTrue);
      expect(VersionUtils.isNewer('1.6.3', '1.6.4'), isFalse);
    });

    test('normalizes leading v prefix', () {
      expect(VersionUtils.normalize('v1.6.4'), '1.6.4');
      expect(VersionUtils.isNewer('v1.6.4', '1.6.3'), isTrue);
    });
  });

  group('UpdateInfo.isNewerThan', () {
    const updateInfo = UpdateInfo(
      version: '1.6.4',
      build: 99,
      apkUrl: 'https://example.com/app.apk',
      releaseNotes: [],
    );

    test('shows update only when latest semver is greater', () {
      expect(
        updateInfo.isNewerThan(currentVersion: '1.6.3', currentBuild: 23),
        isTrue,
      );
      expect(
        updateInfo.isNewerThan(currentVersion: '1.6.4', currentBuild: 23),
        isFalse,
      );
      expect(
        updateInfo.isNewerThan(currentVersion: '1.6.4', currentBuild: 99),
        isFalse,
      );
    });
  });
}
