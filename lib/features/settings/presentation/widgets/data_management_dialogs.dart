import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/services/backup_verification_service.dart';
import '../../../../core/services/data_storage_service.dart';
import '../../../../core/services/storage_folder_opener.dart';

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
            final csvDir = await DataStorageService.instance.csvDirectory();
            try {
              await openStoragePath(csvDir.path);
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

/// Shows success dialog after database backup with integrity check results.
Future<void> showBackupSuccessDialog(
  BuildContext context,
  VerifiedBackupResult result,
) {
  final verification = result.verification;
  final passed = verification.passed;

  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Row(
        children: [
          Icon(
            passed ? Icons.check_circle : Icons.warning_amber_rounded,
            color: passed ? Colors.green.shade700 : Colors.orange.shade800,
          ),
          const SizedBox(width: 8),
          const Expanded(child: Text('Backup Created')),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Saved to:\n\n${DataStorageService.instance.displayRootPath()}/Backups',
          ),
          const SizedBox(height: 16),
          Text(
            'Integrity Check:',
            style: Theme.of(ctx).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            passed ? 'Passed' : 'Failed',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: passed ? Colors.green.shade700 : Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 8),
          if (verification.databaseOpened)
            const Text('Database opened successfully.')
          else
            Text(
              verification.failureReason ?? 'Could not open backup database.',
            ),
          if (passed) ...[
            const SizedBox(height: 4),
            const Text('Ready for restore.'),
          ] else if (verification.failureReason != null) ...[
            const SizedBox(height: 4),
            Text(
              verification.failureReason!,
              style: TextStyle(color: Colors.red.shade700, fontSize: 13),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Share.shareXFiles(
            [XFile(result.path)],
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
