class AppConstants {
  static const String appName = 'TubigTrack';
  static const String appVersion = '1.8.3.1';
  static const String applicationId = 'com.tubigtrack.tubig_track';

  /// GitHub Releases API for self-update.
  static const String githubLatestReleaseUrl =
      'https://api.github.com/repos/Renzzes/Tubig_Track/releases/latest';
  static const String githubReleasesUrl =
      'https://api.github.com/repos/Renzzes/Tubig_Track/releases';

  static const String prefStorageRootPath = 'tubigtrack_storage_root_path';
  static const String prefStorageKind = 'tubigtrack_storage_kind';
  static const String prefStorageLastTestAt = 'tubigtrack_storage_last_test_at';
  static const String prefBackupKeepCount = 'tubigtrack_backup_keep_count';
  static const String prefBackupMaxAge = 'tubigtrack_backup_max_age';
  static const String prefAutomaticBackupSchedule =
      'tubigtrack_automatic_backup_schedule';
  static const String prefAutomaticBackupLastRunAt =
      'tubigtrack_automatic_backup_last_run_at';

  static const String tubigTrackRoot = 'TubigTrack';
  static const String backupsSubfolder = 'Backups';
  static const String archivesSubfolder = 'Archives';
  static const String csvSubfolder = 'CSV';
  static const String reportsSubfolder = 'Reports';
  static const String recoverySubfolder = 'Recovery';
  static const String restoreLogsSubfolder = 'RestoreLogs';
  static const String backupEventsSubfolder = 'BackupEvents';

  /// Legacy path segments kept for migration checks.
  static const String backupsFolderName = 'TubigTrack/Backups';
  static const String archivesFolderName = 'TubigTrack/Archives';

  static const List<String> tubigTrackSubfolders = [
    backupsSubfolder,
    archivesSubfolder,
    csvSubfolder,
    reportsSubfolder,
    recoverySubfolder,
  ];

  static const String preUpdateBackupPrefix = 'tubigtrack_preupdate_';
  static const String manualBackupPrefix = 'TubigTrack_Backup_';
  static const String autoBackupPrefix = 'TubigTrack_AutoBackup_';

  static const String settingTotalBottleInventory = 'total_bottle_inventory';
  static const String settingFilledBottlesAvailable = 'filled_bottles_available';
  static const String settingEmptyBottlesReadyForRefill =
      'empty_bottles_ready_for_refill';
  static const String settingInitialCustomerBottleBalance =
      'initial_customer_bottle_balance';
  static const String settingCustomerBottleAdjustments =
      'customer_bottle_adjustments';
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
  static const String transactionCustomerAdjustment = 'customer_adjustment';

  /// Reason stored on initial migration customer_adjustment rows.
  static const String initialBalanceMigrationReason = 'Initial Balance Migration';

  static String initialBalanceTransactionId(String customerId) =>
      '${customerId}_initial_balance';

  static const String customerOwnedEventSetBalance = 'set_balance';
  static const String customerOwnedEventAdjustBalance = 'adjust_balance';
  static const String customerOwnedEventCollected = 'collected';
  static const String customerOwnedEventDeliveryFilled = 'delivery_filled';

  static const String paymentStatusPaid = 'paid';
  static const String paymentStatusUnpaid = 'unpaid';
  static const String paymentStatusPartial = 'partial';

  static const String dbFileName = 'tubig_track_db';
}
