import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/backup_metadata.dart';
import '../../../../core/services/backup_metadata_service.dart';
import '../../../../core/services/backup_migration_service.dart';
import '../../../../core/services/csv_export_service.dart';
import '../../../settings/presentation/widgets/data_management_dialogs.dart';

/// Browse an unrestorable backup without modifying it or the live database.
class ReadOnlyRecoveryScreen extends StatefulWidget {
  final String backupPath;

  const ReadOnlyRecoveryScreen({super.key, required this.backupPath});

  @override
  State<ReadOnlyRecoveryScreen> createState() => _ReadOnlyRecoveryScreenState();
}

class _ReadOnlyRecoveryScreenState extends State<ReadOnlyRecoveryScreen>
    with SingleTickerProviderStateMixin {
  AppDatabase? _db;
  File? _tempCopy;
  BackupMetadata? _metadata;
  String? _error;
  bool _loading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _openBackup();
  }

  Future<void> _openBackup() async {
    try {
      final metadata =
          await BackupMetadataService.instance.readMetadata(widget.backupPath);
      final opened =
          await BackupMigrationService.instance.openReadOnlyCopy(widget.backupPath);
      if (mounted) {
        setState(() {
          _db = opened.db;
          _tempCopy = opened.tempFile;
          _metadata = metadata;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _db?.close();
    _tempCopy?.delete();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Read-Only Recovery'),
        bottom: _loading || _error != null || _db == null
            ? null
            : TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: const [
                  Tab(text: 'Customers'),
                  Tab(text: 'Deliveries'),
                  Tab(text: 'Payments'),
                  Tab(text: 'More'),
                ],
              ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share Backup',
            onPressed: () => Share.shareXFiles(
              [XFile(widget.backupPath)],
              text: p.basename(widget.backupPath),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          MaterialBanner(
            content: const Text(
              'Read-Only Recovery Mode — this backup cannot be restored directly '
              'but its records remain accessible.',
            ),
            leading: const Icon(Icons.lock_outline),
            backgroundColor: Colors.orange.shade50,
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Exit'),
              ),
            ],
          ),
          if (_loading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            Expanded(child: Center(child: Text('Error: $_error')))
          else ...[
            if (_metadata != null) _MetadataStrip(metadata: _metadata!),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _SimpleList(
                    loader: () async {
                      final rows = await _db!.customersDao.getAll();
                      return rows
                          .map((c) => '${c.name} · ${c.phone ?? 'no phone'}')
                          .toList();
                    },
                  ),
                  _SimpleList(
                    loader: () async {
                      final rows = await _db!.deliveriesDao.getAll();
                      return rows
                          .map(
                            (d) =>
                                '${DateFormat.yMMMd().format(d.deliveryDate)} · '
                                'Qty ${d.quantity}',
                          )
                          .toList();
                    },
                  ),
                  _SimpleList(
                    loader: () async {
                      final rows = await _db!.paymentsDao.getAll();
                      return rows
                          .map(
                            (p) =>
                                '${DateFormat.yMMMd().format(p.paymentDate)} · '
                                '₱${p.amount.toStringAsFixed(0)}',
                          )
                          .toList();
                    },
                  ),
                  _MoreTab(db: _db!),
                ],
              ),
            ),
            _ActionBar(
              onExportCsv: _exportCsv,
              onShareBackup: () => Share.shareXFiles(
                [XFile(widget.backupPath)],
                text: 'TubigTrack Backup',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _exportCsv() async {
    if (_db == null) return;
    try {
      final paths = await CsvExportService(_db!).exportAllTables();
      if (mounted) {
        await showCsvExportSuccessDialog(context, paths);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }
}

class _MetadataStrip extends StatelessWidget {
  final BackupMetadata metadata;

  const _MetadataStrip({required this.metadata});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Wrap(
        spacing: 16,
        runSpacing: 4,
        children: [
          Text('v${metadata.appVersion}'),
          Text('Schema ${metadata.databaseSchema}'),
          Text('${metadata.customers} customers'),
          Text('${metadata.deliveries} deliveries'),
          Text(metadata.databaseSize),
        ],
      ),
    );
  }
}

class _SimpleList extends StatelessWidget {
  final Future<List<String>> Function() loader;

  const _SimpleList({required this.loader});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: loader(),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snap.data ?? [];
        if (items.isEmpty) {
          return const Center(child: Text('No records'));
        }
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (_, i) => ListTile(
            dense: true,
            title: Text(items[i]),
          ),
        );
      },
    );
  }
}

class _MoreTab extends StatelessWidget {
  final AppDatabase db;

  const _MoreTab({required this.db});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<(int, int, int)>(
      future: () async {
        final expenses = await db.expensesDao.getAll();
        final suppliers = await db.suppliersDao.getAll();
        final bottles = await db.bottleTransactionsDao.getAll();
        return (expenses.length, suppliers.length, bottles.length);
      }(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final (expenses, suppliers, bottles) = snap.data!;
        return ListView(
          children: [
            ListTile(title: Text('Expenses ($expenses)')),
            ListTile(title: Text('Suppliers ($suppliers)')),
            ListTile(title: Text('Bottle Ledger ($bottles)')),
          ],
        );
      },
    );
  }
}

class _ActionBar extends StatelessWidget {
  final VoidCallback onExportCsv;
  final VoidCallback onShareBackup;

  const _ActionBar({
    required this.onExportCsv,
    required this.onShareBackup,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onExportCsv,
                icon: const Icon(Icons.download_outlined),
                label: const Text('Export CSV'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onShareBackup,
                icon: const Icon(Icons.backup_outlined),
                label: const Text('Share Backup'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
