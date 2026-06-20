class AppSettings {
  final int totalBottleInventory;
  final int lowInventoryThreshold;
  final int minBottles;
  final int minGallons;
  final int minCaps;
  final int minWaterStocks;

  const AppSettings({
    required this.totalBottleInventory,
    required this.lowInventoryThreshold,
    required this.minBottles,
    required this.minGallons,
    required this.minCaps,
    required this.minWaterStocks,
  });

  AppSettings copyWith({
    int? totalBottleInventory,
    int? lowInventoryThreshold,
    int? minBottles,
    int? minGallons,
    int? minCaps,
    int? minWaterStocks,
  }) {
    return AppSettings(
      totalBottleInventory:
          totalBottleInventory ?? this.totalBottleInventory,
      lowInventoryThreshold:
          lowInventoryThreshold ?? this.lowInventoryThreshold,
      minBottles: minBottles ?? this.minBottles,
      minGallons: minGallons ?? this.minGallons,
      minCaps: minCaps ?? this.minCaps,
      minWaterStocks: minWaterStocks ?? this.minWaterStocks,
    );
  }
}
