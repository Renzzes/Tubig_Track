import 'package:flutter/material.dart';

import '../../domain/entities/update_info.dart';

class UpdateDialog extends StatelessWidget {
  final UpdateInfo updateInfo;
  final String currentVersion;
  final VoidCallback onLater;
  final VoidCallback onUpdateNow;

  const UpdateDialog({
    super.key,
    required this.updateInfo,
    required this.currentVersion,
    required this.onLater,
    required this.onUpdateNow,
  });

  static Future<void> show(
    BuildContext context, {
    required UpdateInfo updateInfo,
    required String currentVersion,
    required VoidCallback onLater,
    required VoidCallback onUpdateNow,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: !updateInfo.mandatory,
      builder: (_) => UpdateDialog(
        updateInfo: updateInfo,
        currentVersion: currentVersion,
        onLater: onLater,
        onUpdateNow: onUpdateNow,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Icon(
        Icons.system_update_alt,
        size: 40,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: const Text('New Version Available'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _VersionRow(
              label: 'Current Version',
              value: currentVersion,
            ),
            const SizedBox(height: 8),
            _VersionRow(
              label: 'Latest Version',
              value: updateInfo.version,
              highlight: true,
            ),
            const SizedBox(height: 16),
            Text(
              'Release Notes',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            if (updateInfo.releaseNotes.isEmpty)
              Text(
                updateInfo.releaseName ?? 'No release notes provided.',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              ...updateInfo.releaseNotes.map(
                (note) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• '),
                      Expanded(child: Text(note)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        if (!updateInfo.mandatory)
          TextButton(onPressed: onLater, child: const Text('Later')),
        FilledButton(
          onPressed: onUpdateNow,
          child: const Text('Download Update'),
        ),
      ],
    );
  }
}

class _VersionRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _VersionRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: highlight
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
        ),
      ],
    );
  }
}
