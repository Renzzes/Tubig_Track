/// Pure bottle-inventory math used across inventory, dashboard, and reports.
class InventoryTotals {
  final int initialInventory;
  final int purchasedBottles;
  final int addedBottles;
  final int permanentlyRemovedBottles;
  final int donatedBottles;
  final int borrowedBottles;
  final int returnedBottles;
  final int damagedBottles;
  final int missingBottles;
  final int adjustmentNet;

  const InventoryTotals({
    required this.initialInventory,
    required this.purchasedBottles,
    this.addedBottles = 0,
    this.permanentlyRemovedBottles = 0,
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

  /// Lifetime bottles owned by the business (ownership baseline).
  static int totalBottlesOwned(InventoryTotals t) =>
      (t.initialInventory +
              t.purchasedBottles +
              t.addedBottles -
              t.permanentlyRemovedBottles)
          .clamp(0, 999999);

  /// Bottles currently held by customers (delivered − collected).
  static int bottlesWithCustomers(InventoryTotals t) =>
      (t.borrowedBottles - t.returnedBottles).clamp(0, 999999);

  /// Physical bottles in warehouse and ready for use.
  static int availableStock(InventoryTotals t) {
    final owned = totalBottlesOwned(t);
    final withCustomers = bottlesWithCustomers(t);
    return (owned -
            withCustomers -
            t.damagedBottles -
            t.missingBottles -
            t.donatedBottles +
            t.adjustmentNet)
        .clamp(0, 999999);
  }

  /// Backward-compatible alias.
  static int availableBottles(InventoryTotals t) => availableStock(t);

  /// Validates reconciliation: owned = stock + with customers + damaged + missing + donated − adjustment
  static bool isBalanced(InventoryTotals t) {
    final owned = totalBottlesOwned(t);
    final sum = availableStock(t) +
        bottlesWithCustomers(t) +
        t.damagedBottles +
        t.missingBottles +
        t.donatedBottles -
        t.adjustmentNet;
    return owned == sum;
  }

  /// Per-customer bottles currently held.
  static int customerBottlesHeld({
    required int delivered,
    required int collected,
  }) =>
      (delivered - collected).clamp(0, 999999);
}
