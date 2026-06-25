enum RecoveryFileCategory {
  databaseBackup,
  archive,
  csvExport,
  report,
  emergencyRecovery,
}

class RecoveryFileInfo {
  final String path;
  final String fileName;
  final DateTime modifiedAt;
  final int sizeBytes;
  final RecoveryFileCategory category;
  final bool isPreUpdate;
  final String? appVersion;
  final int? databaseVersion;
  final int? customers;
  final int? deliveries;
  final int? inventoryTransactions;
  final String? databaseSize;
  final DateTime? metadataCreatedAt;

  const RecoveryFileInfo({
    required this.path,
    required this.fileName,
    required this.modifiedAt,
    required this.sizeBytes,
    required this.category,
    this.isPreUpdate = false,
    this.appVersion,
    this.databaseVersion,
    this.customers,
    this.deliveries,
    this.inventoryTransactions,
    this.databaseSize,
    this.metadataCreatedAt,
  });

  String get categoryLabel {
    switch (category) {
      case RecoveryFileCategory.databaseBackup:
        return isPreUpdate ? 'Pre-Update Backup' : 'Database Backup';
      case RecoveryFileCategory.archive:
        return 'Archive';
      case RecoveryFileCategory.csvExport:
        return 'CSV Export';
      case RecoveryFileCategory.report:
        return 'Business Report';
      case RecoveryFileCategory.emergencyRecovery:
        return 'Emergency Backup';
    }
  }

  bool get canRestore =>
      category == RecoveryFileCategory.databaseBackup ||
      category == RecoveryFileCategory.emergencyRecovery ||
      (category == RecoveryFileCategory.archive &&
          fileName.toLowerCase().endsWith('.db'));
}
