import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/services/data_storage_service.dart';
import '../../../../core/services/pdf_export_actions.dart';

/// Shows success dialog after CSV export with Open Folder / Share / Done actions.
Future<void> showCsvExportSuccessDialog(
  BuildContext context,
  List<String> exportedPaths,
) async {
  final csvDir = await DataStorageService.instance.csvDirectory();
  if (!context.mounted) return;
  final displayPath = DataStorageService.instance.displayPath(csvDir.path);

  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('CSV Exported Successfully'),
      content: Text(
        '${exportedPaths.length} files saved to:\n\n$displayPath',
      ),
      actions: [
        TextButton(
          onPressed: () async {
            try {
              if (exportedPaths.isNotEmpty) {
                await openStoragePath(exportedPaths.first);
              } else {
                await openStoragePath(csvDir.path);
              }
            } catch (_) {
              if (ctx.mounted) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(content: Text('Folder: $displayPath')),
                );
              }
            }
          },
          child: const Text('Open Folder'),
        ),
        TextButton(
          onPressed: () async {
            await Share.shareXFiles(
              exportedPaths.map((p) => XFile(p)).toList(),
              text: 'TubigTrack CSV Export',
            );
          },
          child: const Text('Share'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Done'),
        ),
      ],
    ),
  );
}

/// Shows success dialog after database backup.
Future<void> showBackupSuccessDialog(BuildContext context, String backupPath) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Database Backed Up Successfully'),
      content: Text('Saved to:\n\nTubigTrack/Backups'),
      actions: [
        TextButton(
          onPressed: () => Share.shareXFiles(
            [XFile(backupPath)],
            text: 'TubigTrack Database Backup',
          ),
          child: const Text('Share'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(ctx);
            context.push('/recovery-center');
          },
          child: const Text('Recovery Center'),
        ),
      ],
    ),
  );
}
