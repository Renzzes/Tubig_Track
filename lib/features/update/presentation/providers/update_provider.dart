import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/database/database_provider.dart';
import '../../data/repositories/backup_repository_impl.dart';
import '../../data/repositories/update_repository_impl.dart';
import '../../domain/entities/backup_file_info.dart';
import '../../domain/entities/update_channel.dart';
import '../../domain/entities/update_history_entry.dart';
import '../../domain/repositories/backup_repository.dart';
import '../../domain/repositories/update_repository.dart';
import '../../services/update_service.dart';
import '../screens/update_diagnostics_screen.dart';

final updateRepositoryProvider = Provider<UpdateRepository>((ref) {
  return UpdateRepositoryImpl();
});

final backupRepositoryProvider = Provider<BackupRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return BackupRepositoryImpl(db);
});

final updateServiceProvider = Provider<UpdateService>((ref) {
  return UpdateService(
    updateRepository: ref.watch(updateRepositoryProvider),
    backupRepository: ref.watch(backupRepositoryProvider),
  );
});

final updateChannelProvider = FutureProvider<UpdateChannel>((ref) async {
  return ref.watch(updateServiceProvider).getChannel();
});

final updateHistoryProvider =
    FutureProvider<List<UpdateHistoryEntry>>((ref) async {
  return ref.watch(updateServiceProvider).getHistory();
});

final lastUpdateCheckProvider = FutureProvider<DateTime?>((ref) async {
  return ref.watch(updateServiceProvider).getLastCheckTime();
});

final packageInfoProvider = FutureProvider<PackageInfo>((ref) async {
  return ref.watch(updateServiceProvider).getPackageInfo();
});

final availableBackupsProvider =
    FutureProvider<List<BackupFileInfo>>((ref) async {
  return ref.watch(backupRepositoryProvider).listBackups();
});

final updateDiagnosticsProvider =
    FutureProvider<UpdateDiagnosticsData>((ref) async {
  final service = ref.watch(updateServiceProvider);
  final result = await service.checkForUpdates();
  return UpdateDiagnosticsData(
    currentVersion: result.currentVersion,
    latestVersion: result.latestVersion ?? result.fetchResult?.latestVersion,
    isUpdateAvailable: result.isUpdateAvailable,
    fetchResult: result.fetchResult ?? service.lastFetchResult,
  );
});
