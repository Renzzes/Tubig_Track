import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../reports/presentation/providers/reports_provider.dart';
import '../../../reports/presentation/widgets/report_period_selector.dart';
import '../providers/supply_purchase_provider.dart';

class SupplierSummaryScreen extends ConsumerWidget {
  const SupplierSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(selectedPeriodProvider);
    final reportAsync = ref.watch(reportSummaryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Supplier Summary')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: ReportPeriodSelector(
              selected: period,
              onChanged: (p) {
                ref.read(selectedPeriodProvider.notifier).select(p);
              },
            ),
          ),
          Expanded(
            child: reportAsync.when(
              data: (report) {
                final range = (report.startDate, report.endDate);
                final summaryAsync = ref.watch(supplierSummaryProvider(range));
                return summaryAsync.when(
                  data: (entries) {
                    if (entries.isEmpty) {
                      return Center(
                        child: Text(
                          'No supplier purchases for ${DateFormatter.formatShort(report.startDate)} – ${DateFormatter.formatShort(report.endDate)}',
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Text(
                          '${DateFormatter.format(report.startDate)} – ${DateFormatter.format(report.endDate)}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        ...entries.map(
                          (e) => Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    e.supplierName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _StatChip(
                                          label: 'Purchases',
                                          value: '${e.purchaseCount}',
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _StatChip(
                                          label: 'Total Cost',
                                          value: CurrencyFormatter.format(
                                            e.totalCost,
                                          ),
                                          highlight: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _StatChip({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.primary.withValues(alpha: 0.08)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: highlight ? AppColors.primary : null,
            ),
          ),
        ],
      ),
    );
  }
}
