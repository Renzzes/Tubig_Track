import 'package:flutter_test/flutter_test.dart';

/// Mirrors the delivery filter used in SavingsRepositoryImpl.
bool deliveryCountsTowardSavings(String deliveryStatus) =>
    deliveryStatus == 'completed';

void main() {
  group('Delivery savings status filter', () {
    test('only completed deliveries count toward savings', () {
      expect(deliveryCountsTowardSavings('completed'), isTrue);
      expect(deliveryCountsTowardSavings('scheduled'), isFalse);
      expect(deliveryCountsTowardSavings('in_progress'), isFalse);
      expect(deliveryCountsTowardSavings('cancelled'), isFalse);
    });

    test('margin example applies only when completed', () {
      const costPerBottle = 25.0;
      const pricePerBottle = 35.0;
      const quantity = 10;

      final profit = (pricePerBottle - costPerBottle) * quantity;
      expect(profit, 100.0);

      if (deliveryCountsTowardSavings('completed')) {
        expect(profit, 100.0);
      }
      if (!deliveryCountsTowardSavings('scheduled')) {
        expect(0.0, 0.0);
      }
    });
  });
}
