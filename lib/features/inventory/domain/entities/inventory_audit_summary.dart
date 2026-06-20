class InventoryAuditSummary {
  final int totalAudits;
  final DateTime? lastAuditDate;
  final int missingBottlesFound;
  final int adjustmentQuantity;

  const InventoryAuditSummary({
    required this.totalAudits,
    required this.lastAuditDate,
    required this.missingBottlesFound,
    required this.adjustmentQuantity,
  });

  bool get needsAuditReminder {
    if (lastAuditDate == null) return true;
    final days = DateTime.now().difference(lastAuditDate!).inDays;
    return days >= 30;
  }
}
