import 'package:flutter_test/flutter_test.dart';
import 'package:tubig_track/core/utils/bottle_balance_utils.dart';
import 'package:tubig_track/core/utils/inventory_calculator.dart';
import 'package:tubig_track/features/inventory/domain/entities/bottle_transaction.dart';

void main() {
  group('InventoryCalculator', () {
    test('total owned = initial + purchased - damaged - missing - donated', () {
      const totals = InventoryTotals(
        initialInventory: 157,
        purchasedBottles: 10,
        donatedBottles: 5,
        borrowedBottles: 0,
        returnedBottles: 0,
        damagedBottles: 2,
        missingBottles: 3,
      );

      expect(InventoryCalculator.totalBottlesOwned(totals), 157);
    });

    test('bottles with customers includes manual adjustments', () {
      const totals = InventoryTotals(
        initialInventory: 100,
        purchasedBottles: 0,
        donatedBottles: 0,
        borrowedBottles: 50,
        returnedBottles: 20,
        damagedBottles: 0,
        missingBottles: 0,
        customerAdjustmentNet: 3,
      );

      expect(InventoryCalculator.bottlesWithCustomers(totals), 33);
    });

    test('empty bottles ready for refill = collected - refilled', () {
      const totals = InventoryTotals(
        initialInventory: 100,
        purchasedBottles: 0,
        donatedBottles: 0,
        borrowedBottles: 0,
        returnedBottles: 25,
        damagedBottles: 0,
        missingBottles: 0,
        refilledBottles: 0,
      );

      expect(InventoryCalculator.emptyBottlesReadyForRefill(totals), 25);
    });

    test('customer balance consistency check', () {
      expect(
        InventoryCalculator.customerBalancesMatchGlobal(
          globalWithCustomers: 27,
          sumCustomerHeld: 27,
        ),
        isTrue,
      );
      expect(
        InventoryCalculator.customerBalancesMatchGlobal(
          globalWithCustomers: 27,
          sumCustomerHeld: 25,
        ),
        isFalse,
      );
    });
  });

  group('Customer bottle ledger', () {
    test('computes running balance newest first with corrections', () {
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
          quantity: 3,
          date: DateTime(2024, 6, 7),
        ),
        BottleTransaction(
          id: '3',
          customerId: 'c1',
          transactionType: TransactionType.borrow,
          quantity: 5,
          date: DateTime(2024, 6, 15),
        ),
        BottleTransaction(
          id: '4',
          customerId: 'c1',
          transactionType: TransactionType.ret,
          quantity: 5,
          date: DateTime(2024, 6, 20),
        ),
      ];

      final ledger = buildCustomerBottleLedger(txs);
      expect(ledger.length, 4);
      expect(ledger.first.balanceAfter, 7);
      expect(ledgerHeadline(ledger.first), 'Collected 5 Bottles');
      expect(computeCustomerBottlesHeld(txs), 7);
    });
  });
}
