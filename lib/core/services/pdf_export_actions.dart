import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

/// Save, share, and print PDF documents (native Android print via [Printing]).
class PdfExportActions {
  PdfExportActions._();

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
              onTap: () async {
                Navigator.pop(ctx);
                await _savePdf(context, bytes, fileName);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share PDF'),
              subtitle: const Text('Requires internet for some apps'),
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

  static Future<File> _writeTempFile(Uint8List bytes, String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  static Future<void> _savePdf(
    BuildContext context,
    Uint8List bytes,
    String fileName,
  ) async {
    try {
      final file = await _writeTempFile(bytes, fileName);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF saved to ${file.path}')),
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
      final file = await _writeTempFile(bytes, fileName);
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
