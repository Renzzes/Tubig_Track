import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

import '../../../../core/database/backup_metadata.dart';
import '../../../../core/services/backup_health_service.dart';
import '../../../../core/services/backup_verification_service.dart';
import '../../../../core/services/data_storage_service.dart';
import '../../presentation/providers/update_provider.dart';
import '../../presentation/widgets/backup_health_badge.dart';

Future<void> showBackupDetailsDialog(
  BuildContext context,
  WidgetRef ref, {
  required String backupPath,
}) async {
  if (!backupPath.toLowerCase().endsWith('.db')) {
    await _showGenericDetails(context, ref, backupPath);
    return;
  }

  final repo = ref.read(backupRepositoryProvider);
  final file = await repo.getFileMetadata(backupPath);
  if (file == null || !context.mounted) return;

  final verification = await BackupVerificationService.instance.verify(backupPath);
  final health = await BackupHealthService.instance.evaluate(
    backupPath: backupPath,
    repository: repo,
  );
  final compatibility = await repo.checkCompatibility(backupPath);
  if (!context.mounted) return;

  final storage = DataStorageService.instance;
  final dateFormat = DateFormat('MMMM d, yyyy h:mm a');

  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(p.basenameWithoutExtension(file.fileName)),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: BackupHealthBadge(health: health)),
            const SizedBox(height: 16),
            _DetailRow('Backup Name', file.fileName),
            _DetailRow('Created', dateFormat.format(file.modifiedAt)),
            if (file.appVersion != null)
              _DetailRow('App Version', file.appVersion!),
            if (file.databaseVersion != null)
              _DetailRow('Database Schema', file.databaseVersion.toString()),
            if (file.customers != null)
              _DetailRow('Customers', file.customers.toString()),
            if (file.deliveries != null)
              _DetailRow('Deliveries', file.deliveries.toString()),
            if (file.inventoryTransactions != null)
              _DetailRow(
                'Inventory Transactions',
                file.inventoryTransactions.toString(),
              ),
            _DetailRow(
              'Database Size',
              file.databaseSize ?? storage.formatBytes(file.sizeBytes),
            ),
            _DetailRow('Compatibility', _compatLabel(compatibility.status)),
            _DetailRow(
              'Verification Status',
              verification.passed ? 'Passed' : 'Failed',
            ),
            _DetailRow(
              'Storage Location',
              storage.displayPath(p.dirname(backupPath)),
            ),
          ],
        ),
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

Future<void> _showGenericDetails(
  BuildContext context,
  WidgetRef ref,
  String path,
) async {
  final file = await ref.read(backupRepositoryProvider).getFileMetadata(path);
  if (file == null || !context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(file.fileName),
      content: Text('${file.categoryLabel}\n${DataStorageService.instance.displayPath(path)}'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
      ],
    ),
  );
}

String _compatLabel(BackupCompatibilityStatus status) {
  switch (status) {
    case BackupCompatibilityStatus.compatible:
      return 'Compatible';
    case BackupCompatibilityStatus.migratable:
      return 'Migratable';
    case BackupCompatibilityStatus.unknown:
      return 'Unknown';
    case BackupCompatibilityStatus.unsupported:
      return 'Unsupported';
    case BackupCompatibilityStatus.newerThanApp:
      return 'Newer Than App';
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
