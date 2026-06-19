class AppSettings {
  final int totalBottleInventory;
  final int lowInventoryThreshold;

  const AppSettings({
    required this.totalBottleInventory,
    required this.lowInventoryThreshold,
  });

  AppSettings copyWith({
    int? totalBottleInventory,
    int? lowInventoryThreshold,
  }) {
    return AppSettings(
      totalBottleInventory:
          totalBottleInventory ?? this.totalBottleInventory,
      lowInventoryThreshold:
          lowInventoryThreshold ?? this.lowInventoryThreshold,
    );
  }
}
