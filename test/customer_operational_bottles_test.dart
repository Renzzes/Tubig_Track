import 'package:flutter_test/flutter_test.dart';
import 'package:tubig_track/core/utils/customer_operational_bottles_utils.dart';
import 'package:tubig_track/features/deliveries/domain/entities/delivery.dart';

Delivery _delivery({
  required String id,
  required DeliveryStatus status,
  required DateTime date,
  int quantity = 5,
}) {
  return Delivery(
    id: id,
    customerId: 'c1',
    quantity: quantity,
    pricePerBottle: 30,
    totalAmount: quantity * 30.0,
    paymentStatus: PaymentStatus.paid,
    amountPaid: quantity * 30.0,
    remainingBalance: 0,
    deliveryDate: date,
    deliveryStatus: status,
  );
}

void main() {
  group('CustomerOperationalBottlesUtils (v1.6.1)', () {
    test('pending delivery sums scheduled and in-progress only', () {
      final deliveries = [
        _delivery(
          id: '1',
          status: DeliveryStatus.scheduled,
          date: DateTime(2026, 6, 1),
          quantity: 3,
        ),
        _delivery(
          id: '2',
          status: DeliveryStatus.inProgress,
          date: DateTime(2026, 6, 2),
          quantity: 4,
        ),
        _delivery(
          id: '3',
          status: DeliveryStatus.completed,
          date: DateTime(2026, 6, 3),
          quantity: 10,
        ),
        _delivery(
          id: '4',
          status: DeliveryStatus.cancelled,
          date: DateTime(2026, 6, 4),
          quantity: 2,
        ),
      ];

      expect(
        CustomerOperationalBottlesUtils.pendingDeliveryQty(deliveries),
        7,
      );
    });

    test('operational collected resets after completed delivery', () {
      final completedDate = DateTime(2026, 6, 10);
      final deliveries = [
        _delivery(
          id: 'done',
          status: DeliveryStatus.completed,
          date: completedDate,
        ),
      ];
      final returns = [
        (
          date: DateTime(2026, 6, 9),
          quantity: 5,
          id: 'old-return',
        ),
        (
          date: DateTime(2026, 6, 11),
          quantity: 2,
          id: 'new-return',
        ),
      ];

      expect(
        CustomerOperationalBottlesUtils.operationalCollected(
          deliveries: deliveries,
          returnEntries: returns,
        ),
        2,
      );
    });

    test('operational collected is zero when cycle completed and no new returns',
        () {
      final deliveries = [
        _delivery(
          id: 'done',
          status: DeliveryStatus.completed,
          date: DateTime(2026, 6, 10),
        ),
      ];
      final returns = [
        (
          date: DateTime(2026, 6, 9),
          quantity: 5,
          id: 'return-before-complete',
        ),
      ];

      expect(
        CustomerOperationalBottlesUtils.operationalCollected(
          deliveries: deliveries,
          returnEntries: returns,
        ),
        0,
      );
    });
  });
}
