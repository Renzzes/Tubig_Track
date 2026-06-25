import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

import '../../../../core/services/data_storage_service.dart';
import '../../../../core/services/pdf_export_actions.dart';
import '../../../settings/presentation/widgets/backup_restore_flow.dart';
import '../../domain/entities/recovery_file_info.dart';
import '../providers/update_provider.dart';

class RecoveryCenterScreen extends ConsumerWidget {
  const RecoveryCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filesAsync = ref.watch(recoveryFilesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recovery Center'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(recoveryFilesProvider);
              ref.invalidate(availableBackupsProvider);
            },
          ),
        ],
      ),
      body: filesAsync.when(
        data: (files) {
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

          final grouped = _groupByCategory(files);

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              for (final entry in grouped.entries) ...[
                _SectionTitle(_sectionLabel(entry.key)),
                ...entry.value.map(
                  (file) => _RecoveryFileTile(file: file),
                ),
                const SizedBox(height: 8),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Map<RecoveryFileCategory, List<RecoveryFileInfo>> _groupByCategory(
    List<RecoveryFileInfo> files,
  ) {
    final map = <RecoveryFileCategory, List<RecoveryFileInfo>>{};
    for (final file in files) {
      map.putIfAbsent(file.category, () => []).add(file);
    }
    return map;
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

class _RecoveryFileTile extends ConsumerWidget {
  final RecoveryFileInfo file;

  const _RecoveryFileTile({required this.file});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = DataStorageService.instance;
    final dateFormat = DateFormat('MMM d, yyyy');

    final subtitleLines = <String>[
      file.databaseSize ?? storage.formatBytes(file.sizeBytes),
      dateFormat.format(file.modifiedAt),
    ];
    if (file.appVersion != null) {
      subtitleLines.add('v${file.appVersion} · Schema ${file.databaseVersion ?? '?'}');
    }
    if (file.customers != null && file.deliveries != null) {
      subtitleLines.add('${file.customers} customers · ${file.deliveries} deliveries');
    }

    return ListTile(
      leading: Icon(_iconFor(file)),
      title: Text(file.fileName, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(subtitleLines.join('\n')),
      isThreeLine: true,
      onTap: () => _showMetadata(context, ref),
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
    switch (action) {
      case 'restore':
        await _restore(context, ref);
      case 'share':
        await Share.shareXFiles([XFile(file.path)], text: file.fileName);
      case 'open':
        try {
          await openStoragePath(file.path);
        } catch (_) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  DataStorageService.instance.displayPath(
                    p.dirname(file.path),
                  ),
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
        await showBackupDetailsDialog(
          context,
          ref,
          backupPath: file.path,
        );
    }
  }

  Future<void> _showMetadata(BuildContext context, WidgetRef ref) async {
    final storage = DataStorageService.instance;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(file.categoryLabel),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MetaRow('File', file.fileName),
            _MetaRow('Size', storage.formatBytes(file.sizeBytes)),
            _MetaRow(
              'Created',
              DateFormat('MMMM d, yyyy h:mm a').format(file.modifiedAt),
            ),
            if (file.appVersion != null)
              _MetaRow('App Version', file.appVersion!),
            if (file.customers != null)
              _MetaRow('Customers', file.customers.toString()),
            if (file.deliveries != null)
              _MetaRow('Deliveries', file.deliveries.toString()),
            if (file.inventoryTransactions != null)
              _MetaRow(
                'Inventory Transactions',
                file.inventoryTransactions.toString(),
              ),
            _MetaRow(
              'Database Size',
              file.databaseSize ?? storage.formatBytes(file.sizeBytes),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    await runBackupRestoreFlow(context, ref, file.path);
  }

  Future<void> _rename(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(text: file.fileName);
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
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (newName == null || newName.isEmpty || newName == file.fileName) return;

    try {
      await ref.read(backupRepositoryProvider).renameBackup(file.path, newName);
      ref.invalidate(recoveryFilesProvider);
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
        content: Text('Delete ${file.fileName} permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
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
      await ref.read(backupRepositoryProvider).deleteBackup(file.path);
      ref.invalidate(recoveryFilesProvider);
      ref.invalidate(storageSummaryProvider);
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

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;

  const _MetaRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
