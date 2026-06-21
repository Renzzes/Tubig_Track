import 'package:flutter_test/flutter_test.dart';
import 'package:tubig_track/core/utils/supply_timeline_utils.dart';
import 'package:tubig_track/features/supply_purchases/domain/entities/supply_purchase.dart';

SupplyPurchase _purchase({String supplier = 'CEBU-HIQ', int quantity = 50}) {
  return SupplyPurchase(
    id: 'sp1',
    purchaseDate: DateTime(2026, 6, 1),
    supplierName: supplier,
    itemType: 'Gallons',
    quantity: quantity,
    unitCost: 35,
    totalCost: quantity * 35.0,
    expenseId: 'exp1',
  );
}

void main() {
  group('SupplyTimelineUtils (v1.6.2)', () {
    test('includes supplier name when present', () {
      expect(
        SupplyTimelineUtils.supplierDeliveryHeadline(_purchase()),
        'Supplier Delivered 50 Filled Bottles from CEBU-HIQ',
      );
    });

    test('omits supplier suffix when name blank', () {
      expect(
        SupplyTimelineUtils.supplierDeliveryHeadline(
          _purchase(supplier: '  '),
        ),
        'Supplier Delivered 50 Filled Bottles',
      );
    });
  });
}
