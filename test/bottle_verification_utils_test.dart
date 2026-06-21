import 'package:flutter_test/flutter_test.dart';
import 'package:tubig_track/core/utils/bottle_verification_utils.dart';
import 'package:tubig_track/features/customers/domain/entities/customer.dart';

Customer _customer({
  required String id,
  required String name,
  DateTime? lastPhysicalCountDate,
}) {
  return Customer(
    id: id,
    name: name,
    lastPhysicalCountDate: lastPhysicalCountDate,
    lastPhysicalCountVerified: lastPhysicalCountDate != null,
    createdAt: DateTime(2026, 1, 1),
  );
}

void main() {
  group('BottleVerificationUtils (v1.4.9)', () {
    final now = DateTime(2026, 6, 25);

    test('not verified when no physical count date', () {
      final customer = _customer(id: '1', name: 'Ana');
      expect(
        BottleVerificationUtils.statusFor(customer, now: now),
        PhysicalCountStatus.notVerified,
      );
      expect(
        BottleVerificationUtils.daysSinceLabel(customer, now: now),
        'Never Verified',
      );
    });

    test('verified within 30 days', () {
      final customer = _customer(
        id: '1',
        name: 'Ben',
        lastPhysicalCountDate: DateTime(2026, 6, 18),
      );
      expect(
        BottleVerificationUtils.statusFor(customer, now: now),
        PhysicalCountStatus.verified,
      );
      expect(BottleVerificationUtils.daysSinceLabel(customer, now: now), '7 Days');
    });

    test('needs reconciliation after 30 days', () {
      final customer = _customer(
        id: '1',
        name: 'Cara',
        lastPhysicalCountDate: DateTime(2026, 5, 1),
      );
      expect(
        BottleVerificationUtils.statusFor(customer, now: now),
        PhysicalCountStatus.needsReconciliation,
      );
    });

    test('summarize counts customers by status', () {
      final customers = [
        _customer(
          id: '1',
          name: 'A',
          lastPhysicalCountDate: DateTime(2026, 6, 20),
        ),
        _customer(
          id: '2',
          name: 'B',
          lastPhysicalCountDate: DateTime(2026, 1, 1),
        ),
        _customer(id: '3', name: 'C'),
      ];
      final summary = BottleVerificationUtils.summarize(customers, now: now);
      expect(summary.verified, 1);
      expect(summary.needsReconciliation, 1);
      expect(summary.notVerified, 1);
    });
  });
}
