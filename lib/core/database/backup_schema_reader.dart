import 'dart:io';

import 'package:sqlite3/sqlite3.dart';

import 'app_database.dart';

/// Reads SQLite schema version from a database file without opening Drift.
class BackupSchemaReader {
  BackupSchemaReader._();

  static Future<int?> readUserVersion(File dbFile) async {
    if (!await dbFile.exists()) return null;
    Database? db;
    try {
      db = sqlite3.open(dbFile.path, mode: OpenMode.readOnly);
      final rows = db.select('PRAGMA user_version');
      if (rows.isEmpty) return null;
      return rows.first.columnAt(0) as int;
    } catch (_) {
      return null;
    } finally {
      db?.close();
    }
  }

  static Future<bool> hasRequiredTables(File dbFile) async {
    Database? db;
    try {
      db = sqlite3.open(dbFile.path, mode: OpenMode.readOnly);
      final rows = db.select(
        "SELECT name FROM sqlite_master WHERE type='table' AND name IN "
        "('customers', 'deliveries', 'settings')",
      );
      return rows.length >= 3;
    } catch (_) {
      return false;
    } finally {
      db?.close();
    }
  }

  static List<int> migrationStepsFrom(int fromSchema, int toSchema) {
    if (fromSchema >= toSchema) return [];
    return [for (var v = fromSchema + 1; v <= toSchema; v++) v];
  }

  static bool hasMigrationPath(int fromSchema, int toSchema) {
    if (fromSchema <= 0 || toSchema <= 0) return false;
    if (fromSchema > toSchema) return false;
    if (fromSchema < AppDatabase.minRestorableSchema) return false;
    return toSchema <= AppDatabase.currentSchemaVersion;
  }
}
