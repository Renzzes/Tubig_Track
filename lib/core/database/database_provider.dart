import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database_restore_service.dart';
import 'app_database.dart';
import '../services/app_startup_service.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppStartupService.instance.getDatabase();
  ref.onDispose(() {
    if (!skipDatabaseDisposeClose) {
      db.close();
    }
  });
  return db;
});
