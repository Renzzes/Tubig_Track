import 'package:flutter_test/flutter_test.dart';
import 'package:tubig_track/core/services/app_startup_service.dart';

void main() {
  group('AppStartupService', () {
    test('safe mode flag defaults to false', () {
      expect(AppStartupService.instance.safeMode, isFalse);
    });

    test('essential complete is false before startup runs', () {
      expect(AppStartupService.instance.essentialComplete, isFalse);
    });

    test('startup timeout is 10 seconds', () {
      expect(AppStartupService.startupTimeout.inSeconds, 10);
    });
  });
}
