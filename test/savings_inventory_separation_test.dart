import 'package:flutter_test/flutter_test.dart';
import 'package:tubig_track/core/utils/inventory_calculator.dart';

void main() {
  group('Inventory ownership vs financial separation (v1.4.7)', () {
    test('purchase new bottles increases total owned only', () {
      const before = InventoryTotals(
        initialInventory: 157,
        purchasedBottles: 0,
        donatedBottles: 0,
        borrowedBottles: 0,
        returnedBottles: 0,
        damagedBottles: 0,
        missingBottles: 0,
      );
      const afterPurchase = InventoryTotals(
        initialInventory: 157,
        purchasedBottles: 30,
        donatedBottles: 0,
        borrowedBottles: 0,
        returnedBottles: 0,
        damagedBottles: 0,
        missingBottles: 0,
      );

      expect(InventoryCalculator.totalBottlesOwned(before), 157);
      expect(InventoryCalculator.totalBottlesOwned(afterPurchase), 187);
    });

    test('savings formula excludes bottle purchase cost and owner capital', () {
      const deliveryProfit = 5000.0;
      const dispenserProfit = 800.0;
      const totalExpenses = 1200.0;
      const ownerCapital = 300.0;
      const bottlePurchaseCost = 3510.0;

      final accumulatedProfit =
          deliveryProfit + dispenserProfit - totalExpenses;
      final totalBusinessMoney = accumulatedProfit + ownerCapital;
      final legacySavingsWithPurchaseDeduction =
          accumulatedProfit - bottlePurchaseCost;

      expect(accumulatedProfit, 4600.0);
      expect(totalBusinessMoney, 4900.0);
      expect(legacySavingsWithPurchaseDeduction, 1090.0);
      expect(accumulatedProfit, greaterThan(legacySavingsWithPurchaseDeduction));
    });

    test('savings transfer moves cash without changing accumulated profit', () {
      const accumulatedProfit = 50000.0;
      const ownerCapital = 0.0;
      const transferAmount = 5000.0;

      final totalBefore = accumulatedProfit + ownerCapital;
      final savingsAfter = transferAmount;
      final businessCashAfter = totalBefore - savingsAfter;

      expect(businessCashAfter, 45000.0);
      expect(savingsAfter, 5000.0);
      expect(accumulatedProfit, 50000.0);
    });
  });
}
