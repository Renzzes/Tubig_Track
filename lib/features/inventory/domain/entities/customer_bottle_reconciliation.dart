class CustomerBottleReconciliation {
  final String id;
  final String customerId;
  final int expectedCount;
  final int actualCount;
  final int variance;
  final String? reason;
  final String? notes;
  final bool adjustmentApplied;
  final DateTime createdAt;

  const CustomerBottleReconciliation({
    required this.id,
    required this.customerId,
    required this.expectedCount,
    required this.actualCount,
    required this.variance,
    this.reason,
    this.notes,
    this.adjustmentApplied = false,
    required this.createdAt,
  });
}
