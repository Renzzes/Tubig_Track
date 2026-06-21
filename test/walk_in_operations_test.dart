import 'package:flutter_test/flutter_test.dart';
import 'package:tubig_track/features/walk_in_operations/domain/entities/walk_in_sale.dart';

final _date = DateTime(2026, 6, 1);

void main() {
  group('WalkInType (v1.6.0+)', () {
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

    test('simplified user-facing labels', () {
      expect(WalkInType.businessBottles.label, 'Borrow Bottle');
      expect(WalkInType.customerRefill.label, 'Refill Own Bottle');
    });

    test('bottlesSold counts primary quantity per type', () {
      final borrow = WalkInSale(
        id: '1',
        walkInType: WalkInType.businessBottles,
        businessOwnedQuantity: 4,
        pricePerBottle: 30,
        totalAmount: 120,
        date: _date,
        createdAt: _date,
        updatedAt: _date,
      );
      final refill = WalkInSale(
        id: '2',
        walkInType: WalkInType.customerRefill,
        customerOwnedQuantity: 3,
        pricePerBottle: 30,
        totalAmount: 90,
        date: _date,
        createdAt: _date,
        updatedAt: _date,
      );
      expect(borrow.bottlesSold, 4);
      expect(refill.bottlesSold, 3);
    });
  });
}
