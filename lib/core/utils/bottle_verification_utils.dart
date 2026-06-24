import '../../features/customers/domain/entities/customer.dart';

enum PhysicalCountStatus {
  verified,
  needsReconciliation,
  notVerified,
}

extension PhysicalCountStatusX on PhysicalCountStatus {
  String get label => switch (this) {
        PhysicalCountStatus.verified => 'Verified',
        PhysicalCountStatus.needsReconciliation => 'Needs Reconciliation',
        PhysicalCountStatus.notVerified => 'Not Verified',
      };

  String get listBadgeLabel => switch (this) {
        PhysicalCountStatus.verified => '✓ Verified',
        PhysicalCountStatus.needsReconciliation => '⚠ Needs Reconciliation',
        PhysicalCountStatus.notVerified => '❓ Not Verified',
      };

  /// Plain-language explanation shown on customer profile and detail views.
  String get description => switch (this) {
        PhysicalCountStatus.verified =>
          'Physical bottle count verified within the last 30 days',
        PhysicalCountStatus.needsReconciliation =>
          'Last physical count was more than 30 days ago — reconcile soon',
        PhysicalCountStatus.notVerified =>
          'Physical bottle count has never been verified',
      };

  int get colorValue => switch (this) {
        PhysicalCountStatus.verified => 0xFF2E7D32,
        PhysicalCountStatus.needsReconciliation => 0xFFF57C00,
        PhysicalCountStatus.notVerified => 0xFF757575,
      };
}

class BottleVerificationSummary {
  final int verified;
  final int needsReconciliation;
  final int notVerified;

  const BottleVerificationSummary({
    required this.verified,
    required this.needsReconciliation,
    required this.notVerified,
  });

  int get total => verified + needsReconciliation + notVerified;
}

/// Days after which a physical count is considered stale.
const physicalCountVerificationWindowDays = 30;

class BottleVerificationUtils {
  BottleVerificationUtils._();

  static PhysicalCountStatus statusFor(Customer customer, {DateTime? now}) {
    final date = customer.lastPhysicalCountDate;
    if (date == null) return PhysicalCountStatus.notVerified;

    final reference = now ?? DateTime.now();
    final days = reference.difference(date).inDays;
    if (days <= physicalCountVerificationWindowDays) {
      return PhysicalCountStatus.verified;
    }
    return PhysicalCountStatus.needsReconciliation;
  }

  static int? daysSinceLastPhysicalCount(Customer customer, {DateTime? now}) {
    final date = customer.lastPhysicalCountDate;
    if (date == null) return null;
    final reference = now ?? DateTime.now();
    return reference.difference(date).inDays;
  }

  static String daysSinceLabel(Customer customer, {DateTime? now}) {
    final days = daysSinceLastPhysicalCount(customer, now: now);
    if (days == null) return 'Never Verified';
    if (days == 0) return 'Today';
    if (days == 1) return '1 Day';
    return '$days Days';
  }

  static String lastPhysicalCountLabel(Customer customer) {
    if (customer.lastPhysicalCountDate == null) return 'Never';
    return _formatDate(customer.lastPhysicalCountDate!);
  }

  static BottleVerificationSummary summarize(List<Customer> customers,
      {DateTime? now}) {
    var verified = 0;
    var needs = 0;
    var notVerified = 0;
    for (final c in customers) {
      switch (statusFor(c, now: now)) {
        case PhysicalCountStatus.verified:
          verified++;
        case PhysicalCountStatus.needsReconciliation:
          needs++;
        case PhysicalCountStatus.notVerified:
          notVerified++;
      }
    }
    return BottleVerificationSummary(
      verified: verified,
      needsReconciliation: needs,
      notVerified: notVerified,
    );
  }

  static List<Customer> customersNeedingReconciliation(List<Customer> customers,
      {DateTime? now}) {
    return customers
        .where(
          (c) => statusFor(c, now: now) ==
              PhysicalCountStatus.needsReconciliation,
        )
        .toList()
      ..sort(
        (a, b) => (a.lastPhysicalCountDate ?? DateTime(2000))
            .compareTo(b.lastPhysicalCountDate ?? DateTime(2000)),
      );
  }

  static List<Customer> neverVerifiedCustomers(List<Customer> customers) {
    return customers
        .where((c) => c.lastPhysicalCountDate == null)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  static String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
