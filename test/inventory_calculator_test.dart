import 'package:flutter_test/flutter_test.dart';
import 'package:tubig_track/core/utils/bottle_balance_utils.dart';
import 'package:tubig_track/core/utils/inventory_calculator.dart';
import 'package:tubig_track/features/inventory/domain/entities/bottle_transaction.dart';

void main() {
  group('InventoryCalculator', () {
    test('spec scenario: owned stays 157 through deliver/collect cycles', () {
      const owned = 157;

      // Week 1: deliver 10
      var totals = const InventoryTotals(
        initialInventory: owned,
        purchasedBottles: 0,
        donatedBottles: 0,
        borrowedBottles: 10,
        returnedBottles: 0,
        damagedBottles: 0,
        missingBottles: 0,
      );
      expect(InventoryCalculator.totalBottlesOwned(totals), 157);
      expect(InventoryCalculator.bottlesWithCustomers(totals), 10);
      expect(InventoryCalculator.availableStock(totals), 147);

      // Week 2: collect 5
      totals = InventoryTotals(
        initialInventory: owned,
        purchasedBottles: 0,
        donatedBottles: 0,
        borrowedBottles: 10,
        returnedBottles: 5,
        damagedBottles: 0,
        missingBottles: 0,
      );
      expect(InventoryCalculator.totalBottlesOwned(totals), 157);
      expect(InventoryCalculator.bottlesWithCustomers(totals), 5);
      expect(InventoryCalculator.availableStock(totals), 152);

      // Week 3: deliver 7 more (17 delivered, 5 collected)
      totals = InventoryTotals(
        initialInventory: owned,
        purchasedBottles: 0,
        donatedBottles: 0,
        borrowedBottles: 17,
        returnedBottles: 5,
        damagedBottles: 0,
        missingBottles: 0,
      );
      expect(InventoryCalculator.totalBottlesOwned(totals), 157);
      expect(InventoryCalculator.bottlesWithCustomers(totals), 12);
      expect(InventoryCalculator.availableStock(totals), 145);
    });

    test('donated bottles do not reduce total owned', () {
      const totals = InventoryTotals(
        initialInventory: 157,
        purchasedBottles: 0,
        donatedBottles: 10,
        borrowedBottles: 0,
        returnedBottles: 0,
        damagedBottles: 0,
        missingBottles: 0,
      );

      expect(InventoryCalculator.totalBottlesOwned(totals), 157);
      expect(InventoryCalculator.availableStock(totals), 147);
      expect(InventoryCalculator.isBalanced(totals), isTrue);
    });

    test('owned includes purchased and added bottles', () {
      const totals = InventoryTotals(
        initialInventory: 100,
        purchasedBottles: 30,
        addedBottles: 5,
        donatedBottles: 0,
        borrowedBottles: 0,
        returnedBottles: 0,
        damagedBottles: 0,
        missingBottles: 0,
      );

      expect(InventoryCalculator.totalBottlesOwned(totals), 135);
    });

    test('missing and damaged reduce available but not owned', () {
      const totals = InventoryTotals(
        initialInventory: 100,
        purchasedBottles: 0,
        donatedBottles: 0,
        borrowedBottles: 10,
        returnedBottles: 0,
        damagedBottles: 2,
        missingBottles: 1,
      );

      expect(InventoryCalculator.totalBottlesOwned(totals), 100);
      expect(InventoryCalculator.bottlesWithCustomers(totals), 10);
      expect(InventoryCalculator.availableStock(totals), 87);
    });

    test('adjustment reconciles physical count without changing owned', () {
      const totals = InventoryTotals(
        initialInventory: 157,
        purchasedBottles: 0,
        donatedBottles: 0,
        borrowedBottles: 0,
        returnedBottles: 0,
        damagedBottles: 0,
        missingBottles: 0,
        adjustmentNet: 10,
      );

      expect(InventoryCalculator.totalBottlesOwned(totals), 157);
      expect(InventoryCalculator.availableStock(totals), 167);
      expect(InventoryCalculator.isBalanced(totals), isTrue);
    });
  });

  group('Customer bottle ledger', () {
    test('computes running balance newest first', () {
      final txs = [
        BottleTransaction(
          id: '1',
          customerId: 'c1',
          transactionType: TransactionType.borrow,
          quantity: 10,
          date: DateTime(2024, 6, 1),
        ),
        BottleTransaction(
          id: '2',
          customerId: 'c1',
          transactionType: TransactionType.ret,
          quantity: 5,
          date: DateTime(2024, 6, 8),
        ),
        BottleTransaction(
          id: '3',
          customerId: 'c1',
          transactionType: TransactionType.borrow,
          quantity: 7,
          date: DateTime(2024, 6, 15),
        ),
        BottleTransaction(
          id: '4',
          customerId: 'c1',
          transactionType: TransactionType.ret,
          quantity: 4,
          date: DateTime(2024, 6, 20),
        ),
      ];

      final ledger = buildCustomerBottleLedger(txs);
      expect(ledger.length, 4);
      expect(ledger.first.balanceAfter, 8);
      expect(ledger.first.actionLabel, 'Collected');
      expect(computeCustomerBottlesHeld(txs), 8);
    });

    test('never allows negative customer balance', () {
      final txs = [
        BottleTransaction(
          id: '1',
          customerId: 'c1',
          transactionType: TransactionType.ret,
          quantity: 5,
          date: DateTime(2024, 6, 1),
        ),
      ];

      expect(computeCustomerBottlesHeld(txs), 0);
      expect(buildCustomerBottleLedger(txs).first.balanceAfter, 0);
    });
  });
}
