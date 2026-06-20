class InventoryAdjustment {
  final String id;
  final DateTime adjustmentDate;
  final int quantity;
  final String reason;
  final String? notes;

  const InventoryAdjustment({
    required this.id,
    required this.adjustmentDate,
    required this.quantity,
    required this.reason,
    this.notes,
  });
}
