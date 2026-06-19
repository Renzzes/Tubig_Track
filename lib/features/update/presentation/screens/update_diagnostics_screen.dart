import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/update_fetch_result.dart';
import '../providers/update_provider.dart';

class UpdateDiagnosticsScreen extends ConsumerStatefulWidget {
  const UpdateDiagnosticsScreen({super.key});

  @override
  ConsumerState<UpdateDiagnosticsScreen> createState() =>
      _UpdateDiagnosticsScreenState();
}

class _UpdateDiagnosticsScreenState
    extends ConsumerState<UpdateDiagnosticsScreen> {
  UpdateFetchResult? _testResult;
  bool _testing = false;
  String? _testMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(updateDiagnosticsProvider);
    });
  }

  Future<void> _runApiTest() async {
    setState(() {
      _testing = true;
      _testMessage = null;
      _testResult = null;
    });

    try {
      final result = await ref.read(updateServiceProvider).testGitHubConnection();
      if (!mounted) return;
      setState(() {
        _testResult = result;
        _testing = false;
        _testMessage = result.isSuccess
            ? 'Connection successful'
            : result.errorDetail ?? 'Connection failed';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _testing = false;
        _testMessage = 'Test failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final diagnosticsAsync = ref.watch(updateDiagnosticsProvider);
    final lastCheckAsync = ref.watch(lastUpdateCheckProvider);
    final packageInfoAsync = ref.watch(packageInfoProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Update Diagnostics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Update Status',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  diagnosticsAsync.when(
                    data: (result) => Column(
                      children: [
                        packageInfoAsync.when(
                          data: (info) => _DiagRow(
                            label: 'Installed Build',
                            value: '${info.version}+${info.buildNumber}',
                          ),
                          loading: () => const _DiagRow(
                            label: 'Installed Build',
                            value: '…',
                          ),
                          error: (_, __) => const _DiagRow(
                            label: 'Installed Build',
                            value: '—',
                          ),
                        ),
                        _DiagRow(
                          label: 'Current App Version',
                          value: result.currentVersion,
                        ),
                        _DiagRow(
                          label: 'Latest GitHub Version',
                          value: result.latestVersion ?? '—',
                        ),
                        _DiagRow(
                          label: 'Update Available',
                          value: result.isUpdateAvailable ? 'Yes' : 'No',
                          valueColor: result.isUpdateAvailable
                              ? Colors.orange
                              : Colors.green,
                        ),
                        _DiagRow(
                          label: 'GitHub API Status',
                          value: _apiStatusLabel(result.fetchResult),
                        ),
                        _DiagRow(
                          label: 'Download URL Detected',
                          value: result.fetchResult?.downloadUrl ?? '—',
                          multiline: true,
                        ),
                        lastCheckAsync.when(
                          data: (lastCheck) => _DiagRow(
                            label: 'Last Update Check',
                            value: lastCheck == null
                                ? 'Never'
                                : DateFormat('MMMM d, yyyy h:mm a')
                                    .format(lastCheck),
                          ),
                          loading: () => const _DiagRow(
                            label: 'Last Update Check',
                            value: '…',
                          ),
                          error: (_, __) => const _DiagRow(
                            label: 'Last Update Check',
                            value: '—',
                          ),
                        ),
                      ],
                    ),
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (e, _) => Text('Error loading diagnostics: $e'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'API Configuration',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _DiagRow(
                    label: 'GitHub API URL',
                    value: AppConstants.githubLatestReleaseUrl,
                    multiline: true,
                  ),
                  _DiagRow(
                    label: 'APK Asset Name',
                    value: 'app-release.apk',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Manual API Test',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _testing ? null : _runApiTest,
                      icon: _testing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.wifi_tethering),
                      label: Text(
                        _testing ? 'Testing…' : 'Test GitHub Connection',
                      ),
                    ),
                  ),
                  if (_testMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _testMessage!,
                      style: TextStyle(
                        color: _testResult?.isSuccess == true
                            ? Colors.green[700]
                            : Colors.red[700],
                      ),
                    ),
                  ],
                  if (_testResult != null) ...[
                    const SizedBox(height: 12),
                    _DiagRow(
                      label: 'Response Status',
                      value: '${_testResult!.statusCode ?? '—'}',
                    ),
                    _DiagRow(
                      label: 'Parsed Version',
                      value: _testResult!.latestVersion ?? '—',
                    ),
                    _DiagRow(
                      label: 'Asset Count',
                      value: '${_testResult!.assetCount}',
                    ),
                    if (_testResult!.errorDetail != null)
                      _DiagRow(
                        label: 'Error Detail',
                        value: _testResult!.errorDetail!,
                        multiline: true,
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _apiStatusLabel(UpdateFetchResult? fetch) {
    if (fetch == null) return 'Not checked';
    if (fetch.isSuccess) return 'OK (${fetch.statusCode})';
    if (fetch.isNetworkError) return 'Network error';
    return 'Error ${fetch.statusCode ?? ''}: ${fetch.errorDetail ?? fetch.error.name}';
  }
}

class _DiagRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool multiline;

  const _DiagRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.multiline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: multiline
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: valueColor,
                  ),
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: valueColor,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
    );
  }
}

class UpdateDiagnosticsData {
  final String currentVersion;
  final String? latestVersion;
  final bool isUpdateAvailable;
  final UpdateFetchResult? fetchResult;

  const UpdateDiagnosticsData({
    required this.currentVersion,
    this.latestVersion,
    required this.isUpdateAvailable,
    this.fetchResult,
  });
}
