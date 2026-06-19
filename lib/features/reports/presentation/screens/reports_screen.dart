import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart' as xl;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../domain/entities/report_summary.dart';
import '../providers/reports_provider.dart';
import '../widgets/report_period_selector.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(selectedPeriodProvider);
    final reportAsync = ref.watch(reportSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          reportAsync.when(
            data: (r) => PopupMenuButton<String>(
              icon: const Icon(Icons.download_outlined),
              onSelected: (value) {
                if (value == 'pdf') _exportPDF(context, r);
                if (value == 'excel') _exportExcel(context, r);
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'pdf',
                  child: Row(
                    children: [
                      Icon(Icons.picture_as_pdf_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Export as PDF'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'excel',
                  child: Row(
                    children: [
                      Icon(Icons.table_chart_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Export as Excel'),
                    ],
                  ),
                ),
              ],
            ),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
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
          const SizedBox(height: 8),
          Expanded(
            child: reportAsync.when(
              data: (report) => _ReportContent(report: report),
              loading: () => const LoadingOverlay(),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportPDF(BuildContext context, ReportSummary report) async {
    try {
      final pdf = pw.Document();
      final title =
          '${_periodLabel(report.period)} Report (${DateFormatter.formatShort(report.startDate)} - ${DateFormatter.formatShort(report.endDate)})';

      pdf.addPage(
        pw.Page(
          build: (pw.Context ctx) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'TubigTrack - Financial Report',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(title),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 10),
              _pdfRow('Delivery Sales', CurrencyFormatter.format(report.deliverySales)),
              _pdfRow('Dispenser Sales', CurrencyFormatter.format(report.dispenserSales)),
              _pdfRow('Total Sales', CurrencyFormatter.format(report.totalSales), bold: true),
              pw.SizedBox(height: 10),
              _pdfRow('Total Expenses', CurrencyFormatter.format(report.totalExpenses)),
              pw.SizedBox(height: 10),
              pw.Divider(),
              _pdfRow(
                'Net Profit',
                CurrencyFormatter.format(report.netProfit),
                bold: true,
              ),
              pw.SizedBox(height: 20),
              _pdfRow('Total Deliveries', '${report.totalDeliveries}'),
              _pdfRow('Bottles Delivered', '${report.totalBottlesDelivered}'),
              _pdfRow('Payments Received',
                  CurrencyFormatter.format(report.totalPaymentsReceived)),
            ],
          ),
        ),
      );

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/tubigtrack_report.pdf');
      await file.writeAsBytes(await pdf.save());

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'TubigTrack Report',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting PDF: $e')),
        );
      }
    }
  }

  pw.Widget _pdfRow(String label, String value, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: bold
                ? pw.TextStyle(fontWeight: pw.FontWeight.bold)
                : null,
          ),
          pw.Text(
            value,
            style: bold
                ? pw.TextStyle(fontWeight: pw.FontWeight.bold)
                : null,
          ),
        ],
      ),
    );
  }

  Future<void> _exportExcel(BuildContext context, ReportSummary report) async {
    try {
      final excel = xl.Excel.createExcel();
      final sheet = excel['Report'];

      sheet.appendRow([
        xl.TextCellValue('TubigTrack Report'),
      ]);
      sheet.appendRow([
        xl.TextCellValue(
          '${DateFormatter.formatShort(report.startDate)} - ${DateFormatter.formatShort(report.endDate)}',
        ),
      ]);
      sheet.appendRow([xl.TextCellValue('')]);
      sheet.appendRow([
        xl.TextCellValue('Metric'),
        xl.TextCellValue('Value'),
      ]);
      sheet.appendRow([
        xl.TextCellValue('Delivery Sales'),
        xl.DoubleCellValue(report.deliverySales),
      ]);
      sheet.appendRow([
        xl.TextCellValue('Dispenser Sales'),
        xl.DoubleCellValue(report.dispenserSales),
      ]);
      sheet.appendRow([
        xl.TextCellValue('Total Sales'),
        xl.DoubleCellValue(report.totalSales),
      ]);
      sheet.appendRow([
        xl.TextCellValue('Total Expenses'),
        xl.DoubleCellValue(report.totalExpenses),
      ]);
      sheet.appendRow([
        xl.TextCellValue('Net Profit'),
        xl.DoubleCellValue(report.netProfit),
      ]);
      sheet.appendRow([
        xl.TextCellValue('Total Deliveries'),
        xl.IntCellValue(report.totalDeliveries),
      ]);
      sheet.appendRow([
        xl.TextCellValue('Bottles Delivered'),
        xl.IntCellValue(report.totalBottlesDelivered),
      ]);
      sheet.appendRow([
        xl.TextCellValue('Payments Received'),
        xl.DoubleCellValue(report.totalPaymentsReceived),
      ]);

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/tubigtrack_report.xlsx');
      final bytes = excel.encode();
      if (bytes != null) {
        await file.writeAsBytes(bytes);
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'TubigTrack Report',
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting Excel: $e')),
        );
      }
    }
  }

  String _periodLabel(ReportPeriod period) {
    switch (period) {
      case ReportPeriod.daily:
        return 'Daily';
      case ReportPeriod.weekly:
        return 'Weekly';
      case ReportPeriod.monthly:
        return 'Monthly';
      case ReportPeriod.yearly:
        return 'Yearly';
    }
  }
}

class _ReportContent extends StatelessWidget {
  final ReportSummary report;

  const _ReportContent({required this.report});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(context.pageHorizontalPadding),
      children: [
        // Date range
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.date_range, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${DateFormatter.format(report.startDate)} – ${DateFormatter.format(report.endDate)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Revenue section
        _SectionHeader(title: 'Revenue', icon: Icons.trending_up, color: AppColors.primary),
        const SizedBox(height: 8),
        _MetricRow(
          label: 'Delivery Sales',
          value: CurrencyFormatter.format(report.deliverySales),
        ),
        _MetricRow(
          label: 'Dispenser Sales',
          value: CurrencyFormatter.format(report.dispenserSales),
        ),
        const Divider(),
        _MetricRow(
          label: 'Total Sales',
          value: CurrencyFormatter.format(report.totalSales),
          isTotal: true,
          color: AppColors.primary,
        ),
        const SizedBox(height: 16),

        // Expenses section
        _SectionHeader(title: 'Expenses', icon: Icons.receipt_outlined, color: AppColors.error),
        const SizedBox(height: 8),
        _MetricRow(
          label: 'Total Expenses',
          value: CurrencyFormatter.format(report.totalExpenses),
          color: AppColors.error,
        ),
        const SizedBox(height: 16),

        // Profit section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: report.netProfit >= 0
                ? AppColors.success.withValues(alpha: 0.08)
                : AppColors.error.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: report.netProfit >= 0
                  ? AppColors.success.withValues(alpha: 0.3)
                  : AppColors.error.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Net Profit',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: report.netProfit >= 0
                        ? AppColors.success
                        : AppColors.error,
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  CurrencyFormatter.format(report.netProfit),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: report.netProfit >= 0
                        ? AppColors.success
                        : AppColors.error,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Operations section
        _SectionHeader(
          title: 'Operations',
          icon: Icons.local_shipping_outlined,
          color: AppColors.primary,
        ),
        const SizedBox(height: 8),
        _MetricRow(
          label: 'Total Deliveries',
          value: '${report.totalDeliveries}',
        ),
        _MetricRow(
          label: 'Bottles Delivered',
          value: '${report.totalBottlesDelivered} bottles',
        ),
        _MetricRow(
          label: 'Payments Received',
          value: CurrencyFormatter.format(report.totalPaymentsReceived),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;
  final Color? color;

  const _MetricRow({
    required this.label,
    required this.value,
    this.isTotal = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isTotal ? 15 : 14,
                fontWeight:
                    isTotal ? FontWeight.w600 : FontWeight.normal,
                color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: isTotal ? 16 : 14,
                fontWeight:
                    isTotal ? FontWeight.w700 : FontWeight.w500,
                color: color ?? AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
