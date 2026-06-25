import 'dart:io';

import 'package:flutter/services.dart';

/// Android platform channel for public TubigTrack storage and Files app integration.
class TubigTrackStorageChannel {
  TubigTrackStorageChannel._();

  static const _channel = MethodChannel('com.tubigtrack.tubig_track/storage');

  /// Creates [Internal Storage/TubigTrack/] and subfolders. Returns root path or null.
  static Future<String?> initPublicStorage() async {
    if (!Platform.isAndroid) return null;
    try {
      final path = await _channel.invokeMethod<String>('initPublicStorage');
      return path;
    } on PlatformException {
      return null;
    }
  }

  /// Opens a TubigTrack subfolder in the device Files app.
  ///
  /// Provide [relativePath] like `Backups` or [absolutePath] for the folder to open.
  static Future<bool> openFolderInFilesApp({
    String? relativePath,
    String? absolutePath,
  }) async {
    if (!Platform.isAndroid) return false;
    try {
      final ok = await _channel.invokeMethod<bool>('openFolderInFilesApp', {
        if (relativePath != null) 'relativePath': relativePath,
        if (absolutePath != null) 'absolutePath': absolutePath,
      });
      return ok ?? false;
    } on PlatformException {
      return false;
    }
  }
}
