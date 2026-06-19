import 'package:flutter/material.dart';

class DownloadProgressDialog extends StatefulWidget {
  final ValueNotifier<double> progress;

  const DownloadProgressDialog({super.key, required this.progress});

  static Future<ValueNotifier<double>> show(BuildContext context) {
    final progress = ValueNotifier<double>(0);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => DownloadProgressDialog(progress: progress),
    );
    return Future.value(progress);
  }

  static void dismiss(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  State<DownloadProgressDialog> createState() => _DownloadProgressDialogState();
}

class _DownloadProgressDialogState extends State<DownloadProgressDialog> {
  @override
  void initState() {
    super.initState();
    widget.progress.addListener(_onProgress);
  }

  @override
  void dispose() {
    widget.progress.removeListener(_onProgress);
    super.dispose();
  }

  void _onProgress() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final percent = (widget.progress.value * 100).clamp(0, 100).toInt();
    return PopScope(
      canPop: false,
      child: AlertDialog(
        title: const Text('Downloading Update'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(
              value: widget.progress.value > 0 ? widget.progress.value : null,
            ),
            const SizedBox(height: 16),
            Text(
              '$percent%',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
