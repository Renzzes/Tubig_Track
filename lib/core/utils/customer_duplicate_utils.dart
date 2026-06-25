import '../../features/customers/domain/entities/customer.dart';

/// Name and phone duplicate checks for customer create/edit forms.
class CustomerDuplicateUtils {
  CustomerDuplicateUtils._();

  /// Trims whitespace and collapses internal runs of spaces.
  static String normalizeName(String name) {
    return name.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  static String normalizeNameForComparison(String name) {
    return normalizeName(name).toLowerCase();
  }

  static String? normalizePhoneForComparison(String? phone) {
    if (phone == null || phone.trim().isEmpty) return null;
    return phone.trim().toLowerCase();
  }

  static Customer? findDuplicateByName(
    List<Customer> customers,
    String name, {
    String? excludeCustomerId,
  }) {
    final target = normalizeNameForComparison(name);
    if (target.isEmpty) return null;

    for (final customer in customers) {
      if (excludeCustomerId != null && customer.id == excludeCustomerId) {
        continue;
      }
      if (normalizeNameForComparison(customer.name) == target) {
        return customer;
      }
    }
    return null;
  }

  static Customer? findDuplicateByPhone(
    List<Customer> customers,
    String phone, {
    String? excludeCustomerId,
  }) {
    final target = normalizePhoneForComparison(phone);
    if (target == null) return null;

    for (final customer in customers) {
      if (excludeCustomerId != null && customer.id == excludeCustomerId) {
        continue;
      }
      final existing = normalizePhoneForComparison(customer.phone);
      if (existing != null && existing == target) {
        return customer;
      }
    }
    return null;
  }
}
