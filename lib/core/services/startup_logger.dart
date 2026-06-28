import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Structured startup logging for diagnosing launch hangs.
class StartupLogger {
  StartupLogger._();

  static const _tag = 'Startup';

  static void start(String step) {
    final message = 'START $step';
    debugPrint('[$_tag] $message');
    developer.log(message, name: _tag);
  }

  static void success(String step, Duration elapsed) {
    final message = 'SUCCESS $step (${elapsed.inMilliseconds} ms)';
    debugPrint('[$_tag] $message');
    developer.log(message, name: _tag);
  }

  static void failure(
    String step,
    Duration elapsed,
    Object error, [
    StackTrace? stackTrace,
  ]) {
    final message =
        'FAILURE $step (${elapsed.inMilliseconds} ms): $error';
    debugPrint('[$_tag] $message');
    if (stackTrace != null) {
      debugPrint('$stackTrace');
    }
    developer.log(
      message,
      name: _tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void info(String message) {
    debugPrint('[$_tag] $message');
    developer.log(message, name: _tag);
  }

  static void skipped(String step, String reason) {
    final message = 'SKIPPED $step — $reason';
    debugPrint('[$_tag] $message');
    developer.log(message, name: _tag);
  }
}
