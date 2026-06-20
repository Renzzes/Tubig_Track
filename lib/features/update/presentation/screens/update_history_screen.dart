import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/update_history_entry.dart';
import '../../utils/release_notes_summary.dart';
import '../providers/update_provider.dart';

class UpdateHistoryScreen extends ConsumerStatefulWidget {
  const UpdateHistoryScreen({super.key});

  @override
  ConsumerState<UpdateHistoryScreen> createState() =>
      _UpdateHistoryScreenState();
}

class _UpdateHistoryScreenState extends ConsumerState<UpdateHistoryScreen> {
  final Map<String, bool> _expandedByKey = {};

  String _entryKey(UpdateHistoryEntry entry) =>
      '${entry.version}_${entry.build}';

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(updateHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Update History')),
      body: historyAsync.when(
        data: (history) {
          if (history.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No update history yet.\nUpdates will appear here after installation.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final entry = history[index];
              final key = _entryKey(entry);
              final isExpanded = _expandedByKey[key] ?? false;

              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < history.length - 1 ? 12 : 0,
                ),
                child: _UpdateHistoryCard(
                  entry: entry,
                  isExpanded: isExpanded,
                  onToggle: () {
                    setState(() {
                      _expandedByKey[key] = !isExpanded;
                    });
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _UpdateHistoryCard extends StatelessWidget {
  final UpdateHistoryEntry entry;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _UpdateHistoryCard({
    required this.entry,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final summary = ReleaseNotesSummary.summarize(entry.releaseNotes);
    final hasNotes = entry.releaseNotes.isNotEmpty;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Version ${entry.version}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Installed ${DateFormat('MMMM d, yyyy').format(entry.installedAt)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (hasNotes) ...[
            const SizedBox(height: 12),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 250),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstCurve: Curves.easeInOut,
              secondCurve: Curves.easeInOut,
              sizeCurve: Curves.easeInOut,
              firstChild: _CollapsedNotesPreview(summary: summary),
              secondChild: _ExpandedNotesContent(notes: entry.releaseNotes),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: onToggle,
                child: Text(isExpanded ? 'View Less' : 'View More'),
              ),
            ),
          ] else
            const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _CollapsedNotesPreview extends StatelessWidget {
  final ({List<String> previewLines, int remainingCount}) summary;

  const _CollapsedNotesPreview({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...summary.previewLines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(line),
            ),
          ),
          if (summary.remainingCount > 0)
            Text(
              '+${summary.remainingCount} more features',
              style: TextStyle(color: Colors.grey[600]),
            ),
        ],
      ),
    );
  }
}

class _ExpandedNotesContent extends StatelessWidget {
  final List<String> notes;

  const _ExpandedNotesContent({required this.notes});

  @override
  Widget build(BuildContext context) {
    final cleaned = ReleaseNotesSummary.cleanLines(notes);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: cleaned
            .map(
              (note) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(child: Text(note)),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
