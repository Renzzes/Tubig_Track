class AppConstants {
  static const String appName = 'TubigTrack';
  static const String appVersion = '1.3.4';
  static const String applicationId = 'com.tubigtrack.tubig_track';

  /// GitHub Releases API for self-update.
  static const String githubLatestReleaseUrl =
      'https://api.github.com/repos/Renzzes/Tubig_Track/releases/latest';
  static const String githubReleasesUrl =
      'https://api.github.com/repos/Renzzes/Tubig_Track/releases';

  static const String backupsFolderName = 'TubigTrack/Backups';
  static const String archivesFolderName = 'TubigTrack/Archives';
  static const String preUpdateBackupPrefix = 'tubigtrack_preupdate_';

  static const String settingTotalBottleInventory = 'total_bottle_inventory';
  static const String settingLowInventoryThreshold = 'low_inventory_threshold';
  static const String settingMinBottles = 'min_bottles';
  static const String settingMinGallons = 'min_gallons';
  static const String settingMinCaps = 'min_caps';
  static const String settingMinWaterStocks = 'min_water_stocks';
  static const String settingCostPerBottle = 'cost_per_bottle';
  static const int defaultBottleInventory = 100;
  static const int defaultLowInventoryThreshold = 25;
  static const int defaultMinBottles = 20;
  static const int defaultMinGallons = 10;
  static const int defaultMinCaps = 100;
  static const int defaultMinWaterStocks = 5;
  static const double defaultPricePerBottle = 30.0;
  static const double defaultCostPerBottle = 25.0;

  static const List<String> supplyItemTypes = [
    'Gallons',
    'Bottles',
    'Caps',
    'Water Stocks',
    'Others',
  ];

  /// Keys used in inventory_stock table (non-bottle items).
  static const Map<String, String> supplyItemStockKeys = {
    'Gallons': 'gallons',
    'Caps': 'caps',
    'Water Stocks': 'water_stocks',
    'Others': 'others',
  };

  static const List<String> expenseCategories = [
    'Supplies',
    'Other Supplies',
    'Operations',
    'Maintenance',
    'Utilities',
    'Miscellaneous',
  ];

  static const String transactionBorrow = 'borrow';
  static const String transactionReturn = 'return';
  static const String transactionDamaged = 'damaged';
  static const String transactionPurchase = 'purchase';

  static const String paymentStatusPaid = 'paid';
  static const String paymentStatusUnpaid = 'unpaid';
  static const String paymentStatusPartial = 'partial';

  static const String dbFileName = 'tubig_track_db';
}
