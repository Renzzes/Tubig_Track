enum InventoryAuditAction {
  balanced,
  markedMissing,
  adjustment,
  cancelled,
}

class InventoryAudit {
  final String id;
  final DateTime auditDate;
  final int systemCount;
  final int physicalCount;
  final int difference;
  final InventoryAuditAction actionTaken;
  final String? notes;

  const InventoryAudit({
    required this.id,
    required this.auditDate,
    required this.systemCount,
    required this.physicalCount,
    required this.difference,
    required this.actionTaken,
    this.notes,
  });

  static InventoryAuditAction actionFromString(String value) {
    switch (value) {
      case 'marked_missing':
        return InventoryAuditAction.markedMissing;
      case 'adjustment':
        return InventoryAuditAction.adjustment;
      case 'cancelled':
        return InventoryAuditAction.cancelled;
      default:
        return InventoryAuditAction.balanced;
    }
  }

  static String actionToString(InventoryAuditAction action) {
    switch (action) {
      case InventoryAuditAction.markedMissing:
        return 'marked_missing';
      case InventoryAuditAction.adjustment:
        return 'adjustment';
      case InventoryAuditAction.cancelled:
        return 'cancelled';
      case InventoryAuditAction.balanced:
        return 'balanced';
    }
  }

  static String actionLabel(InventoryAuditAction action) {
    switch (action) {
      case InventoryAuditAction.markedMissing:
        return 'Marked as Missing';
      case InventoryAuditAction.adjustment:
        return 'Inventory Adjustment';
      case InventoryAuditAction.cancelled:
        return 'Cancelled';
      case InventoryAuditAction.balanced:
        return 'Inventory Balanced';
    }
  }
}
