import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/app_startup_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _status = 'Starting TubigTrack…';
  bool _starting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _launch());
  }

  Future<void> _launch() async {
    if (_starting) return;
    _starting = true;

    setState(() => _status = 'Initializing…');

    final result = await AppStartupService.instance.runEssentialStartup();

    if (!mounted) return;

    if (result.success) {
      await _enterApp();
      return;
    }

    await _showStartupFailureDialog(result);
  }

  Future<void> _enterApp() async {
    if (!mounted) return;
    context.go('/');
  }

  Future<void> _showStartupFailureDialog(StartupResult result) async {
    if (!mounted) return;

    final failure = result.failures.isNotEmpty
        ? result.failures.last
        : null;
    final step = result.blockingStep ?? failure?.step ?? 'Unknown step';
    final detail = failure?.error.toString() ?? 'Startup did not complete.';

    final action = await showDialog<_StartupFailureAction>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Startup Problem'),
        content: Text(
          'TubigTrack could not finish starting within '
          '${AppStartupService.startupTimeout.inSeconds} seconds.\n\n'
          'Step: $step\n\n'
          'Error: $detail\n\n'
          'You can retry or continue in Safe Mode. Safe Mode opens the app '
          'without backup, storage, or notification setup until you restart.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, _StartupFailureAction.retry),
            child: const Text('Retry'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, _StartupFailureAction.safeMode),
            child: const Text('Continue in Safe Mode'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    switch (action) {
      case _StartupFailureAction.retry:
        _starting = false;
        await _launch();
      case _StartupFailureAction.safeMode:
        await AppStartupService.instance.enterSafeModeAndCompleteEssential();
        await _enterApp();
      case null:
        await AppStartupService.instance.enterSafeModeAndCompleteEssential();
        await _enterApp();
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final bottomInset = media.padding.bottom;
    final screenHeight = media.size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final logoMaxWidth = constraints.maxWidth * 0.75;
            final loaderBottom = (screenHeight * 0.22).clamp(100.0, 200.0);

            return Stack(
              fit: StackFit.expand,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Image.asset(
                      'assets/images/splash_logo.png',
                      fit: BoxFit.contain,
                      width: logoMaxWidth,
                    ),
                  ),
                ),
                Positioned(
                  bottom: loaderBottom + bottomInset,
                  left: 0,
                  right: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF1565C0),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _status,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Image.asset(
                    'assets/images/splash_water.png',
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

enum _StartupFailureAction { retry, safeMode }
