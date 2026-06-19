import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_refresh.dart';
import '../providers/update_provider.dart';

/// Checks for missing database on startup and offers restore from pre-update backup.
class PostUpdateRecoveryGate extends ConsumerStatefulWidget {
  final Widget child;

  const PostUpdateRecoveryGate({super.key, required this.child});

  @override
  ConsumerState<PostUpdateRecoveryGate> createState() =>
      _PostUpdateRecoveryGateState();
}

class _PostUpdateRecoveryGateState extends ConsumerState<PostUpdateRecoveryGate> {
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkDatabase());
  }

  Future<void> _checkDatabase() async {
    if (_checked) return;
    _checked = true;

    final backupRepo = ref.read(backupRepositoryProvider);
    final exists = await backupRepo.databaseExists();
    if (exists || !mounted) return;

    final backup = await backupRepo.findLatestPreUpdateBackup();
    if (backup == null || !mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Backup Found'),
        content: const Text(
          'Your database was not found after the update.\n\n'
          'Restore from the most recent pre-update backup?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Skip'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await backupRepo.restoreBackup(backup.path);
                invalidateAllDataProviders(ref);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Backup restored successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Restore failed: $e')),
                  );
                }
              }
            },
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
