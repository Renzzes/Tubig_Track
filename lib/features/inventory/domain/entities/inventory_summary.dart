class InventorySummary {
  final int initialInventory;
  final int totalBottlesOwned;
  final int bottlesWithCustomers;
  final int filledBottlesAvailable;
  final int emptyBottlesReadyForRefill;
  final int borrowedBottles;
  final int returnedBottles;
  final int damagedBottles;
  final int missingBottles;
  final int purchasedBottles;
  final int donatedBottles;
  final int customerAdjustmentNet;
  final int refilledBottles;
  final int gallonsStock;
  final int capsStock;
  final int waterStocks;
  final int othersStock;

  const InventorySummary({
    required this.initialInventory,
    required this.totalBottlesOwned,
    required this.bottlesWithCustomers,
    required this.filledBottlesAvailable,
    required this.emptyBottlesReadyForRefill,
    required this.borrowedBottles,
    required this.returnedBottles,
    required this.damagedBottles,
    required this.missingBottles,
    required this.purchasedBottles,
    required this.donatedBottles,
    this.customerAdjustmentNet = 0,
    this.refilledBottles = 0,
    this.gallonsStock = 0,
    this.capsStock = 0,
    this.waterStocks = 0,
    this.othersStock = 0,
  });

  /// Backward-compatible alias.
  int get totalBottles => totalBottlesOwned;

  /// Backward-compatible alias.
  int get borrowedOutstanding => bottlesWithCustomers;

  /// Backward-compatible alias.
  int get collectedEmptyBottles => emptyBottlesReadyForRefill;

  /// Backward-compatible alias for filled bottles ready for delivery.
  int get availableBottles => filledBottlesAvailable;

  /// Backward-compatible alias.
  int get availableStock => filledBottlesAvailable;
}
