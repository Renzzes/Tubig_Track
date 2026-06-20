import 'package:flutter_test/flutter_test.dart';
import 'package:tubig_track/core/utils/inventory_calculator.dart';

void main() {
  group('InventoryCalculator', () {
    test('verification scenario balances correctly', () {
      const totals = InventoryTotals(
        initialInventory: 157,
        purchasedBottles: 30,
        donatedBottles: 10,
        borrowedBottles: 20,
        returnedBottles: 5,
        damagedBottles: 2,
        missingBottles: 1,
      );

      expect(InventoryCalculator.totalBottlesOwned(totals), 177);
      expect(InventoryCalculator.bottlesWithCustomers(totals), 15);
      expect(InventoryCalculator.availableBottles(totals), 159);
      expect(InventoryCalculator.isBalanced(totals), isTrue);
      expect(
        InventoryCalculator.availableBottles(totals) +
            InventoryCalculator.bottlesWithCustomers(totals) +
            totals.damagedBottles +
            totals.missingBottles,
        177,
      );
    });

    test('donated bottles reduce total owned', () {
      const totals = InventoryTotals(
        initialInventory: 100,
        purchasedBottles: 50,
        donatedBottles: 20,
        borrowedBottles: 0,
        returnedBottles: 0,
        damagedBottles: 5,
        missingBottles: 0,
      );

      expect(InventoryCalculator.totalBottlesOwned(totals), 130);
      expect(InventoryCalculator.availableBottles(totals), 125);
    });

    test('missing reduces available but not total owned', () {
      const totals = InventoryTotals(
        initialInventory: 100,
        purchasedBottles: 0,
        donatedBottles: 0,
        borrowedBottles: 10,
        returnedBottles: 0,
        damagedBottles: 0,
        missingBottles: 3,
      );

      expect(InventoryCalculator.totalBottlesOwned(totals), 100);
      expect(InventoryCalculator.bottlesWithCustomers(totals), 10);
      expect(InventoryCalculator.availableBottles(totals), 87);
    });

    test('adjustment only affects available inventory', () {
      const totals = InventoryTotals(
        initialInventory: 177,
        purchasedBottles: 0,
        donatedBottles: 0,
        borrowedBottles: 0,
        returnedBottles: 0,
        damagedBottles: 0,
        missingBottles: 0,
        adjustmentNet: 10,
      );

      expect(InventoryCalculator.totalBottlesOwned(totals), 177);
      expect(InventoryCalculator.availableBottles(totals), 187);
      expect(InventoryCalculator.isBalanced(totals), isTrue);
    });
  });
}
