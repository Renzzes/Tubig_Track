import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/update/presentation/widgets/post_update_recovery_gate.dart';

class TubigTrackApp extends ConsumerStatefulWidget {
  const TubigTrackApp({super.key});

  @override
  ConsumerState<TubigTrackApp> createState() => _TubigTrackAppState();
}

class _TubigTrackAppState extends ConsumerState<TubigTrackApp> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    NotificationService.onNotificationTap = (payload) {
      if (payload != null && mounted) {
        ref.read(routerProvider).go(payload);
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    return PostUpdateRecoveryGate(
      child: MaterialApp.router(
        title: 'TubigTrack',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: router,
      ),
    );
  }
}
