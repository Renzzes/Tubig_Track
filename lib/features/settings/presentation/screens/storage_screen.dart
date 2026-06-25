import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/services/data_storage_service.dart';
import '../../../../core/services/pdf_export_actions.dart';
import '../../../update/presentation/providers/update_provider.dart';

class StorageScreen extends ConsumerWidget {
  const StorageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(storageSummaryProvider);
    final storage = DataStorageService.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Storage'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(storageSummaryProvider),
          ),
        ],
      ),
      body: summaryAsync.when(
        data: (summary) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SummaryCard(
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
              onOpen: () => _openFolder(summary.backupsPath),
              onShare: () => _shareFolder(summary.backupsPath),
              onBrowse: () => context.push('/recovery-center'),
            ),
            _FolderTile(
              icon: Icons.archive_outlined,
              title: 'Archives',
              path: summary.archivesPath,
              count: summary.archiveCount,
              onOpen: () => _openFolder(summary.archivesPath),
              onShare: () => _shareFolder(summary.archivesPath),
              onBrowse: () => context.push('/recovery-center'),
            ),
            _FolderTile(
              icon: Icons.table_chart_outlined,
              title: 'CSV Exports',
              path: summary.csvPath,
              count: summary.csvCount,
              onOpen: () => _openFolder(summary.csvPath),
              onShare: () => _shareFolder(summary.csvPath),
              onBrowse: () => context.push('/recovery-center'),
            ),
            _FolderTile(
              icon: Icons.description_outlined,
              title: 'Reports',
              path: summary.reportsPath,
              count: summary.reportCount,
              onOpen: () => _openFolder(summary.reportsPath),
              onShare: () => _shareFolder(summary.reportsPath),
              onBrowse: () => context.push('/recovery-center'),
            ),
            _FolderTile(
              icon: Icons.emergency_outlined,
              title: 'Recovery',
              path: summary.recoveryPath,
              count: summary.recoveryCount,
              onOpen: () => _openFolder(summary.recoveryPath),
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

  Future<void> _openFolder(String path) async {
    try {
      await openStoragePath(path);
    } catch (_) {
      // Folder open may not be supported on all devices.
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

class _SummaryCard extends StatelessWidget {
  final String totalBytes;
  final int backupCount;
  final int archiveCount;
  final int csvCount;
  final int reportCount;

  const _SummaryCard({
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
              'TubigTrack Storage',
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
            const SizedBox(height: 8),
            Text(
              'All data is stored in your app\'s private internal storage under TubigTrack/.',
              style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.4),
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
            PopupMenuItem(value: 'open', child: Text('Open')),
            PopupMenuItem(value: 'share', child: Text('Share Files')),
            PopupMenuItem(value: 'browse', child: Text('Recovery Center')),
          ],
        ),
      ),
    );
  }
}
