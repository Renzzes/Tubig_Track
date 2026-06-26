import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import 'backup_retention_service.dart';
import 'backup_verification_service.dart';
import '../../features/update/domain/repositories/backup_repository.dart';

/// When TubigTrack should create backups automatically.
enum AutomaticBackupSchedule {
  disabled,
  daily,
  weekly,
  beforeAppUpdates,
}

class AutomaticBackupService {
  AutomaticBackupService._();

  static final AutomaticBackupService instance = AutomaticBackupService._();

  bool _running = false;

  Future<AutomaticBackupSchedule> loadSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(AppConstants.prefAutomaticBackupSchedule);
    return AutomaticBackupSchedule.values.firstWhere(
      (value) => value.name == name,
      orElse: () => AutomaticBackupSchedule.disabled,
    );
  }

  Future<void> saveSchedule(AutomaticBackupSchedule schedule) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.prefAutomaticBackupSchedule,
      schedule.name,
    );
  }

  Future<DateTime?> loadLastRunAt() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AppConstants.prefAutomaticBackupLastRunAt);
    return raw == null ? null : DateTime.tryParse(raw);
  }

  Future<bool> shouldBackupBeforeUpdate() async {
    return (await loadSchedule()) ==
        AutomaticBackupSchedule.beforeAppUpdates;
  }

  Future<VerifiedBackupResult?> maybeRunScheduledBackup(
    BackupRepository repository,
  ) async {
    if (_running) return null;

    final schedule = await loadSchedule();
    if (schedule != AutomaticBackupSchedule.daily &&
        schedule != AutomaticBackupSchedule.weekly) {
      return null;
    }

    if (!await _isDue(schedule)) return null;

    _running = true;
    try {
      return await _runAutomaticBackup(repository);
    } finally {
      _running = false;
    }
  }

  Future<VerifiedBackupResult?> runBeforeUpdateBackup(
    BackupRepository repository,
  ) async {
    if (_running) return null;
    if (!await shouldBackupBeforeUpdate()) return null;

    _running = true;
    try {
      return await _runAutomaticBackup(
        repository,
        usePreUpdateNaming: true,
      );
    } finally {
      _running = false;
    }
  }

  Future<VerifiedBackupResult> _runAutomaticBackup(
    BackupRepository repository, {
    bool usePreUpdateNaming = false,
  }) async {
    final result = usePreUpdateNaming
        ? await repository.createVerifiedPreUpdateBackup()
        : await repository.createVerifiedAutomaticBackup();

    await _saveLastRunAt(DateTime.now());
    await BackupRetentionService.instance.cleanOldBackups();
    return result;
  }

  Future<void> _saveLastRunAt(DateTime when) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.prefAutomaticBackupLastRunAt,
      when.toIso8601String(),
    );
  }

  Future<bool> _isDue(AutomaticBackupSchedule schedule) async {
    final lastRun = await loadLastRunAt();
    if (lastRun == null) return true;

    final now = DateTime.now();
    switch (schedule) {
      case AutomaticBackupSchedule.daily:
        return !_isSameDay(lastRun, now);
      case AutomaticBackupSchedule.weekly:
        return now.difference(lastRun).inDays >= 7;
      case AutomaticBackupSchedule.disabled:
      case AutomaticBackupSchedule.beforeAppUpdates:
        return false;
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
