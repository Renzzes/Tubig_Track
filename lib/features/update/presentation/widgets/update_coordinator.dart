import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/update_info.dart';
import '../../services/update_service.dart';
import '../providers/update_provider.dart';
import '../widgets/download_progress_dialog.dart';
import '../widgets/update_dialog.dart';

/// Listens for updates 3 seconds after mount and shows dialogs when needed.
class UpdateCoordinator extends ConsumerStatefulWidget {
  final Widget child;

  const UpdateCoordinator({super.key, required this.child});

  @override
  ConsumerState<UpdateCoordinator> createState() => _UpdateCoordinatorState();
}

class _UpdateCoordinatorState extends ConsumerState<UpdateCoordinator> {
  bool _autoCheckDone = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduleAutoCheck();
      _recordVersion();
    });
  }

  Future<void> _recordVersion() async {
    await ref.read(updateServiceProvider).recordVersionIfUpdated();
    ref.invalidate(updateHistoryProvider);
  }

  Future<void> _scheduleAutoCheck() async {
    if (_autoCheckDone) return;
    _autoCheckDone = true;

    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final result = await ref.read(updateServiceProvider).checkForUpdates();
    ref.invalidate(lastUpdateCheckProvider);

    if (!mounted) return;
    if (result.status == UpdateCheckStatus.updateAvailable &&
        result.updateInfo != null) {
      await _showUpdateDialog(result.updateInfo!);
    }
  }

  Future<void> _showUpdateDialog(UpdateInfo updateInfo) async {
    await UpdateDialog.show(
      context,
      updateInfo: updateInfo,
      onLater: () => Navigator.pop(context),
      onUpdateNow: () {
        Navigator.pop(context);
        _startUpdate(updateInfo);
      },
    );
  }

  Future<void> _startUpdate(UpdateInfo updateInfo) async {
    final progress = await DownloadProgressDialog.show(context);

    try {
      await ref.read(updateServiceProvider).downloadAndInstall(
            updateInfo,
            onProgress: (p) => progress.value = p,
          );
      if (mounted) {
        DownloadProgressDialog.dismiss(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Installer launched. Complete the update to continue.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        DownloadProgressDialog.dismiss(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Exposes manual update check for Settings screen.
Future<void> performManualUpdateCheck(
  BuildContext context,
  WidgetRef ref, {
  bool showUpToDateMessage = true,
}) async {
  final service = ref.read(updateServiceProvider);
  final result = await service.checkForUpdates();
  ref.invalidate(lastUpdateCheckProvider);

  if (!context.mounted) return;

  switch (result.status) {
    case UpdateCheckStatus.updateAvailable when result.updateInfo != null:
      await UpdateDialog.show(
        context,
        updateInfo: result.updateInfo!,
        onLater: () => Navigator.pop(context),
        onUpdateNow: () async {
          Navigator.pop(context);
          final progress = await DownloadProgressDialog.show(context);
          try {
            await service.downloadAndInstall(
              result.updateInfo!,
              onProgress: (p) => progress.value = p,
            );
            if (context.mounted) {
              DownloadProgressDialog.dismiss(context);
            }
          } catch (e) {
            if (context.mounted) {
              DownloadProgressDialog.dismiss(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Update failed: $e')),
              );
            }
          }
        },
      );
    case UpdateCheckStatus.offline:
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to check for updates. Continue normal operation.'),
        ),
      );
    case UpdateCheckStatus.upToDate:
      if (showUpToDateMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You are on the latest version.')),
        );
      }
    case UpdateCheckStatus.error:
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to check for updates.')),
      );
    default:
      break;
  }
}
