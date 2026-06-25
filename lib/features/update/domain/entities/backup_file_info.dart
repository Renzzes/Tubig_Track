class BackupFileInfo {
  final String path;
  final String fileName;
  final DateTime modifiedAt;
  final int sizeBytes;
  final bool isPreUpdate;
  final String? appVersion;
  final int? databaseVersion;
  final int? customers;
  final int? deliveries;
  final int? inventoryTransactions;
  final String? databaseSize;

  const BackupFileInfo({
    required this.path,
    required this.fileName,
    required this.modifiedAt,
    this.sizeBytes = 0,
    this.isPreUpdate = false,
    this.appVersion,
    this.databaseVersion,
    this.customers,
    this.deliveries,
    this.inventoryTransactions,
    this.databaseSize,
  });
}
