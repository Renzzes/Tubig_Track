import 'dart:io';

import 'package:open_filex/open_filex.dart';

import 'data_storage_service.dart';
import 'tubig_track_storage_channel.dart';

/// Opens a TubigTrack folder in the Files app (public) or a file with its app.
Future<void> openStoragePath(String path) async {
  final storage = DataStorageService.instance;
  final file = File(path);

  if (await file.exists()) {
    final result = await OpenFilex.open(path);
    if (result.type != ResultType.done) {
      throw Exception(result.message);
    }
    return;
  }

  final dir = Directory(path);
  if (!await dir.exists()) {
    throw Exception('Path not found: $path');
  }

  if (Platform.isAndroid) {
    final relative = storage.relativeSubfolderPath(path);
    final opened = await TubigTrackStorageChannel.openFolderInFilesApp(
      relativePath: relative,
      absolutePath: storage.isPublicStorage ? path : null,
    );
    if (opened) return;
  }

  throw Exception(
    storage.isPublicStorage
        ? 'Could not open folder in Files app. Open Internal storage → TubigTrack manually.'
        : 'Files are in app-private storage (${storage.displayRootPath()}). '
            'Use Share, or choose a public TubigTrack folder in Settings → Storage.',
  );
}

Future<bool> openTubigTrackFolder(String folderPath) async {
  try {
    await openStoragePath(folderPath);
    return true;
  } catch (_) {
    return false;
  }
}
