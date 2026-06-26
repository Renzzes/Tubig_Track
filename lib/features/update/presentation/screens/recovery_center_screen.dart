import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/services/backup_event_log_service.dart';
import '../../../../core/services/backup_health_service.dart';
import '../../../../core/services/business_package_export_service.dart';
import '../../../../core/services/data_storage_service.dart';
import '../../../../core/services/storage_folder_opener.dart';
import '../../../settings/presentation/widgets/backup_restore_flow.dart';
import '../../domain/entities/recovery_file_info.dart';
import '../providers/backup_monitoring_provider.dart';
import '../providers/update_provider.dart';
import '../widgets/backup_details_dialog.dart';
import '../widgets/backup_health_badge.dart';
import '../widgets/backup_history_tab.dart';

class RecoveryCenterScreen extends ConsumerStatefulWidget {
  const RecoveryCenterScreen({super.key});

  @override
  ConsumerState<RecoveryCenterScreen> createState() =>
      _RecoveryCenterScreenState();
}

class _RecoveryCenterScreenState extends ConsumerState<RecoveryCenterScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _exportBusinessPackage() async {
    setState(() => _exporting = true);
    try {
      final db = ref.read(databaseProvider);
      final path = await BusinessPackageExportService.instance
          .exportBusinessPackage(db: db);
      await BackupEventLogService.instance.record(
        type: BackupEventType.archive,
        title: 'Business Package Exported',
        detail: p.basename(path),
        relatedPath: path,
      );
      invalidateBackupMonitoring(ref);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Exported ${DataStorageService.instance.displayPath(path)}',
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filesAsync = ref.watch(recoveryFilesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recovery Center'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Files'),
            Tab(text: 'History'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              invalidateBackupMonitoring(ref);
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          filesAsync.when(
            data: (files) => _FilesTab(files: files),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
          const BackupHistoryTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton.extended(
                  heroTag: 'recover',
                  onPressed: () => context.push('/disaster-recovery'),
                  icon: const Icon(Icons.medical_services_outlined),
                  label: const Text('Recover My Business'),
                ),
                const SizedBox(height: 12),
                FloatingActionButton.extended(
                  heroTag: 'export',
                  onPressed: _exporting ? null : _exportBusinessPackage,
                  icon: _exporting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.inventory_2_outlined),
                  label: const Text('Export Business Package'),
                ),
              ],
            )
          : null,
    );
  }
}

class _FilesTab extends StatelessWidget {
  final List<RecoveryFileInfo> files;

  const _FilesTab({required this.files});

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No files found.\n\nBackups, archives, CSV exports, and reports '
            'appear here after you create them.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final grouped = <RecoveryFileCategory, List<RecoveryFileInfo>>{};
    for (final file in files) {
      grouped.putIfAbsent(file.category, () => []).add(file);
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        for (final entry in grouped.entries) ...[
          _SectionTitle(_sectionLabel(entry.key)),
          ...entry.value.map((file) => _RecoveryFileTile(file: file)),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  String _sectionLabel(RecoveryFileCategory category) {
    switch (category) {
      case RecoveryFileCategory.databaseBackup:
        return 'Database Backups';
      case RecoveryFileCategory.archive:
        return 'Archives';
      case RecoveryFileCategory.csvExport:
        return 'CSV Exports';
      case RecoveryFileCategory.report:
        return 'Business Reports';
      case RecoveryFileCategory.emergencyRecovery:
        return 'Emergency Backups';
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _RecoveryFileTile extends ConsumerStatefulWidget {
  final RecoveryFileInfo file;

  const _RecoveryFileTile({required this.file});

  @override
  ConsumerState<_RecoveryFileTile> createState() => _RecoveryFileTileState();
}

class _RecoveryFileTileState extends ConsumerState<_RecoveryFileTile> {
  BackupHealthInfo? _health;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _loadHealth();
  }

  Future<void> _loadHealth() async {
    if (!widget.file.path.toLowerCase().endsWith('.db')) return;
    final health = await BackupHealthService.instance.evaluate(
      backupPath: widget.file.path,
      repository: ref.read(backupRepositoryProvider),
    );
    if (mounted) setState(() => _health = health);
  }

  @override
  Widget build(BuildContext context) {
    final storage = DataStorageService.instance;
    final dateFormat = DateFormat('MMM d, yyyy');
    final file = widget.file;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ExpansionTile(
        initiallyExpanded: _expanded,
        onExpansionChanged: (value) => setState(() => _expanded = value),
        leading: Icon(_iconFor(file)),
        title: Text(file.fileName, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              [
                file.databaseSize ?? storage.formatBytes(file.sizeBytes),
                dateFormat.format(file.modifiedAt),
              ].join(' · '),
            ),
            if (_health != null) ...[
              const SizedBox(height: 4),
              BackupHealthBadge(health: _health!, compact: true),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (action) => _handleAction(context, ref, action),
          itemBuilder: (_) => [
            if (file.canRestore)
              const PopupMenuItem(value: 'restore', child: Text('Restore')),
            const PopupMenuItem(value: 'share', child: Text('Share')),
            const PopupMenuItem(value: 'open', child: Text('Open Folder')),
            const PopupMenuItem(value: 'rename', child: Text('Rename')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
            const PopupMenuItem(value: 'metadata', child: Text('View Details')),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (file.appVersion != null)
                  Text('App Version: ${file.appVersion}'),
                if (file.databaseVersion != null)
                  Text('Schema: ${file.databaseVersion}'),
                if (file.customers != null && file.deliveries != null)
                  Text('${file.customers} customers · ${file.deliveries} deliveries'),
                if (_health != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: BackupHealthBadge(health: _health!),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(RecoveryFileInfo file) {
    switch (file.category) {
      case RecoveryFileCategory.databaseBackup:
        return file.isPreUpdate
            ? Icons.system_update_alt
            : Icons.backup_outlined;
      case RecoveryFileCategory.archive:
        return Icons.archive_outlined;
      case RecoveryFileCategory.csvExport:
        return Icons.table_chart_outlined;
      case RecoveryFileCategory.report:
        return Icons.description_outlined;
      case RecoveryFileCategory.emergencyRecovery:
        return Icons.emergency_outlined;
    }
  }

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    String action,
  ) async {
    final file = widget.file;
    switch (action) {
      case 'restore':
        await runBackupRestoreFlow(context, ref, file.path);
      case 'share':
        await Share.shareXFiles([XFile(file.path)], text: file.fileName);
      case 'open':
        try {
          await openStoragePath(p.dirname(file.path));
        } catch (_) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  DataStorageService.instance.displayPath(p.dirname(file.path)),
                ),
              ),
            );
          }
        }
      case 'rename':
        await _rename(context, ref);
      case 'delete':
        await _delete(context, ref);
      case 'metadata':
        await showBackupDetailsDialog(context, ref, backupPath: file.path);
    }
  }

  Future<void> _rename(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(text: widget.file.fileName);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'File name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (newName == null || newName.isEmpty || newName == widget.file.fileName) {
      return;
    }
    try {
      await ref.read(backupRepositoryProvider).renameBackup(widget.file.path, newName);
      invalidateBackupMonitoring(ref);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File renamed')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rename failed: $e')),
        );
      }
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete File'),
        content: Text('Delete ${widget.file.fileName} permanently?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(backupRepositoryProvider).deleteBackup(widget.file.path);
      invalidateBackupMonitoring(ref);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File deleted')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')),
        );
      }
    }
  }
}
