import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Handles Android storage permission prompts when sharing or opening files.
class StoragePermissionService {
  StoragePermissionService._();

  /// App-scoped storage does not require permission on modern Android.
  /// This helper covers legacy/external storage cases and gives a retry path.
  static Future<bool> ensureStorageAccess(BuildContext context) async {
    if (!Platform.isAndroid) return true;

    final storage = await Permission.storage.status;
    if (storage.isGranted) return true;

    if (storage.isDenied) {
      final result = await Permission.storage.request();
      if (result.isGranted) return true;
    }

    if (!context.mounted) return false;

    final action = await showDialog<StoragePermissionAction>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Storage Permission'),
        content: const Text(
          'TubigTrack needs storage access to share and open your backup files. '
          'Your data is stored in the app\'s private TubigTrack folder.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, StoragePermissionAction.cancel),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, StoragePermissionAction.retry),
            child: const Text('Retry'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, StoragePermissionAction.settings),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );

    switch (action) {
      case StoragePermissionAction.retry:
        final result = await Permission.storage.request();
        return result.isGranted;
      case StoragePermissionAction.settings:
        await openAppSettings();
        return false;
      case StoragePermissionAction.cancel:
      case null:
        return false;
    }
  }
}

enum StoragePermissionAction { cancel, retry, settings }
