import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/services/automatic_backup_service.dart';
import '../../../../core/services/backup_event_log_service.dart';
import '../../../../core/services/backup_retention_service.dart';
import '../../../../core/services/data_storage_service.dart';
import '../../../../core/services/storage_folder_opener.dart';
import '../../../../core/services/storage_test_service.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../update/presentation/providers/backup_monitoring_provider.dart';
import '../../../update/presentation/providers/update_provider.dart';
import '../widgets/backup_dashboard_cards.dart';
import '../widgets/backup_notification_presenter.dart';

class StorageScreen extends ConsumerStatefulWidget {
  const StorageScreen({super.key});

  @override
  ConsumerState<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends ConsumerState<StorageScreen> {
  StorageTestResult? _lastTest;
  BackupRetentionSettings _retention = const BackupRetentionSettings();
  AutomaticBackupSchedule _autoBackupSchedule = AutomaticBackupSchedule.disabled;
  DateTime? _autoBackupLastRun;
  bool _loadingTest = false;
  bool _loadingCleanup = false;
  bool _loadingRetention = true;
  bool _creatingBackup = false;

  @override
  void initState() {
    super.initState();
    _loadInitialState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        BackupNotificationPresenter.showPendingIfAny(context);
      }
    });
  }

  Future<void> _loadInitialState() async {
    final lastTest = await StorageTestService.instance.loadLastTest();
    final retention = await BackupRetentionService.instance.loadSettings();
    final schedule = await AutomaticBackupService.instance.loadSchedule();
    final lastAutoRun = await AutomaticBackupService.instance.loadLastRunAt();
    if (!mounted) return;
    setState(() {
      _lastTest = lastTest;
      _retention = retention;
      _autoBackupSchedule = schedule;
      _autoBackupLastRun = lastAutoRun;
      _loadingRetention = false;
    });
  }

  Future<void> _runStorageTest() async {
    setState(() => _loadingTest = true);
    try {
      final result = await StorageTestService.instance.runTest();
      if (!mounted) return;
      setState(() => _lastTest = result);
      invalidateBackupMonitoring(ref);
      await BackupEventLogService.instance.record(
        type: BackupEventType.storageTest,
        title: result.allPassed ? 'Storage Test Passed' : 'Storage Test Issues',
        success: result.allPassed,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.allPassed
                ? 'Storage test passed.'
                : 'Storage test completed with issues.',
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Storage test failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loadingTest = false);
      }
    }
  }

  Future<void> _changeFolder() async {
    final ok = await DataStorageService.instance.changeStorageLocation();
    if (!mounted) return;
    if (ok) {
      invalidateBackupMonitoring(ref);
      final lastTest = await StorageTestService.instance.loadLastTest();
      if (!mounted) return;
      setState(() => _lastTest = lastTest);
      final location = DataStorageService.instance.friendlyLocationLabel();
      await BackupEventLogService.instance.record(
        type: BackupEventType.storageLocationChanged,
        title: 'Storage Location Updated',
        detail: location,
      );
      await BackupNotificationPresenter.queueStorageChanged(location);
      await BackupNotificationPresenter.showStorageChanged(context, location: location);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not change storage folder.')),
      );
    }
  }

  Future<void> _saveRetention(BackupRetentionSettings settings) async {
    await BackupRetentionService.instance.saveSettings(settings);
    if (mounted) {
      setState(() => _retention = settings);
    }
  }

  Future<void> _saveAutoBackupSchedule(AutomaticBackupSchedule schedule) async {
    await AutomaticBackupService.instance.saveSchedule(schedule);
    if (mounted) {
      setState(() => _autoBackupSchedule = schedule);
    }
  }

  Future<void> _cleanOldBackups() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clean Old Backups'),
        content: const Text(
          'This removes old database backups from TubigTrack/Backups '
          'according to your retention settings. Emergency recovery backups '
          'are not affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clean'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _loadingCleanup = true);
    try {
      final result = await BackupRetentionService.instance.cleanOldBackups();
      if (!mounted) return;
      invalidateBackupMonitoring(ref);
      if (_lastTest != null) {
        final refreshed = await StorageTestService.instance.runTest();
        if (!mounted) return;
        setState(() => _lastTest = refreshed);
      }
      await BackupEventLogService.instance.record(
        type: BackupEventType.backupCleanup,
        title: 'Old Backups Cleaned',
        detail: 'Removed ${result.deletedCount} backup(s)',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.deletedCount == 0
                ? 'No backups matched your retention rules.'
                : 'Removed ${result.deletedCount} old backup(s).',
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cleanup failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loadingCleanup = false);
      }
    }
  }

  Future<void> _createBackup() async {
    setState(() => _creatingBackup = true);
    try {
      final result =
          await ref.read(backupRepositoryProvider).createVerifiedManualBackup();
      await BackupEventLogService.instance.record(
        type: BackupEventType.manualBackup,
        title: result.verification.passed
            ? 'Manual Backup'
            : 'Manual Backup (Verification Failed)',
        success: result.verification.passed,
        relatedPath: result.path,
      );
      if (!result.verification.passed) {
        await BackupEventLogService.instance.record(
          type: BackupEventType.verification,
          title: 'Backup Verification Failed',
          success: false,
          relatedPath: result.path,
        );
      }
      invalidateBackupMonitoring(ref);
      if (!mounted) return;
      if (result.verification.passed) {
        await BackupNotificationPresenter.showManualBackupSuccess(context, result);
      } else {
        await BackupNotificationPresenter.showVerificationFailed(
          context,
          backupPath: result.path,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _creatingBackup = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(storageSummaryProvider);
    final dashboardAsync = ref.watch(backupDashboardProvider);
    final storage = DataStorageService.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Storage'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              invalidateBackupMonitoring(ref);
              _loadInitialState();
            },
          ),
        ],
      ),
      body: summaryAsync.when(
        data: (summary) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            dashboardAsync.when(
              data: (dashboard) => Column(
                children: [
                  BackupDashboardHeroCard(
                    snapshot: dashboard,
                    creatingBackup: _creatingBackup,
                    onCreateBackup: _createBackup,
                    onRecoveryCenter: () => context.push('/recovery-center'),
                    onRunStorageTest: _runStorageTest,
                  ),
                  const SizedBox(height: 16),
                  RecoveryReadinessCard(report: dashboard.readiness),
                  const SizedBox(height: 16),
                ],
              ),
              loading: () => const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: LinearProgressIndicator(),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),
            _StorageStatusCard(
              isPublicStorage: summary.isPublicStorage,
              locationLabel: summary.locationLabel,
              onChangeFolder: _changeFolder,
              onChoosePublicFolder: _changeFolder,
            ),
            const SizedBox(height: 16),
            _StorageTestCard(
              result: _lastTest,
              loading: _loadingTest,
              onRunTest: _runStorageTest,
            ),
            const SizedBox(height: 16),
            _AutomaticBackupCard(
              schedule: _autoBackupSchedule,
              lastRunAt: _autoBackupLastRun,
              keepLastLabel: _keepLastLabel(_retention),
              loading: _loadingRetention,
              onScheduleChanged: _saveAutoBackupSchedule,
            ),
            const SizedBox(height: 16),
            _StorageManagementCard(
              settings: _retention,
              loading: _loadingRetention || _loadingCleanup,
              onKeepCountChanged: (value) =>
                  _saveRetention(_retention.copyWith(keepCount: value)),
              onMaxAgeChanged: (value) =>
                  _saveRetention(_retention.copyWith(maxAge: value)),
              onClean: _cleanOldBackups,
            ),
            const SizedBox(height: 16),
            _UsageSummaryCard(
              totalBytes: storage.formatBytes(summary.totalBytes),
              backupCount: summary.backupCount,
              archiveCount: summary.archiveCount,
              csvCount: summary.csvCount,
              reportCount: summary.reportCount,
            ),
            const SizedBox(height: 16),
            _FolderTile(
              icon: Icons.backup_outlined,
              title: 'Backups',
              path: summary.backupsPath,
              count: summary.backupCount,
              onOpen: () => _openFolder(context, summary.backupsPath),
              onShare: () => _shareFolder(summary.backupsPath),
              onBrowse: () => context.push('/recovery-center'),
            ),
            _FolderTile(
              icon: Icons.archive_outlined,
              title: 'Archives',
              path: summary.archivesPath,
              count: summary.archiveCount,
              onOpen: () => _openFolder(context, summary.archivesPath),
              onShare: () => _shareFolder(summary.archivesPath),
              onBrowse: () => context.push('/recovery-center'),
            ),
            _FolderTile(
              icon: Icons.table_chart_outlined,
              title: 'CSV Exports',
              path: summary.csvPath,
              count: summary.csvCount,
              onOpen: () => _openFolder(context, summary.csvPath),
              onShare: () => _shareFolder(summary.csvPath),
              onBrowse: () => context.push('/recovery-center'),
            ),
            _FolderTile(
              icon: Icons.description_outlined,
              title: 'Reports',
              path: summary.reportsPath,
              count: summary.reportCount,
              onOpen: () => _openFolder(context, summary.reportsPath),
              onShare: () => _shareFolder(summary.reportsPath),
              onBrowse: () => context.push('/recovery-center'),
            ),
            _FolderTile(
              icon: Icons.emergency_outlined,
              title: 'Recovery',
              path: summary.recoveryPath,
              count: summary.recoveryCount,
              onOpen: () => _openFolder(context, summary.recoveryPath),
              onShare: () => _shareFolder(summary.recoveryPath),
              onBrowse: () => context.push('/recovery-center'),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Future<void> _openFolder(BuildContext context, String path) async {
    try {
      await openStoragePath(path);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    }
  }

  Future<void> _shareFolder(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) return;

    final files = dir
        .listSync()
        .whereType<File>()
        .where(
          (f) =>
              f.path.endsWith('.db') ||
              f.path.endsWith('.zip') ||
              f.path.endsWith('.csv') ||
              f.path.endsWith('.pdf') ||
              f.path.endsWith('.xlsx'),
        )
        .map((f) => XFile(f.path))
        .toList();

    if (files.isEmpty) return;
    await Share.shareXFiles(
      files,
      text: 'TubigTrack — ${DataStorageService.instance.displayPath(path)}',
    );
  }
}

extension on BackupRetentionSettings {
  BackupRetentionSettings copyWith({
    BackupKeepCount? keepCount,
    BackupMaxAge? maxAge,
  }) {
    return BackupRetentionSettings(
      keepCount: keepCount ?? this.keepCount,
      maxAge: maxAge ?? this.maxAge,
    );
  }
}

String _keepLastLabel(BackupRetentionSettings settings) {
  final maxCount = settings.keepCount.maxCount;
  if (maxCount == null) return 'Unlimited backups';
  return '$maxCount backups';
}

class _StorageStatusCard extends StatelessWidget {
  final bool isPublicStorage;
  final String locationLabel;
  final VoidCallback onChangeFolder;
  final VoidCallback onChoosePublicFolder;

  const _StorageStatusCard({
    required this.isPublicStorage,
    required this.locationLabel,
    required this.onChangeFolder,
    required this.onChoosePublicFolder,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor =
        isPublicStorage ? Colors.green.shade700 : Colors.amber.shade800;
    final statusIcon = isPublicStorage ? '🟢' : '🟡';
    final statusTitle =
        isPublicStorage ? 'Public Storage' : 'Private Storage';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Storage Status',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(statusIcon, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusTitle,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Location:',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      Text(
                        locationLabel,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isPublicStorage
                            ? 'Accessible from the Files app.'
                            : 'Using app-private storage because public storage '
                                'is unavailable.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: onChangeFolder,
                  icon: const Icon(Icons.folder_open_outlined, size: 18),
                  label: const Text('Change Folder'),
                ),
                if (!isPublicStorage)
                  OutlinedButton(
                    onPressed: onChoosePublicFolder,
                    child: const Text('Choose Public Folder'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StorageTestCard extends StatelessWidget {
  final StorageTestResult? result;
  final bool loading;
  final VoidCallback onRunTest;

  const _StorageTestCard({
    required this.result,
    required this.loading,
    required this.onRunTest,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Storage Test',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            if (result != null) ...[
              const SizedBox(height: 4),
              Text(
                'Current Location: ${result!.locationLabel}',
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),
            ],
            const SizedBox(height: 12),
            if (result == null)
              Text(
                'Run a test to verify read/write access and folder health.',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              )
            else ...[
              _TestRow('Write Permission', result!.writePermission),
              _TestRow('Read Permission', result!.readPermission),
              _TestRow('Folder Exists', result!.folderExists),
              _TestRow(
                '${result!.backupCount} Backups Found',
                result!.readPermission && result!.folderExists,
              ),
              _TestRow('Reports Folder Accessible', result!.reportsAccessible),
              _TestRow('CSV Folder Accessible', result!.csvAccessible),
              const SizedBox(height: 8),
              Text(
                'Last Tested: ${DateFormatter.format(result!.testedAt)}',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: loading ? null : onRunTest,
              icon: loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.play_arrow_outlined, size: 18),
              label: Text(loading ? 'Testing…' : 'Run Storage Test'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TestRow extends StatelessWidget {
  final String label;
  final bool passed;

  const _TestRow(this.label, this.passed);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            passed ? Icons.check_circle : Icons.cancel,
            size: 18,
            color: passed ? Colors.green.shade700 : Colors.red.shade700,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }
}

class _AutomaticBackupCard extends StatelessWidget {
  final AutomaticBackupSchedule schedule;
  final DateTime? lastRunAt;
  final String keepLastLabel;
  final bool loading;
  final ValueChanged<AutomaticBackupSchedule> onScheduleChanged;

  const _AutomaticBackupCard({
    required this.schedule,
    required this.lastRunAt,
    required this.keepLastLabel,
    required this.loading,
    required this.onScheduleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Automatic Backup',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Offline-first protection with scheduled backups to TubigTrack/Backups.',
              style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.4),
            ),
            const SizedBox(height: 12),
            RadioListTile<AutomaticBackupSchedule>(
              title: const Text('Disabled'),
              value: AutomaticBackupSchedule.disabled,
              groupValue: schedule,
              onChanged: loading
                  ? null
                  : (value) {
                      if (value != null) onScheduleChanged(value);
                    },
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
            RadioListTile<AutomaticBackupSchedule>(
              title: const Text('Daily'),
              value: AutomaticBackupSchedule.daily,
              groupValue: schedule,
              onChanged: loading
                  ? null
                  : (value) {
                      if (value != null) onScheduleChanged(value);
                    },
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
            RadioListTile<AutomaticBackupSchedule>(
              title: const Text('Weekly'),
              value: AutomaticBackupSchedule.weekly,
              groupValue: schedule,
              onChanged: loading
                  ? null
                  : (value) {
                      if (value != null) onScheduleChanged(value);
                    },
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
            RadioListTile<AutomaticBackupSchedule>(
              title: const Text('Before App Updates'),
              value: AutomaticBackupSchedule.beforeAppUpdates,
              groupValue: schedule,
              onChanged: loading
                  ? null
                  : (value) {
                      if (value != null) onScheduleChanged(value);
                    },
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),
            Text(
              'Keep last: $keepLastLabel',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            Text(
              'Adjust retention in Storage Management below.',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            if (lastRunAt != null) ...[
              const SizedBox(height: 8),
              Text(
                'Last automatic backup: ${DateFormatter.format(lastRunAt!)}',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StorageManagementCard extends StatelessWidget {
  final BackupRetentionSettings settings;
  final bool loading;
  final ValueChanged<BackupKeepCount> onKeepCountChanged;
  final ValueChanged<BackupMaxAge> onMaxAgeChanged;
  final VoidCallback onClean;

  const _StorageManagementCard({
    required this.settings,
    required this.loading,
    required this.onKeepCountChanged,
    required this.onMaxAgeChanged,
    required this.onClean,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Storage Management',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Keep only the last:',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            RadioListTile<BackupKeepCount>(
              title: const Text('10 backups'),
              value: BackupKeepCount.ten,
              groupValue: settings.keepCount,
              onChanged: loading
                  ? null
                  : (value) {
                      if (value != null) onKeepCountChanged(value);
                    },
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
            RadioListTile<BackupKeepCount>(
              title: const Text('20 backups'),
              value: BackupKeepCount.twenty,
              groupValue: settings.keepCount,
              onChanged: loading
                  ? null
                  : (value) {
                      if (value != null) onKeepCountChanged(value);
                    },
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
            RadioListTile<BackupKeepCount>(
              title: const Text('Unlimited'),
              value: BackupKeepCount.unlimited,
              groupValue: settings.keepCount,
              onChanged: loading
                  ? null
                  : (value) {
                      if (value != null) onKeepCountChanged(value);
                    },
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),
            Text(
              'Delete backups older than:',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            RadioListTile<BackupMaxAge>(
              title: const Text('30 days'),
              value: BackupMaxAge.days30,
              groupValue: settings.maxAge,
              onChanged: loading
                  ? null
                  : (value) {
                      if (value != null) onMaxAgeChanged(value);
                    },
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
            RadioListTile<BackupMaxAge>(
              title: const Text('90 days'),
              value: BackupMaxAge.days90,
              groupValue: settings.maxAge,
              onChanged: loading
                  ? null
                  : (value) {
                      if (value != null) onMaxAgeChanged(value);
                    },
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
            RadioListTile<BackupMaxAge>(
              title: const Text('Never'),
              value: BackupMaxAge.never,
              groupValue: settings.maxAge,
              onChanged: loading
                  ? null
                  : (value) {
                      if (value != null) onMaxAgeChanged(value);
                    },
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: loading ? null : onClean,
              icon: loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cleaning_services_outlined, size: 18),
              label: const Text('Clean Old Backups'),
            ),
          ],
        ),
      ),
    );
  }
}

class _UsageSummaryCard extends StatelessWidget {
  final String totalBytes;
  final int backupCount;
  final int archiveCount;
  final int csvCount;
  final int reportCount;

  const _UsageSummaryCard({
    required this.totalBytes,
    required this.backupCount,
    required this.archiveCount,
    required this.csvCount,
    required this.reportCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Usage',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text('Total used: $totalBytes'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _Chip(label: '$backupCount backups'),
                _Chip(label: '$archiveCount archives'),
                _Chip(label: '$csvCount CSV files'),
                _Chip(label: '$reportCount reports'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;

  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}

class _FolderTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String path;
  final int count;
  final VoidCallback onOpen;
  final VoidCallback onShare;
  final VoidCallback onBrowse;

  const _FolderTile({
    required this.icon,
    required this.title,
    required this.path,
    required this.count,
    required this.onOpen,
    required this.onShare,
    required this.onBrowse,
  });

  @override
  Widget build(BuildContext context) {
    final display = DataStorageService.instance.displayPath(path);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text('$count files · $display'),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (action) {
            switch (action) {
              case 'open':
                onOpen();
              case 'share':
                onShare();
              case 'browse':
                onBrowse();
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'open', child: Text('Open in Files')),
            PopupMenuItem(value: 'share', child: Text('Share Files')),
            PopupMenuItem(value: 'browse', child: Text('Recovery Center')),
          ],
        ),
      ),
    );
  }
}
