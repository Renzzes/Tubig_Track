import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/update_info.dart';
import '../../services/update_service.dart';
import '../providers/update_provider.dart';
import '../widgets/download_progress_dialog.dart';
import '../widgets/update_dialog.dart';

/// Runs update checks once per app session and shows the dialog only when a
/// newer semver is available (latest > installed).
class UpdateCoordinator extends ConsumerStatefulWidget {
  final Widget child;

  const UpdateCoordinator({super.key, required this.child});

  @override
  ConsumerState<UpdateCoordinator> createState() => _UpdateCoordinatorState();
}

class _UpdateCoordinatorState extends ConsumerState<UpdateCoordinator>
    with WidgetsBindingObserver {
  /// Prevents duplicate auto-checks when the coordinator remounts.
  static bool _sessionAutoCheckScheduled = false;

  /// Tracks which version dialog was shown this session.
  static String? _sessionShownVersion;

  bool _updateDialogVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recordVersion();
      _scheduleAutoCheck(fromStartup: true);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _scheduleAutoCheck(fromResume: true);
    }
  }

  Future<void> _recordVersion() async {
    await ref.read(updateServiceProvider).recordVersionIfUpdated();
    ref.invalidate(updateHistoryProvider);
  }

  Future<void> _scheduleAutoCheck({
    bool fromStartup = false,
    bool fromResume = false,
  }) async {
    if (!mounted || _updateDialogVisible) return;

    if (fromStartup) {
      if (_sessionAutoCheckScheduled) return;
      _sessionAutoCheckScheduled = true;
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;
    } else if (fromResume) {
      final lastCheck = await ref.read(updateServiceProvider).getLastCheckTime();
      if (lastCheck != null &&
          DateTime.now().difference(lastCheck).inHours < 6) {
        return;
      }
    } else {
      return;
    }

    await _runAutoCheck();
  }

  Future<void> _runAutoCheck() async {
    if (!mounted || _updateDialogVisible) return;

    final service = ref.read(updateServiceProvider);
    final result = await service.checkForUpdates();
    ref.invalidate(lastUpdateCheckProvider);
    ref.invalidate(updateDiagnosticsProvider);

    if (!mounted) return;
    if (!result.isUpdateAvailable || result.updateInfo == null) return;

    final updateInfo = result.updateInfo!;
    if (_sessionShownVersion == updateInfo.version) return;

    final dismissed =
        await ref.read(updateRepositoryProvider).getDismissedUpdateVersion();
    if (dismissed != null &&
        dismissed.isNotEmpty &&
        dismissed == updateInfo.version) {
      return;
    }

    _sessionShownVersion = updateInfo.version;
    await _showUpdateDialog(result);
  }

  Future<void> _showUpdateDialog(UpdateCheckResult result) async {
    if (_updateDialogVisible || !mounted) return;
    _updateDialogVisible = true;

    try {
      await UpdateDialog.show(
        context,
        updateInfo: result.updateInfo!,
        currentVersion: result.currentVersion,
        onLater: () {
          final navigator = Navigator.of(context);
          ref
              .read(updateRepositoryProvider)
              .setDismissedUpdateVersion(result.updateInfo!.version)
              .then((_) => navigator.pop());
        },
        onUpdateNow: () {
          Navigator.pop(context);
          _startUpdate(result.updateInfo!);
        },
      );
    } finally {
      _updateDialogVisible = false;
    }
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
  if (!context.mounted) return;

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const PopScope(
      canPop: false,
      child: Center(child: CircularProgressIndicator()),
    ),
  );

  final service = ref.read(updateServiceProvider);
  UpdateCheckResult result;
  try {
    result = await service.checkForUpdates();
  } finally {
    if (context.mounted) Navigator.pop(context);
  }

  ref.invalidate(lastUpdateCheckProvider);
  ref.invalidate(updateDiagnosticsProvider);

  if (!context.mounted) return;

  switch (result.status) {
    case UpdateCheckStatus.updateAvailable when result.updateInfo != null:
      await UpdateDialog.show(
        context,
        updateInfo: result.updateInfo!,
        currentVersion: result.currentVersion,
        onLater: () {
          final navigator = Navigator.of(context);
          ref
              .read(updateRepositoryProvider)
              .setDismissedUpdateVersion(result.updateInfo!.version)
              .then((_) => navigator.pop());
        },
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
    case UpdateCheckStatus.networkError:
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to connect to GitHub. Please check your internet connection.',
          ),
        ),
      );
    case UpdateCheckStatus.apiError:
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to retrieve release information.'),
        ),
      );
    case UpdateCheckStatus.upToDate:
      if (showUpToDateMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You are already using the latest version.'),
          ),
        );
      }
    default:
      break;
  }
}
