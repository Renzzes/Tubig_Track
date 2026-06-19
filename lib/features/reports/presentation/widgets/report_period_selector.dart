import 'package:flutter/material.dart';
import '../../domain/entities/report_summary.dart';

class ReportPeriodSelector extends StatelessWidget {
  final ReportPeriod selected;
  final ValueChanged<ReportPeriod> onChanged;

  const ReportPeriodSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ReportPeriod.values.map((period) {
          final isSelected = period == selected;
          final label = _label(period);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) => onChanged(period),
              selectedColor: Theme.of(context).colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: isSelected
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _label(ReportPeriod period) {
    switch (period) {
      case ReportPeriod.daily:
        return 'Today';
      case ReportPeriod.weekly:
        return 'This Week';
      case ReportPeriod.monthly:
        return 'This Month';
      case ReportPeriod.yearly:
        return 'This Year';
    }
  }
}
