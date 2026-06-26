import 'dart:io';

import 'package:sqlite3/sqlite3.dart';

import '../database/backup_schema_reader.dart';

/// Result of verifying a freshly created backup file.
class BackupVerificationResult {
  final bool passed;
  final bool fileExists;
  final bool databaseOpened;
  final bool integrityCheckPassed;
  final bool requiredTablesPresent;
  final int? schemaVersion;
  final String? failureReason;

  const BackupVerificationResult({
    required this.passed,
    this.fileExists = false,
    this.databaseOpened = false,
    this.integrityCheckPassed = false,
    this.requiredTablesPresent = false,
    this.schemaVersion,
    this.failureReason,
  });

  factory BackupVerificationResult.failed(String reason) {
    return BackupVerificationResult(
      passed: false,
      failureReason: reason,
    );
  }
}

class VerifiedBackupResult {
  final String path;
  final BackupVerificationResult verification;

  const VerifiedBackupResult({
    required this.path,
    required this.verification,
  });
}

class BackupVerificationService {
  BackupVerificationService._();

  static final BackupVerificationService instance = BackupVerificationService._();

  Future<BackupVerificationResult> verify(String backupPath) async {
    final file = File(backupPath);
    if (!await file.exists()) {
      return BackupVerificationResult.failed('Backup file not found');
    }

    if (await file.length() == 0) {
      return BackupVerificationResult.failed('Backup file is empty');
    }

    Database? db;
    try {
      db = sqlite3.open(file.path, mode: OpenMode.readOnly);

      final integrityRows = db.select('PRAGMA integrity_check');
      final integrityValue = integrityRows.isNotEmpty
          ? integrityRows.first.columnAt(0)?.toString()
          : null;
      final integrityOk = integrityValue == 'ok';

      final tableRows = db.select(
        "SELECT name FROM sqlite_master WHERE type='table' AND name IN "
        "('customers', 'deliveries', 'settings')",
      );
      final hasTables = tableRows.length >= 3;

      final schemaRows = db.select('PRAGMA user_version');
      final schemaVersion = schemaRows.isNotEmpty
          ? schemaRows.first.columnAt(0) as int?
          : await BackupSchemaReader.readUserVersion(file);

      final passed = integrityOk && hasTables;
      return BackupVerificationResult(
        passed: passed,
        fileExists: true,
        databaseOpened: true,
        integrityCheckPassed: integrityOk,
        requiredTablesPresent: hasTables,
        schemaVersion: schemaVersion,
        failureReason: passed
            ? null
            : _failureMessage(integrityOk: integrityOk, hasTables: hasTables),
      );
    } catch (e) {
      return BackupVerificationResult.failed('Could not open database: $e');
    } finally {
      db?.close();
    }
  }

  String? _failureMessage({
    required bool integrityOk,
    required bool hasTables,
  }) {
    if (!integrityOk && !hasTables) {
      return 'Integrity check failed and required tables are missing';
    }
    if (!integrityOk) {
      return 'Integrity check failed';
    }
    if (!hasTables) {
      return 'Required TubigTrack tables were not found';
    }
    return null;
  }
}
