import 'package:flutter_test/flutter_test.dart';
import 'package:tubig_track/core/utils/customer_duplicate_utils.dart';
import 'package:tubig_track/features/customers/domain/entities/customer.dart';

Customer _customer({
  required String id,
  required String name,
  String? phone,
}) {
  return Customer(
    id: id,
    name: name,
    phone: phone,
    createdAt: DateTime(2026, 1, 1),
  );
}

void main() {
  group('CustomerDuplicateUtils', () {
    test('normalizeName trims and collapses spaces', () {
      expect(
        CustomerDuplicateUtils.normalizeName('  Aljun   Cruz  '),
        'Aljun Cruz',
      );
    });

    test('findDuplicateByName is case-insensitive', () {
      final customers = [
        _customer(id: '1', name: 'Aljun'),
        _customer(id: '2', name: 'Maria'),
      ];
      final duplicate = CustomerDuplicateUtils.findDuplicateByName(
        customers,
        '  aljun  ',
      );
      expect(duplicate?.id, '1');
    });

    test('findDuplicateByName excludes current customer when editing', () {
      final customers = [
        _customer(id: '1', name: 'Aljun'),
      ];
      expect(
        CustomerDuplicateUtils.findDuplicateByName(
          customers,
          'Aljun',
          excludeCustomerId: '1',
        ),
        isNull,
      );
    });

    test('findDuplicateByPhone matches trimmed case-insensitive phone', () {
      final customers = [
        _customer(id: '1', name: 'Aljun', phone: '09171234567'),
      ];
      final duplicate = CustomerDuplicateUtils.findDuplicateByPhone(
        customers,
        ' 09171234567 ',
        excludeCustomerId: '2',
      );
      expect(duplicate?.id, '1');
    });

    test('findDuplicateByPhone ignores empty phone input', () {
      final customers = [
        _customer(id: '1', name: 'Aljun', phone: '09171234567'),
      ];
      expect(
        CustomerDuplicateUtils.findDuplicateByPhone(customers, '   '),
        isNull,
      );
    });
  });
}
