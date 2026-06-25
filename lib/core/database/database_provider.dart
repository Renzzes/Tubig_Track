import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database_restore_service.dart';
import 'app_database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() {
    if (!skipDatabaseDisposeClose) {
      db.close();
    }
  });
  return db;
});
