/// Pure bottle-inventory math used across inventory, dashboard, and reports.
class InventoryTotals {
  final int initialInventory;
  final int purchasedBottles;
  final int donatedBottles;
  final int borrowedBottles;
  final int returnedBottles;
  final int damagedBottles;
  final int missingBottles;
  final int adjustmentNet;

  const InventoryTotals({
    required this.initialInventory,
    required this.purchasedBottles,
    required this.donatedBottles,
    required this.borrowedBottles,
    required this.returnedBottles,
    required this.damagedBottles,
    required this.missingBottles,
    this.adjustmentNet = 0,
  });
}

class InventoryCalculator {
  InventoryCalculator._();

  /// Total bottles owned by the business.
  static int totalBottlesOwned(InventoryTotals t) =>
      (t.initialInventory + t.purchasedBottles - t.donatedBottles)
          .clamp(0, 999999);

  /// Bottles currently held by customers.
  static int bottlesWithCustomers(InventoryTotals t) =>
      (t.borrowedBottles - t.returnedBottles).clamp(0, 999999);

  /// Bottles physically available inside the business.
  static int availableBottles(InventoryTotals t) {
    final owned = totalBottlesOwned(t);
    final withCustomers = bottlesWithCustomers(t);
    return (owned -
            withCustomers -
            t.damagedBottles -
            t.missingBottles +
            t.adjustmentNet)
        .clamp(0, 999999);
  }

  /// Validates: owned + adjustment == available + withCustomers + damaged + missing
  static bool isBalanced(InventoryTotals t) {
    final owned = totalBottlesOwned(t) + t.adjustmentNet;
    final sum = availableBottles(t) +
        bottlesWithCustomers(t) +
        t.damagedBottles +
        t.missingBottles;
    return owned == sum;
  }
}
