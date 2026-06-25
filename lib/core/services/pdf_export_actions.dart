import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../services/data_storage_service.dart';

/// Save, share, and print PDF documents to TubigTrack/Reports/.
class PdfExportActions {
  PdfExportActions._();

  static Future<File> writeReportFile(
    Uint8List bytes,
    String fileName,
  ) async {
    final storage = DataStorageService.instance;
    await storage.ensureFolderStructure();
    final reportsDir = await storage.reportsDirectory();
    final file = File(p.join(reportsDir.path, fileName));
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  static Future<File> writeReportFileWithTimestamp(
    Uint8List bytes,
    String baseName,
  ) async {
    final stamp = DataStorageService.instance.timestampForFilename();
    final ext = p.extension(baseName);
    final name = p.basenameWithoutExtension(baseName);
    return writeReportFile(bytes, '${name}_$stamp$ext');
  }

  static Future<void> showOptions(
    BuildContext context, {
    required Uint8List bytes,
    required String fileName,
    String shareText = 'TubigTrack Report',
  }) async {
    if (!context.mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.save_outlined),
              title: const Text('Save PDF'),
              subtitle: const Text('TubigTrack/Reports'),
              onTap: () async {
                Navigator.pop(ctx);
                await _savePdf(context, bytes, fileName);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share PDF'),
              onTap: () async {
                Navigator.pop(ctx);
                await _sharePdf(context, bytes, fileName, shareText);
              },
            ),
            ListTile(
              leading: const Icon(Icons.print_outlined),
              title: const Text('Print PDF'),
              onTap: () async {
                Navigator.pop(ctx);
                await _printPdf(context, bytes, fileName);
              },
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _savePdf(
    BuildContext context,
    Uint8List bytes,
    String fileName,
  ) async {
    try {
      final file = await writeReportFileWithTimestamp(bytes, fileName);
      if (context.mounted) {
        final display = DataStorageService.instance.displayPath(file.path);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF saved to $display')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving PDF: $e')),
        );
      }
    }
  }

  static Future<void> _sharePdf(
    BuildContext context,
    Uint8List bytes,
    String fileName,
    String shareText,
  ) async {
    try {
      final file = await writeReportFileWithTimestamp(bytes, fileName);
      await Share.shareXFiles([XFile(file.path)], text: shareText);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing PDF: $e')),
        );
      }
    }
  }

  static Future<void> _printPdf(
    BuildContext context,
    Uint8List bytes,
    String fileName,
  ) async {
    try {
      await Printing.layoutPdf(
        name: fileName,
        onLayout: (_) async => bytes,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error printing PDF: $e')),
        );
      }
    }
  }
}

/// Opens a file or folder path on device.
Future<void> openStoragePath(String path) async {
  final result = await OpenFilex.open(path);
  if (result.type != ResultType.done) {
    throw Exception(result.message);
  }
}
