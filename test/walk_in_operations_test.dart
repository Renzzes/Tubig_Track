import 'package:flutter_test/flutter_test.dart';
import 'package:tubig_track/features/walk_in_operations/domain/entities/walk_in_sale.dart';

void main() {
  group('WalkInType (v1.6.0)', () {
    test('storage round-trip', () {
      for (final type in WalkInType.values) {
        expect(
          WalkInTypeX.fromStorage(type.storageValue),
          type,
        );
      }
    });

    test('timeline labels are distinct', () {
      final labels =
          WalkInType.values.map((t) => t.timelineLabel).toSet();
      expect(labels.length, WalkInType.values.length);
    });
  });
}
