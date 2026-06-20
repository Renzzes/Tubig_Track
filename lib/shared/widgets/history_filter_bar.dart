import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Shared filter bar for history/list screens.
class HistoryFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final DateTime? startDate;
  final DateTime? endDate;
  final VoidCallback onDateFilterTap;
  final VoidCallback? onClearDates;
  final Widget? typeFilter;

  const HistoryFilterBar({
    super.key,
    required this.searchController,
    this.startDate,
    this.endDate,
    required this.onDateFilterTap,
    this.onClearDates,
    this.typeFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              isDense: true,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDateFilterTap,
                  icon: const Icon(Icons.date_range, size: 18),
                  label: Text(
                    startDate == null
                        ? 'Date Filter'
                        : '${DateFormat('MMM d').format(startDate!)}${endDate != null ? ' – ${DateFormat('MMM d').format(endDate!)}' : ''}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              if (startDate != null && onClearDates != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onClearDates,
                  icon: const Icon(Icons.clear),
                  tooltip: 'Clear dates',
                ),
              ],
              if (typeFilter != null) ...[
                const SizedBox(width: 8),
                typeFilter!,
              ],
            ],
          ),
        ],
      ),
    );
  }
}

Future<(DateTime?, DateTime?)> showDateRangePickerDialog(
  BuildContext context, {
  DateTime? initialStart,
  DateTime? initialEnd,
}) async {
  final start = await showDatePicker(
    context: context,
    initialDate: initialStart ?? DateTime.now(),
    firstDate: DateTime(2020),
    lastDate: DateTime.now().add(const Duration(days: 365)),
    helpText: 'Start Date',
  );
  if (start == null || !context.mounted) return (null, null);

  final end = await showDatePicker(
    context: context,
    initialDate: initialEnd ?? start,
    firstDate: start,
    lastDate: DateTime.now().add(const Duration(days: 365)),
    helpText: 'End Date',
  );
  return (start, end ?? start);
}

bool isInDateRange(DateTime date, DateTime? start, DateTime? end) {
  if (start == null) return true;
  final d = DateTime(date.year, date.month, date.day);
  final s = DateTime(start.year, start.month, start.day);
  final e = end != null
      ? DateTime(end.year, end.month, end.day)
      : s;
  return !d.isBefore(s) && !d.isAfter(e);
}
