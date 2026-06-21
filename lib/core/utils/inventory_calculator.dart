/// Pure bottle-inventory math used across inventory, dashboard, and reports.
class InventoryTotals {
  final int initialInventory;
  final int purchasedBottles;
  final int permanentlyRemovedBottles;
  final int donatedBottles;
  final int borrowedBottles;
  final int returnedBottles;
  final int damagedBottles;
  final int missingBottles;
  final int customerAdjustmentNet;
  /// Bottles refilled via supplier delivery (supply purchases of filled bottles).
  final int refilledBottles;

  const InventoryTotals({
    required this.initialInventory,
    required this.purchasedBottles,
    this.permanentlyRemovedBottles = 0,
    required this.donatedBottles,
    required this.borrowedBottles,
    required this.returnedBottles,
    required this.damagedBottles,
    required this.missingBottles,
    this.customerAdjustmentNet = 0,
    this.refilledBottles = 0,
  });
}

class InventoryCalculator {
  InventoryCalculator._();

  /// Physical bottle assets: initial + purchased − damaged − missing − donated.
  static int totalBottlesOwned(InventoryTotals t) =>
      (t.initialInventory +
              t.purchasedBottles -
              t.permanentlyRemovedBottles -
              t.donatedBottles -
              t.missingBottles -
              t.damagedBottles)
          .clamp(0, 999999);

  /// Global bottles with customers (delivered − collected + manual adjustments).
  static int bottlesWithCustomers(InventoryTotals t) =>
      (t.borrowedBottles -
              t.returnedBottles +
              t.customerAdjustmentNet)
          .clamp(0, 999999);

  /// Empties collected from customers waiting for refill.
  static int emptyBottlesReadyForRefill(InventoryTotals t) =>
      (t.returnedBottles - t.refilledBottles).clamp(0, 999999);

  /// Backward-compatible alias.
  static int collectedEmptyBottles(InventoryTotals t) =>
      emptyBottlesReadyForRefill(t);

  /// Validates: owned = filled + empty + with customers + damaged + missing
  static bool isAuditBalanced({
    required int totalOwned,
    required int filledAvailable,
    required int emptyReadyForRefill,
    required int bottlesWithCustomers,
    required int damagedBottles,
    required int missingBottles,
  }) {
    final sum = filledAvailable +
        emptyReadyForRefill +
        bottlesWithCustomers +
        damagedBottles +
        missingBottles;
    return totalOwned == sum;
  }

  /// Per-customer: delivered − collected + all customer adjustments (incl. initial).
  static int customerBottlesHeld({
    required int delivered,
    required int collected,
    int manualAdjustments = 0,
  }) =>
      (delivered - collected + manualAdjustments).clamp(0, 999999);

  /// Validates customer balances sum matches global with-customers count.
  static bool customerBalancesMatchGlobal({
    required int globalWithCustomers,
    required int sumCustomerHeld,
  }) =>
      globalWithCustomers == sumCustomerHeld;
}

class InventoryConsistencyReport {
  final int globalWithCustomers;
  final int sumCustomerHeld;
  final int filledBottlesAvailable;
  final int emptyBottlesReadyForRefill;
  final int totalBottlesOwned;
  final int damagedBottles;
  final int missingBottles;

  const InventoryConsistencyReport({
    required this.globalWithCustomers,
    required this.sumCustomerHeld,
    required this.filledBottlesAvailable,
    required this.emptyBottlesReadyForRefill,
    required this.totalBottlesOwned,
    required this.damagedBottles,
    required this.missingBottles,
  });

  bool get isCustomerBalanceConsistent =>
      globalWithCustomers == sumCustomerHeld;

  int get customerBalanceDelta => sumCustomerHeld - globalWithCustomers;

  bool get isAuditBalanced => InventoryCalculator.isAuditBalanced(
        totalOwned: totalBottlesOwned,
        filledAvailable: filledBottlesAvailable,
        emptyReadyForRefill: emptyBottlesReadyForRefill,
        bottlesWithCustomers: globalWithCustomers,
        damagedBottles: damagedBottles,
        missingBottles: missingBottles,
      );
}
