import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/database/database_refresh.dart';
import '../../domain/entities/backup_file_info.dart';
import '../providers/update_provider.dart';

class RecoveryCenterScreen extends ConsumerWidget {
  const RecoveryCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backupsAsync = ref.watch(availableBackupsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Recovery Center')),
      body: backupsAsync.when(
        data: (backups) {
          if (backups.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No backups found.\nBackups are saved to Documents/TubigTrack/Backups/',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: backups.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final backup = backups[index];
              return _BackupTile(backup: backup);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _BackupTile extends ConsumerWidget {
  final BackupFileInfo backup;

  const _BackupTile({required this.backup});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('MMMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    return ListTile(
      leading: Icon(
        backup.isPreUpdate ? Icons.system_update_alt : Icons.backup_outlined,
      ),
      title: Text(
        backup.isPreUpdate ? 'Pre-Update Backup' : 'Backup',
      ),
      subtitle: Text(
        '${dateFormat.format(backup.modifiedAt)}\n${timeFormat.format(backup.modifiedAt)}',
      ),
      isThreeLine: true,
      trailing: PopupMenuButton<String>(
        onSelected: (action) => _handleAction(context, ref, action),
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'restore', child: Text('Restore')),
          PopupMenuItem(value: 'export', child: Text('Export')),
          PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      ),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    String action,
  ) async {
    switch (action) {
      case 'restore':
        await _restore(context, ref);
      case 'export':
        await Share.shareXFiles(
          [XFile(backup.path)],
          text: 'TubigTrack Backup',
        );
      case 'delete':
        await _delete(context, ref);
    }
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore Backup'),
        content: const Text(
          'Restore this backup? Current data will be overwritten.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(backupRepositoryProvider).restoreBackup(backup.path);
      invalidateAllDataProviders(ref);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup restored successfully')),
        );
        context.go('/');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restore failed: $e')),
        );
      }
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Backup'),
        content: const Text('Delete this backup file permanently?'),
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
      await ref.read(backupRepositoryProvider).deleteBackup(backup.path);
      ref.invalidate(availableBackupsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup deleted')),
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
