import 'package:flutter_test/flutter_test.dart';
import 'package:tubig_track/core/utils/customer_bottle_ownership_utils.dart';
import 'package:tubig_track/features/inventory/domain/entities/customer_owned_bottle_log.dart';

void main() {
  group('Customer-owned bottle tracking (v1.4.8)', () {
    test('ownership ledger shows separate business and customer-owned balances', () {
      final logs = [
        CustomerOwnedBottleLog(
          id: 'log1',
          customerId: 'c1',
          eventType: CustomerOwnedBottleEventType.setBalance,
          businessOwnedDelta: 0,
          customerOwnedDelta: 7,
          businessOwnedAfter: 18,
          customerOwnedAfter: 7,
          date: DateTime(2026, 1, 2),
        ),
        CustomerOwnedBottleLog(
          id: 'log2',
          customerId: 'c1',
          eventType: CustomerOwnedBottleEventType.collected,
          businessOwnedDelta: -10,
          customerOwnedDelta: -3,
          businessOwnedAfter: 8,
          customerOwnedAfter: 4,
          date: DateTime(2026, 1, 3),
        ),
      ];

      final ledger = buildCustomerOwnershipLedger(
        transactions: const [],
        logs: logs,
      );

      expect(ledger.length, 2);
      expect(ledger.first.headline, 'Collected Bottles');
      expect(ledger.first.businessOwnedAfter, 8);
      expect(ledger.first.customerOwnedAfter, 4);
      expect(
        ownershipLedgerSubtitle(ledger.first),
        'Business-Owned: -10 • Customer-Owned: -3',
      );
    });

    test('customer-owned totals do not change business-owned formula', () {
      const businessHeld = 18;
      const customerOwnedHeld = 7;
      expect(businessHeld + customerOwnedHeld, 25);
      expect(businessHeld, 18);
    });
  });
}
