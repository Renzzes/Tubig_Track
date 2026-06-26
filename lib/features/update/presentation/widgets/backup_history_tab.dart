import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/services/backup_event_log_service.dart';
import '../providers/backup_monitoring_provider.dart';

class BackupHistoryTab extends ConsumerWidget {
  const BackupHistoryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(backupEventHistoryProvider);

    return historyAsync.when(
      data: (events) {
        if (events.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No backup activity recorded yet.\n\nBackup, restore, and '
                'storage events will appear here.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            final showDateHeader = index == 0 ||
                !_sameDay(event.occurredAt, events[index - 1].occurredAt);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showDateHeader)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Text(
                      _dayLabel(event.occurredAt),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ListTile(
                  leading: Icon(
                    event.success ? Icons.check_circle : Icons.warning_amber,
                    color: event.success
                        ? Colors.green.shade700
                        : Colors.orange.shade800,
                  ),
                  title: Text(DateFormat('h:mm a').format(event.occurredAt)),
                  subtitle: Text(
                    event.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  isThreeLine: event.detail != null,
                  trailing: event.detail != null
                      ? null
                      : const Icon(Icons.chevron_right, size: 18),
                ),
                if (event.detail != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(72, 0, 16, 8),
                    child: Text(
                      event.detail!,
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                  ),
                const Divider(height: 1, indent: 16, endIndent: 16),
              ],
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _dayLabel(DateTime date) {
    final now = DateTime.now();
    if (_sameDay(date, now)) return 'Today';
    final yesterday = now.subtract(const Duration(days: 1));
    if (_sameDay(date, yesterday)) return 'Yesterday';
    return DateFormat('MMMM d').format(date);
  }
}
