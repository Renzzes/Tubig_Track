import 'package:flutter_test/flutter_test.dart';
import 'package:tubig_track/core/utils/deposit_calculator.dart';
import 'package:tubig_track/core/utils/empty_bottle_source.dart';
import 'package:tubig_track/core/utils/inventory_activity_utils.dart';
import 'package:tubig_track/core/utils/inventory_timeline_utils.dart';
import 'package:tubig_track/features/inventory/domain/entities/bottle_transaction.dart';

void main() {
  group('Excess payment handling', () {
    test('return change keeps deposit at remaining after use only', () {
      const excess = 150.0;
      const remainingAfterUse = 0.0;
      const addToDeposit = 0.0;

      expect(
        DepositCalculator.newDepositBalance(
          remainingDepositAfterUse: remainingAfterUse,
          excessPayment: addToDeposit,
        ),
        0,
      );
      expect(excess - addToDeposit, 150);
    });

    test('add to deposit increases balance by excess', () {
      expect(
        DepositCalculator.newDepositBalance(
          remainingDepositAfterUse: 0,
          excessPayment: 150,
        ),
        150,
      );
    });
  });

  group('Empty bottle intake', () {
    test('recognizes legacy and new transaction type strings', () {
      expect(isEmptyBottleIntakeType('empty_added'), isTrue);
      expect(isEmptyBottleIntakeType('empty_bottle_intake'), isTrue);
      expect(isEmptyBottleIntakeType('return'), isFalse);
    });

    test('stores walk-in customer as source label', () {
      expect(EmptyBottleSource.walkInCustomer.label, 'Walk-in Customer');
    });

    test('timeline includes source and notes', () {
      final label = BottleTransaction.timelineLabel(
        TransactionType.emptyAdded,
        5,
        reason: EmptyBottleSource.walkInCustomer.label,
        notes: 'Returned after purchase',
      );
      expect(label, contains('Empty Bottle Intake'));
      expect(label, contains('Walk-in Customer'));
      expect(label, contains('Returned after purchase'));
    });

    test('activity history categorizes empty intake', () {
      expect(
        categoryForTransaction(TransactionType.emptyAdded),
        InventoryActivityCategory.emptyBottleIntake,
      );
    });

    test('reports sum empty bottle intake from legacy and new types', () {
      final breakdown = <String, int>{};
      addEmptyBottleIntakeToBreakdown(breakdown, 'Walk-in Customer', 3);
      addEmptyBottleIntakeToBreakdown(breakdown, 'empty_bottle_intake', 5);
      addEmptyBottleIntakeToBreakdown(breakdown, null, 2);
      addEmptyBottleIntakeToBreakdown(breakdown, 'Customer Collection', 8);

      expect(breakdown['Walk-in Customer'], 3);
      expect(breakdown['Other'], 5);
      expect(breakdown[unspecifiedEmptyBottleSourceLabel], 2);
      expect(breakdown['Customer Collection'], 8);

      final ordered = orderedEmptyBottleIntakeBreakdown(breakdown);
      expect(ordered.map((e) => e.key).toList(), [
        'Walk-in Customer',
        'Customer Collection',
        'Other',
        unspecifiedEmptyBottleSourceLabel,
      ]);
      expect(ordered.fold<int>(0, (sum, e) => sum + e.value), 18);
    });

    test('inventory timeline shows empty bottle intake with source', () {
      final tx = BottleTransaction(
        id: 'tx1',
        transactionType: TransactionType.emptyAdded,
        quantity: 2,
        date: DateTime(2026, 6, 30, 14, 15),
        reason: EmptyBottleSource.walkInCustomer.label,
        notes: 'Returned after purchase',
      );
      final entries = buildInventoryTimeline(
        transactions: [tx],
        supplyPurchases: const [],
        supplyLinkedTxIds: const {},
        customerNames: const {},
      );
      expect(entries, hasLength(1));
      expect(entries.first.headline, contains('Empty Bottle Intake'));
      expect(entries.first.subtitle, 'Walk-in Customer');
    });
  });
}
