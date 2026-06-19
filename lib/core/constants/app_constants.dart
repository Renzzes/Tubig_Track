class AppConstants {
  static const String appName = 'TubigTrack';
  static const String appVersion = '1.2.0';
  static const String applicationId = 'com.tubigtrack.tubig_track';

  /// Remote update manifest URLs (host your JSON at these endpoints).
  static const String updateManifestUrlStable =
      'https://tubigtrack.app/updates/stable.json';
  static const String updateManifestUrlBeta =
      'https://tubigtrack.app/updates/beta.json';

  static const String backupsFolderName = 'TubigTrack/Backups';
  static const String preUpdateBackupPrefix = 'tubigtrack_preupdate_';

  static const String settingTotalBottleInventory = 'total_bottle_inventory';
  static const String settingLowInventoryThreshold = 'low_inventory_threshold';
  static const int defaultBottleInventory = 100;
  static const int defaultLowInventoryThreshold = 25;
  static const double defaultPricePerBottle = 30.0;

  static const List<String> expenseCategories = [
    'Fuel',
    'Electricity',
    'Water',
    'Maintenance',
    'Salary',
    'Supplies',
    'Others',
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
