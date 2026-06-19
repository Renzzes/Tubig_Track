import 'package:flutter/material.dart';

import '../../domain/entities/update_info.dart';

class UpdateDialog extends StatelessWidget {
  final UpdateInfo updateInfo;
  final VoidCallback onLater;
  final VoidCallback onUpdateNow;

  const UpdateDialog({
    super.key,
    required this.updateInfo,
    required this.onLater,
    required this.onUpdateNow,
  });

  static Future<void> show(
    BuildContext context, {
    required UpdateInfo updateInfo,
    required VoidCallback onLater,
    required VoidCallback onUpdateNow,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: !updateInfo.mandatory,
      builder: (_) => UpdateDialog(
        updateInfo: updateInfo,
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
            Text(
              'Version ${updateInfo.version}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              "What's New",
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
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
          child: const Text('Update Now'),
        ),
      ],
    );
  }
}
