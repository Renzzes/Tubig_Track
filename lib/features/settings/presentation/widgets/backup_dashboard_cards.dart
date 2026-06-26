import 'package:flutter/material.dart';

import '../../../../core/services/recovery_readiness_service.dart';

class BackupDashboardHeroCard extends StatelessWidget {
  final BackupDashboardSnapshot snapshot;
  final bool creatingBackup;
  final VoidCallback onCreateBackup;
  final VoidCallback onRecoveryCenter;
  final VoidCallback onRunStorageTest;

  const BackupDashboardHeroCard({
    super.key,
    required this.snapshot,
    required this.creatingBackup,
    required this.onCreateBackup,
    required this.onRecoveryCenter,
    required this.onRunStorageTest,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.35),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Backup Status',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 16),
            _StatusRow(
              icon: Icons.check_circle,
              iconColor: snapshot.lastBackupAt != null
                  ? Colors.green.shade700
                  : Colors.grey,
              label: 'Last Backup',
              value: snapshot.lastBackupLabel,
            ),
            _StatusRow(
              icon: Icons.schedule,
              label: 'Automatic Backup',
              value: snapshot.scheduleLabel,
            ),
            _StatusRow(
              icon: snapshot.latestBackupVerified
                  ? Icons.verified_outlined
                  : Icons.warning_amber_outlined,
              iconColor: snapshot.latestBackupVerified
                  ? Colors.green.shade700
                  : Colors.orange.shade800,
              label: 'Latest Backup',
              value: snapshot.latestBackupVerified ? 'Verified' : 'Not Verified',
            ),
            _StatusRow(
              icon: Icons.folder_outlined,
              label: 'Storage',
              value: snapshot.storageLocation,
            ),
            _StatusRow(
              icon: Icons.backup_outlined,
              label: 'Backups Stored',
              value: '${snapshot.backupsStored}',
            ),
            _StatusRow(
              icon: Icons.sd_storage_outlined,
              label: 'Storage Used',
              value: snapshot.storageUsed,
            ),
            const Divider(height: 28),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: creatingBackup ? null : onCreateBackup,
                  icon: creatingBackup
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.backup_outlined, size: 18),
                  label: const Text('Create Backup'),
                ),
                OutlinedButton(
                  onPressed: onRecoveryCenter,
                  child: const Text('Recovery Center'),
                ),
                OutlinedButton(
                  onPressed: onRunStorageTest,
                  child: const Text('Run Storage Test'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RecoveryReadinessCard extends StatelessWidget {
  final RecoveryReadinessReport report;

  const RecoveryReadinessCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (report.overallStatus) {
      RecoveryOverallStatus.excellent => Colors.green.shade700,
      RecoveryOverallStatus.good => Colors.blue.shade700,
      RecoveryOverallStatus.needsAttention => Colors.orange.shade800,
      RecoveryOverallStatus.critical => Colors.red.shade700,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recovery Readiness',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            _CheckRow(
              'Automatic Backup Enabled',
              report.automaticBackupEnabled,
            ),
            _CheckRow('Latest Backup Verified', report.latestBackupVerified),
            _CheckRow('Restore Tested', report.restoreTested),
            _CheckRow('Storage Healthy', report.storageHealthy),
            const SizedBox(height: 12),
            Text(
              'Overall Status',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 4),
            Text(
              report.overallLabel,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: statusColor,
              ),
            ),
            if (report.issues.isNotEmpty) ...[
              const SizedBox(height: 12),
              for (final issue in report.issues.take(2)) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        size: 18, color: Colors.orange.shade800),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(issue.message,
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text(
                            'Recommendation: ${issue.recommendation}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String label;
  final String value;

  const _StatusRow({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: iconColor ?? Colors.grey.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelMedium),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  final String label;
  final bool passed;

  const _CheckRow(this.label, this.passed);

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
