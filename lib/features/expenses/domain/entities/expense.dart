class Expense {
  final String id;
  final String category;
  final double amount;
  final DateTime date;
  final String? notes;
  final String? description;
  final String? supplier;
  final int? quantity;
  final double? unitCost;
  final String? supplyPurchaseId;

  const Expense({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    this.notes,
    this.description,
    this.supplier,
    this.quantity,
    this.unitCost,
    this.supplyPurchaseId,
  });

  String get displayDescription {
    if (description != null && description!.isNotEmpty) return description!;
    if (quantity != null && quantity! > 0) {
      return '$quantity $category';
    }
    return category;
  }
}
