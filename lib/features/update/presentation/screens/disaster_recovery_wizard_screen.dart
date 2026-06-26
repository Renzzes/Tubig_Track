import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/services/business_package_export_service.dart';
import '../../../../core/services/data_storage_service.dart';
import '../../../settings/presentation/widgets/backup_restore_flow.dart';
import '../providers/backup_monitoring_provider.dart';

enum DisasterScenario {
  changedPhones,
  deletedData,
  corruptedDatabase,
  haveBackupFile,
  viewOldBackup,
}

class DisasterRecoveryWizard extends ConsumerStatefulWidget {
  const DisasterRecoveryWizard({super.key});

  @override
  ConsumerState<DisasterRecoveryWizard> createState() =>
      _DisasterRecoveryWizardState();
}

class _DisasterRecoveryWizardState
    extends ConsumerState<DisasterRecoveryWizard> {
  DisasterScenario? _selected;
  bool _working = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recover My Business')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'What happened?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          RadioListTile<DisasterScenario>(
            title: const Text('I changed phones'),
            value: DisasterScenario.changedPhones,
            groupValue: _selected,
            onChanged: (value) => setState(() => _selected = value),
          ),
          RadioListTile<DisasterScenario>(
            title: const Text('I accidentally deleted my data'),
            value: DisasterScenario.deletedData,
            groupValue: _selected,
            onChanged: (value) => setState(() => _selected = value),
          ),
          RadioListTile<DisasterScenario>(
            title: const Text('My database is corrupted'),
            value: DisasterScenario.corruptedDatabase,
            groupValue: _selected,
            onChanged: (value) => setState(() => _selected = value),
          ),
          RadioListTile<DisasterScenario>(
            title: const Text('I have a backup file'),
            value: DisasterScenario.haveBackupFile,
            groupValue: _selected,
            onChanged: (value) => setState(() => _selected = value),
          ),
          RadioListTile<DisasterScenario>(
            title: const Text('I only want to view an old backup'),
            value: DisasterScenario.viewOldBackup,
            groupValue: _selected,
            onChanged: (value) => setState(() => _selected = value),
          ),
          const SizedBox(height: 16),
          if (_selected != null) _RecommendationCard(scenario: _selected!),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _selected == null || _working ? null : _continue,
            child: _working
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Future<void> _continue() async {
    setState(() => _working = true);
    try {
      switch (_selected!) {
        case DisasterScenario.changedPhones:
          await _exportPackage();
        case DisasterScenario.deletedData:
        case DisasterScenario.corruptedDatabase:
          if (!mounted) return;
          context.push('/settings');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Open Settings → Restore Database'),
            ),
          );
        case DisasterScenario.haveBackupFile:
          await _pickAndRestore();
        case DisasterScenario.viewOldBackup:
          await _pickReadOnly();
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _exportPackage() async {
    final db = ref.read(databaseProvider);
    final path = await BusinessPackageExportService.instance
        .exportBusinessPackage(db: db);
    invalidateBackupMonitoring(ref);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Business package exported to ${DataStorageService.instance.displayPath(path)}',
        ),
      ),
    );
    Navigator.pop(context);
  }

  Future<void> _pickAndRestore() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['db'],
    );
    if (picked == null || picked.files.single.path == null || !mounted) return;
    await runBackupRestoreFlow(context, ref, picked.files.single.path!);
  }

  Future<void> _pickReadOnly() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['db'],
    );
    if (picked == null || picked.files.single.path == null || !mounted) return;
    context.push('/read-only-recovery', extra: picked.files.single.path);
  }
}

class _RecommendationCard extends StatelessWidget {
  final DisasterScenario scenario;

  const _RecommendationCard({required this.scenario});

  @override
  Widget build(BuildContext context) {
    final (title, body) = switch (scenario) {
      DisasterScenario.changedPhones => (
          'Recommended: Export Business Package',
          'Create a full package on your old phone, transfer the ZIP, then import the database on the new phone.',
        ),
      DisasterScenario.deletedData => (
          'Recommended: Restore Database',
          'Use a recent verified backup from TubigTrack/Backups or Recovery Center.',
        ),
      DisasterScenario.corruptedDatabase => (
          'Recommended: Restore Database',
          'Restore from the latest verified backup. TubigTrack will migrate older schemas automatically.',
        ),
      DisasterScenario.haveBackupFile => (
          'Recommended: Recovery Center',
          'Select your .db backup file and TubigTrack will verify compatibility before restoring.',
        ),
      DisasterScenario.viewOldBackup => (
          'Recommended: Read-Only Recovery',
          'Browse backup contents without changing your live database.',
        ),
    };

    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(body),
          ],
        ),
      ),
    );
  }
}
