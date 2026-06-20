import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/database_refresh.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/settings_provider.dart';

class ArchiveResetScreen extends ConsumerStatefulWidget {
  const ArchiveResetScreen({super.key});

  @override
  ConsumerState<ArchiveResetScreen> createState() =>
      _ArchiveResetScreenState();
}

class _ArchiveResetScreenState extends ConsumerState<ArchiveResetScreen> {
  bool _working = false;

  Future<void> _archiveAndReset() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Archive & Reset'),
        content: const Text(
          'This will create a full archive backup in TubigTrack/Archives/, '
          'then reset all operational data. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    setState(() => _working = true);
    try {
      final path = await ref.read(settingsRepositoryProvider).createArchive();
      await ref.read(settingsRepositoryProvider).factoryReset();
      invalidateAllDataProviders(ref);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Archive Complete'),
          content: Text(
            'Archive saved:\n${path.split('/').last}\n\n'
            'Operational data has been reset.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      if (mounted) context.go('/');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Archive failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Archive & Reset')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.archive_outlined, size: 56, color: Colors.blue[700]),
            const SizedBox(height: 16),
            const Text(
              'Start a New Business Cycle',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '1. Creates TubigTrack_Archive_YYYY.db in TubigTrack/Archives/\n'
              '2. Preserves your full business history in the archive\n'
              '3. Resets operational data for a fresh start\n\n'
              'App settings, cost per bottle, and notification preferences are preserved.',
              style: TextStyle(color: Colors.grey[700], height: 1.5),
            ),
            const Spacer(),
            FilledButton(
              onPressed: _working ? null : _archiveAndReset,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(48),
              ),
              child: _working
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Archive & Reset'),
            ),
          ],
        ),
      ),
    );
  }
}
