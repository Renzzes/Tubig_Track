class InventorySummary {
  /// The starting inventory set by the user (before any transactions).
  final int initialInventory;

  /// initialInventory + purchased − damaged
  final int totalBottles;

  /// borrowed − returned (bottles currently with customers)
  final int borrowedOutstanding;

  /// totalBottles − borrowedOutstanding
  final int availableBottles;

  // Raw totals for reference
  final int borrowedBottles;
  final int returnedBottles;
  final int damagedBottles;
  final int purchasedBottles;

  const InventorySummary({
    required this.initialInventory,
    required this.totalBottles,
    required this.borrowedOutstanding,
    required this.availableBottles,
    required this.borrowedBottles,
    required this.returnedBottles,
    required this.damagedBottles,
    required this.purchasedBottles,
  });
}
