import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/app_startup_service.dart';
import '../../../settings/presentation/widgets/backup_notification_presenter.dart';

/// Runs non-essential startup work after the dashboard shell is visible.
class StartupBackgroundCoordinator extends ConsumerStatefulWidget {
  final Widget child;

  const StartupBackgroundCoordinator({super.key, required this.child});

  @override
  ConsumerState<StartupBackgroundCoordinator> createState() =>
      _StartupBackgroundCoordinatorState();
}

class _StartupBackgroundCoordinatorState
    extends ConsumerState<StartupBackgroundCoordinator> {
  static bool _scheduled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _afterFirstFrame());
  }

  Future<void> _afterFirstFrame() async {
    if (_scheduled) return;
    _scheduled = true;

    AppStartupService.instance.scheduleBackgroundTasks(ref);

    if (!mounted) return;
    await BackupNotificationPresenter.showPendingIfAny(context);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
