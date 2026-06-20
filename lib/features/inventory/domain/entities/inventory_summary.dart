class InventorySummary {
  final int initialInventory;
  final int totalBottles;
  final int borrowedOutstanding;
  final int availableBottles;
  final int borrowedBottles;
  final int returnedBottles;
  final int damagedBottles;
  final int purchasedBottles;
  final int gallonsStock;
  final int capsStock;
  final int waterStocks;
  final int othersStock;

  const InventorySummary({
    required this.initialInventory,
    required this.totalBottles,
    required this.borrowedOutstanding,
    required this.availableBottles,
    required this.borrowedBottles,
    required this.returnedBottles,
    required this.damagedBottles,
    required this.purchasedBottles,
    this.gallonsStock = 0,
    this.capsStock = 0,
    this.waterStocks = 0,
    this.othersStock = 0,
  });
}
