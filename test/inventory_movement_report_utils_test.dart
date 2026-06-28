import 'package:flutter_test/flutter_test.dart';
import 'package:tubig_track/core/utils/inventory_movement_report_utils.dart';

void main() {
  group('Inventory movement report', () {
    test('builds filled bottles added by supplier and manual adjustment', () {
      final bySource = buildFilledBottlesAddedBySource(
        supplierDeliveriesQuantity: 120,
        manualAdjustmentQuantity: 8,
      );

      expect(bySource[supplierDeliveriesFilledLabel], 120);
      expect(bySource[manualAdjustmentFilledLabel], 8);
      expect(totalFilledBottlesAdded(bySource), 128);

      final ordered = orderedFilledBottlesAddedBreakdown(bySource);
      expect(ordered.map((e) => e.key).toList(), [
        supplierDeliveriesFilledLabel,
        manualAdjustmentFilledLabel,
      ]);
    });

    test('manual filled additions ignore negative adjustments', () {
      final manual = manualFilledBottlesAddedFromTransactions([
        (transactionType: 'added', quantity: 5),
        (transactionType: 'adjustment', quantity: 3),
        (transactionType: 'adjustment', quantity: -2),
        (transactionType: 'empty_adjustment', quantity: 10),
      ]);

      expect(manual, 8);
    });

    test('net filled bottles added subtracts empty received from filled added', () {
      expect(
        netFilledBottlesAdded(totalFilledAdded: 128, totalEmptyReceived: 39),
        89,
      );
      expect(formatNetFilledBottlesAdded(89), '+89 Bottles');
      expect(formatNetFilledBottlesAdded(-5), '-5 Bottles');
      expect(formatNetFilledBottlesAdded(0), '0 Bottles');
    });

    test('omits zero sources from filled breakdown', () {
      final bySource = buildFilledBottlesAddedBySource(
        supplierDeliveriesQuantity: 0,
        manualAdjustmentQuantity: 4,
      );

      expect(bySource.containsKey(supplierDeliveriesFilledLabel), isFalse);
      expect(bySource[manualAdjustmentFilledLabel], 4);
    });
  });
}
