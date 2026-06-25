import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';

import '../widgets/backup_restore_flow.dart';

import '../../../../shared/widgets/loading_overlay.dart';

import '../../../inventory/presentation/providers/inventory_provider.dart';

import '../../../update/domain/entities/update_channel.dart';

import '../../../update/presentation/providers/update_provider.dart';

import '../widgets/data_management_dialogs.dart';

import '../../../update/presentation/widgets/update_coordinator.dart';

import '../providers/settings_provider.dart';

import 'factory_reset_screen.dart';



class SettingsScreen extends ConsumerWidget {

  const SettingsScreen({super.key});



  @override

  Widget build(BuildContext context, WidgetRef ref) {

    final settingsAsync = ref.watch(appSettingsProvider);

    final packageInfoAsync = ref.watch(packageInfoProvider);

    final lastCheckAsync = ref.watch(lastUpdateCheckProvider);

    final channelAsync = ref.watch(updateChannelProvider);



    return Scaffold(

      appBar: AppBar(title: const Text('Settings')),

      body: settingsAsync.when(

        data: (settings) => ListView(

          children: [

            const _SectionHeader(title: 'App Information'),

            packageInfoAsync.when(

              data: (info) => ListTile(

                leading: const Icon(Icons.water_drop_outlined),

                title: const Text('TubigTrack'),

                subtitle: Text('Version ${info.version}+${info.buildNumber}'),

              ),

              loading: () => ListTile(

                title: const Text('TubigTrack'),

                subtitle: Text('Version ${AppConstants.appVersion}'),

              ),

              error: (_, __) => ListTile(

                title: const Text('TubigTrack'),

                subtitle: Text('Version ${AppConstants.appVersion}'),

              ),

            ),

            lastCheckAsync.when(

              data: (lastCheck) => ListTile(

                leading: const Icon(Icons.schedule_outlined),

                title: const Text('Last Checked'),

                subtitle: Text(

                  lastCheck == null

                      ? 'Never'

                      : DateFormat('MMMM d, yyyy h:mm a').format(lastCheck),

                ),

              ),

              loading: () => const SizedBox.shrink(),

              error: (_, __) => const SizedBox.shrink(),

            ),

            ListTile(

              leading: const Icon(Icons.system_update_outlined),

              title: const Text('Check for Updates'),

              subtitle: const Text('Search for the latest version'),

              onTap: () => performManualUpdateCheck(context, ref),

            ),

            channelAsync.when(

              data: (UpdateChannel channel) => ListTile(

                leading: const Icon(Icons.tune_outlined),

                title: const Text('Update Channel'),

                subtitle: Text(

                  channel == UpdateChannel.stable ? 'Stable' : 'Beta',

                ),

                onTap: () => _showChannelDialog(context, ref, channel),

              ),

              loading: () => const SizedBox.shrink(),

              error: (_, __) => const SizedBox.shrink(),

            ),

            ListTile(

              leading: const Icon(Icons.history_outlined),

              title: const Text('Update History'),

              trailing: const Icon(Icons.arrow_forward_ios, size: 14),

              onTap: () => context.push('/update-history'),

            ),

            ListTile(

              leading: const Icon(Icons.bug_report_outlined),

              title: const Text('Update Diagnostics'),

              subtitle: const Text('GitHub API status and connection test'),

              trailing: const Icon(Icons.arrow_forward_ios, size: 14),

              onTap: () => context.push('/update-diagnostics'),

            ),



            const Divider(),

            const _SectionHeader(title: 'Inventory'),

            ListTile(

              leading: const Icon(Icons.inventory_2_outlined),

              title: const Text('Initial Bottle Inventory'),

              subtitle: Text('${settings.totalBottleInventory} bottles'),

              trailing: const Icon(Icons.edit_outlined),

              onTap: () => _showInventoryDialog(

                context,

                ref,

                settings.totalBottleInventory,

              ),

            ),

            ListTile(

              leading: const Icon(Icons.tune_outlined),

              title: const Text('Inventory Settings'),

              subtitle: const Text('Low stock thresholds for alerts'),

              trailing: const Icon(Icons.arrow_forward_ios, size: 14),

              onTap: () => context.push('/settings/inventory'),

            ),

            ListTile(

              leading: const Icon(Icons.warning_amber_outlined),

              title: const Text('Low Inventory Threshold'),

              subtitle: Text('${settings.lowInventoryThreshold} bottles (legacy)'),

              trailing: const Icon(Icons.edit_outlined),

              onTap: () => _showThresholdDialog(

                context,

                ref,

                settings.lowInventoryThreshold,

              ),

            ),



            const Divider(),

            const _SectionHeader(title: 'Data Management'),

            ListTile(

              leading: const Icon(Icons.folder_outlined),

              title: const Text('Storage'),

              subtitle: const Text('View TubigTrack folders and usage'),

              trailing: const Icon(Icons.arrow_forward_ios, size: 14),

              onTap: () => context.push('/settings/storage'),

            ),

            ListTile(

              title: const Text('Export CSV'),

              subtitle: const Text('Export all data as CSV file'),

              onTap: () => _exportCSV(context, ref),

            ),

            ListTile(

              leading: const Icon(Icons.backup_outlined),

              title: const Text('Backup Database'),

              subtitle: const Text('Save a copy of the database'),

              onTap: () => _backupDB(context, ref),

            ),

            ListTile(

              leading: const Icon(Icons.restore_outlined),

              title: const Text('Restore Database'),

              subtitle: const Text('Restore from a .db backup file'),

              onTap: () => _restoreDB(context, ref),

            ),

            ListTile(

              leading: const Icon(Icons.medical_services_outlined),

              title: const Text('Recovery Center'),

              subtitle: const Text('View, restore, export, or delete backups'),

              trailing: const Icon(Icons.arrow_forward_ios, size: 14),

              onTap: () => context.push('/recovery-center'),

            ),

            ListTile(

              leading: Icon(Icons.delete_forever_outlined, color: Colors.red[700]),

              title: Text(
                'Reset Application',
                style: TextStyle(color: Colors.red[700]),
              ),

              subtitle: const Text(
                'Permanently delete all operational business data',
              ),

              onTap: () => startFactoryResetFlow(context, ref),

            ),

            ListTile(

              leading: const Icon(Icons.archive_outlined),

              title: const Text('Archive & Reset'),

              subtitle: const Text(
                'Save archive backup and start a new business cycle',
              ),

              trailing: const Icon(Icons.arrow_forward_ios, size: 14),

              onTap: () => context.push('/settings/archive-reset'),

            ),



            const Divider(),

            const _SectionHeader(title: 'Quick Links'),

            ListTile(

              leading: const Icon(Icons.receipt_long_outlined),

              title: const Text('Expenses'),

              trailing: const Icon(Icons.arrow_forward_ios, size: 14),

              onTap: () => context.push('/expenses'),

            ),

            ListTile(

              leading: const Icon(Icons.local_drink_outlined),

              title: const Text('Dispenser Sales'),

              trailing: const Icon(Icons.arrow_forward_ios, size: 14),

              onTap: () => context.push('/dispenser-sales'),

            ),



            const Divider(),

            const _SectionHeader(title: 'About'),

            ListTile(

              leading: const Icon(Icons.info_outline),

              title: const Text('About TubigTrack'),

              subtitle: Text('Version ${AppConstants.appVersion}'),

              trailing: const Icon(Icons.arrow_forward_ios, size: 14),

              onTap: () => context.push('/about'),

            ),

          ],

        ),

        loading: () => const LoadingOverlay(),

        error: (e, _) => Center(child: Text('Error: $e')),

      ),

    );

  }



  Future<void> _showChannelDialog(

    BuildContext context,

    WidgetRef ref,

    UpdateChannel current,

  ) async {

    var selected = current;

    final result = await showDialog<UpdateChannel>(

      context: context,

      builder: (ctx) => StatefulBuilder(

        builder: (context, setState) => AlertDialog(

          title: const Text('Update Channel'),

          content: RadioGroup<UpdateChannel>(
            groupValue: selected,
            onChanged: (v) =>
                setState(() => selected = v ?? UpdateChannel.stable),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                RadioListTile<UpdateChannel>(
                  title: Text('Stable'),
                  value: UpdateChannel.stable,
                ),
                RadioListTile<UpdateChannel>(
                  title: Text('Beta'),
                  value: UpdateChannel.beta,
                ),
              ],
            ),
          ),

          actions: [

            TextButton(

              onPressed: () => Navigator.pop(ctx),

              child: const Text('Cancel'),

            ),

            FilledButton(

              onPressed: () => Navigator.pop(ctx, selected),

              child: const Text('Save'),

            ),

          ],

        ),

      ),

    );



    if (result != null) {

      await ref.read(updateServiceProvider).setChannel(result);

      ref.invalidate(updateChannelProvider);

    }

  }



  Future<void> _showInventoryDialog(

    BuildContext context,

    WidgetRef ref,

    int currentValue,

  ) async {

    final controller = TextEditingController(text: currentValue.toString());

    final result = await showDialog<int>(

      context: context,

      builder: (ctx) => AlertDialog(

        title: const Text('Initial Bottle Inventory'),

        content: TextField(

          controller: controller,

          keyboardType: TextInputType.number,

          autofocus: true,

          decoration: const InputDecoration(labelText: 'Initial Bottles'),

        ),

        actions: [

          TextButton(

            onPressed: () => Navigator.pop(ctx),

            child: const Text('Cancel'),

          ),

          ElevatedButton(

            onPressed: () {

              final n = int.tryParse(controller.text);

              if (n != null && n >= 0) Navigator.pop(ctx, n);

            },

            child: const Text('Save'),

          ),

        ],

      ),

    );



    if (result != null) {

      final current = await ref.read(settingsRepositoryProvider).getSettings();

      await ref.read(settingsRepositoryProvider).updateSettings(

            current.copyWith(totalBottleInventory: result),

          );

      await ref.read(inventoryRepositoryProvider).updateTotalInventory(result);

      ref.invalidate(appSettingsProvider);

      ref.invalidate(inventorySummaryProvider);

    }

  }



  Future<void> _showThresholdDialog(

    BuildContext context,

    WidgetRef ref,

    int currentValue,

  ) async {

    final controller = TextEditingController(text: currentValue.toString());

    final result = await showDialog<int>(

      context: context,

      builder: (ctx) => AlertDialog(

        title: const Text('Low Inventory Threshold'),

        content: TextField(

          controller: controller,

          keyboardType: TextInputType.number,

          autofocus: true,

          decoration: const InputDecoration(labelText: 'Alert when at or below'),

        ),

        actions: [

          TextButton(

            onPressed: () => Navigator.pop(ctx),

            child: const Text('Cancel'),

          ),

          ElevatedButton(

            onPressed: () {

              final n = int.tryParse(controller.text);

              if (n != null && n >= 0) Navigator.pop(ctx, n);

            },

            child: const Text('Save'),

          ),

        ],

      ),

    );



    if (result != null) {

      final current = await ref.read(settingsRepositoryProvider).getSettings();

      await ref.read(settingsRepositoryProvider).updateSettings(

            current.copyWith(
              lowInventoryThreshold: result,
              minBottles: result,
            ),

          );

      ref.invalidate(appSettingsProvider);

    }

  }



  Future<void> _exportCSV(BuildContext context, WidgetRef ref) async {

    try {

      final paths = await ref.read(settingsRepositoryProvider).exportCSV();

      if (context.mounted) {

        await showCsvExportSuccessDialog(context, paths);

      }

    } catch (e) {

      if (context.mounted) {

        ScaffoldMessenger.of(context).showSnackBar(

          SnackBar(content: Text('Export failed: $e')),

        );

      }

    }

  }



  Future<void> _backupDB(BuildContext context, WidgetRef ref) async {

    try {

      final path = await ref.read(backupRepositoryProvider).createManualBackup();

      ref.invalidate(recoveryFilesProvider);

      ref.invalidate(availableBackupsProvider);

      ref.invalidate(storageSummaryProvider);

      if (context.mounted) {

        await showBackupSuccessDialog(context, path);

      }

    } catch (e) {

      if (context.mounted) {

        ScaffoldMessenger.of(context).showSnackBar(

          SnackBar(content: Text('Backup failed: $e')),

        );

      }

    }

  }



  Future<void> _restoreDB(BuildContext context, WidgetRef ref) async {

    final backups = await ref.read(backupRepositoryProvider).listBackups();

    if (backups.isEmpty) {

      if (context.mounted) {

        ScaffoldMessenger.of(context).showSnackBar(

          const SnackBar(

            content: Text('No backups found in TubigTrack/Backups'),

          ),

        );

      }

      return;

    }



    if (!context.mounted) return;

    final selected = await showModalBottomSheet<String>(

      context: context,

      builder: (ctx) => SafeArea(

        child: Column(

          mainAxisSize: MainAxisSize.min,

          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [

            const Padding(

              padding: EdgeInsets.all(16),

              child: Text(

                'Select a backup',

                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),

              ),

            ),

            Flexible(

              child: ListView.builder(

                shrinkWrap: true,

                itemCount: backups.length,

                itemBuilder: (_, i) {

                  final b = backups[i];

                  return ListTile(

                    leading: const Icon(Icons.backup_outlined),

                    title: Text(b.fileName),

                    subtitle: Text(

                      '${DateFormat('MMM d, yyyy h:mm a').format(b.modifiedAt)}'

                      '${b.appVersion != null ? ' · v${b.appVersion}' : ''}',

                    ),

                    onTap: () => Navigator.pop(ctx, b.path),

                  );

                },

              ),

            ),

          ],

        ),

      ),

    );

    if (selected == null || !context.mounted) return;

    await runBackupRestoreFlow(context, ref, selected);

  }

}



class _SectionHeader extends StatelessWidget {

  final String title;



  const _SectionHeader({required this.title});



  @override

  Widget build(BuildContext context) {

    return Padding(

      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),

      child: Text(

        title,

        style: TextStyle(

          fontSize: 12,

          fontWeight: FontWeight.w600,

          color: Theme.of(context).colorScheme.primary,

          letterSpacing: 0.5,

        ),

      ),

    );

  }

}


