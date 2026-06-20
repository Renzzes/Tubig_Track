import '../../../../core/utils/inventory_calculator.dart';

class InventorySummary {
  final int initialInventory;
  final int totalBottlesOwned;
  final int bottlesWithCustomers;
  final int availableBottles;
  final int borrowedBottles;
  final int returnedBottles;
  final int damagedBottles;
  final int missingBottles;
  final int purchasedBottles;
  final int donatedBottles;
  final int adjustmentNet;
  final int gallonsStock;
  final int capsStock;
  final int waterStocks;
  final int othersStock;

  const InventorySummary({
    required this.initialInventory,
    required this.totalBottlesOwned,
    required this.bottlesWithCustomers,
    required this.availableBottles,
    required this.borrowedBottles,
    required this.returnedBottles,
    required this.damagedBottles,
    required this.missingBottles,
    required this.purchasedBottles,
    required this.donatedBottles,
    required this.adjustmentNet,
    this.gallonsStock = 0,
    this.capsStock = 0,
    this.waterStocks = 0,
    this.othersStock = 0,
  });

  /// Backward-compatible alias.
  int get totalBottles => totalBottlesOwned;

  /// Backward-compatible alias.
  int get borrowedOutstanding => bottlesWithCustomers;

  bool get isBalanced {
    final totals = InventoryTotals(
      initialInventory: initialInventory,
      purchasedBottles: purchasedBottles,
      donatedBottles: donatedBottles,
      borrowedBottles: borrowedBottles,
      returnedBottles: returnedBottles,
      damagedBottles: damagedBottles,
      missingBottles: missingBottles,
      adjustmentNet: adjustmentNet,
    );
    return InventoryCalculator.isBalanced(totals);
  }
}
