import 'package:flutter_test/flutter_test.dart';
import 'package:tubig_track/core/utils/inventory_validation.dart';
import 'package:tubig_track/features/inventory/domain/entities/bottle_transaction.dart';
import 'package:tubig_track/features/inventory/domain/entities/inventory_summary.dart';

InventorySummary _summary({
  int total = 177,
  int filled = 40,
  int empty = 15,
  int customer = 90,
  int damaged = 2,
  int missing = 30,
}) {
  return InventorySummary(
    initialInventory: total,
    totalBottlesOwned: total,
    bottlesWithCustomers: customer,
    filledBottlesAvailable: filled,
    emptyBottlesReadyForRefill: empty,
    borrowedBottles: 0,
    returnedBottles: 0,
    damagedBottles: damaged,
    missingBottles: missing,
    purchasedBottles: 0,
    donatedBottles: 0,
  );
}

void main() {
  group('InventoryValidation', () {
    test('allows add filled when unallocated bottles remain', () {
      final summary = _summary(
        total: 177,
        filled: 17,
        empty: 28,
        customer: 60,
        damaged: 5,
        missing: 33,
      );

      expect(
        () => InventoryValidation.validateTransaction(
          summary: summary,
          type: TransactionType.added,
          quantity: 34,
        ),
        returnsNormally,
      );
    });

    test('blocks add filled when inventory exceeds owned', () {
      final summary = _summary();

      expect(
        () => InventoryValidation.validateTransaction(
          summary: summary,
          type: TransactionType.added,
          quantity: 5,
        ),
        throwsA(isA<InventoryValidationException>()),
      );
    });

    test('allows adjust filled when reducing count', () {
      final summary = _summary(
        total: 177,
        filled: 61,
        empty: 15,
        customer: 90,
        damaged: 2,
        missing: 9,
      );

      expect(
        () => InventoryValidation.validateTransaction(
          summary: summary,
          type: TransactionType.adjustment,
          quantity: -3,
        ),
        returnsNormally,
      );
    });

    test('allows add empty when unallocated bottles remain', () {
      final summary = _summary(
        total: 177,
        filled: 20,
        empty: 8,
        customer: 90,
        damaged: 2,
        missing: 37,
      );

      expect(
        () => InventoryValidation.validateTransaction(
          summary: summary,
          type: TransactionType.emptyAdded,
          quantity: 20,
        ),
        returnsNormally,
      );
    });

    test('allows collection because customer count decreases', () {
      final summary = _summary();

      expect(
        () => InventoryValidation.validateTransaction(
          summary: summary,
          type: TransactionType.ret,
          quantity: 5,
        ),
        returnsNormally,
      );
    });

    test('skips validation for purchase transactions', () {
      final summary = _summary();

      expect(
        () => InventoryValidation.validateTransaction(
          summary: summary,
          type: TransactionType.purchase,
          quantity: 10,
        ),
        returnsNormally,
      );
    });

    test('validation exception message distinguishes overflow', () {
      const error = InventoryValidationException(
        totalBottlesOwned: 177,
        calculatedInventory: 181,
      );
      expect(error.exceedsOwned, isTrue);
      expect(error.message, contains('exceeds'));
    });
  });
}
