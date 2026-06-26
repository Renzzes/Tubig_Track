/// Metadata stored alongside each database backup.
class BackupMetadata {
  final String appVersion;
  final int databaseSchema;
  final DateTime createdAt;
  final int customers;
  final int deliveries;
  final int inventoryTransactions;
  final String databaseSize;
  final String? fileName;

  const BackupMetadata({
    required this.appVersion,
    required this.databaseSchema,
    required this.createdAt,
    required this.customers,
    required this.deliveries,
    required this.inventoryTransactions,
    required this.databaseSize,
    this.fileName,
  });

  factory BackupMetadata.fromJson(Map<String, dynamic> json) {
    return BackupMetadata(
      appVersion: json['appVersion'] as String? ?? 'unknown',
      databaseSchema: _readSchema(json),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      customers: json['customers'] as int? ?? 0,
      deliveries: json['deliveries'] as int? ?? 0,
      inventoryTransactions: json['inventoryTransactions'] as int? ?? 0,
      databaseSize: json['databaseSize'] as String? ?? 'unknown',
      fileName: json['fileName'] as String?,
    );
  }

  static int _readSchema(Map<String, dynamic> json) {
    return json['databaseSchema'] as int? ??
        json['databaseVersion'] as int? ??
        0;
  }

  Map<String, dynamic> toJson() => {
        'appVersion': appVersion,
        'databaseSchema': databaseSchema,
        'createdAt': createdAt.toIso8601String(),
        'customers': customers,
        'deliveries': deliveries,
        'inventoryTransactions': inventoryTransactions,
        'databaseSize': databaseSize,
        if (fileName != null) 'fileName': fileName,
      };
}

enum BackupCompatibilityStatus {
  /// Same schema — direct restore.
  compatible,

  /// Older schema with a known migration path.
  migratable,

  /// Backup is from a newer app version.
  newerThanApp,

  /// No migration path or corrupt database.
  unsupported,

  /// Could not determine schema.
  unknown,
}

class BackupCompatibilityResult {
  final BackupCompatibilityStatus status;
  final String backupPath;
  final BackupMetadata? metadata;
  final int? detectedSchema;
  final int currentSchema;
  final String currentAppVersion;
  final String? reason;
  final List<int> migrationSteps;

  const BackupCompatibilityResult({
    required this.status,
    required this.backupPath,
    required this.currentSchema,
    required this.currentAppVersion,
    this.metadata,
    this.detectedSchema,
    this.reason,
    this.migrationSteps = const [],
  });

  int get backupSchema => metadata?.databaseSchema ?? detectedSchema ?? 0;

  String get backupAppVersion => metadata?.appVersion ?? 'unknown';

  bool get canRestoreDirectly => status == BackupCompatibilityStatus.compatible;

  bool get canMigrate => status == BackupCompatibilityStatus.migratable;

  bool get canAttemptReadOnly =>
      status == BackupCompatibilityStatus.unsupported ||
      status == BackupCompatibilityStatus.newerThanApp ||
      status == BackupCompatibilityStatus.unknown;
}

class BackupMigrationResult {
  final bool success;
  final String? migratedFilePath;
  final String? errorMessage;
  final List<int> migrationStepsExecuted;
  final int? finalSchema;

  const BackupMigrationResult({
    required this.success,
    this.migratedFilePath,
    this.errorMessage,
    this.migrationStepsExecuted = const [],
    this.finalSchema,
  });
}

class RestoreOperationResult {
  final bool success;
  final String? errorMessage;
  final BackupCompatibilityResult? compatibility;
  final BackupMigrationResult? migration;
  final String? logPath;
  final bool rollbackFailed;
  final String? safetyCopyPath;

  const RestoreOperationResult({
    required this.success,
    this.errorMessage,
    this.compatibility,
    this.migration,
    this.logPath,
    this.rollbackFailed = false,
    this.safetyCopyPath,
  });
}
