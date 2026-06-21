import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
              pw.Text('Revenue', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              _pdfRow('Delivery Revenue', CurrencyFormatter.format(report.deliverySales)),
              _pdfRow('Dispenser Revenue', CurrencyFormatter.format(report.dispenserSales)),
              _pdfRow('Total Sales', CurrencyFormatter.format(report.totalSales), bold: true),
              pw.SizedBox(height: 10),
              pw.Text('Supplies Purchased', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              _pdfRow('Supplies', CurrencyFormatter.format(report.suppliesExpenses)),
              _pdfRow('Other Supplies', CurrencyFormatter.format(report.otherSuppliesExpenses)),
              _pdfRow('Total Supplies Purchased',
                  CurrencyFormatter.format(report.totalSuppliesPurchased), bold: true),
              pw.SizedBox(height: 10),
              pw.Text('Expenses', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              _pdfRow('Operations', CurrencyFormatter.format(report.operationsExpenses)),
              _pdfRow('Maintenance', CurrencyFormatter.format(report.maintenanceExpenses)),
              _pdfRow('Utilities', CurrencyFormatter.format(report.utilitiesExpenses)),
              _pdfRow('Miscellaneous', CurrencyFormatter.format(report.miscellaneousExpenses)),
              _pdfRow('Total Expenses', CurrencyFormatter.format(report.totalExpenses), bold: true),
              pw.SizedBox(height: 10),
              pw.Text('Savings Summary', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              _pdfRow('Current Savings', CurrencyFormatter.format(report.currentSavings)),
              _pdfRow('Manual Savings Additions',
                  CurrencyFormatter.format(report.totalManualSavings)),
              _pdfRow('Net Savings', CurrencyFormatter.format(report.netSavings), bold: true),
              pw.SizedBox(height: 10),
              pw.Divider(),
              _pdfRow('Net Profit', CurrencyFormatter.format(report.netProfit), bold: true),
              pw.SizedBox(height: 10),
              pw.Text(
                'Inventory Ownership Changes',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              _pdfRow(
                'Purchased New Bottles',
                '+${report.periodPurchasedNewBottles}',
              ),
              _pdfRow(
                'Donated Bottles',
                '-${report.periodDonatedBottles}',
              ),
              _pdfRow(
                'Damaged Bottles',
                '-${report.periodDamagedBottles}',
              ),
              _pdfRow(
                'Missing Bottles',
                '-${report.periodMissingBottles}',
              ),
              pw.SizedBox(height: 10),
              pw.Text('Inventory', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              _pdfRow('Total Bottles Owned', '${report.totalBottlesOwned}'),
              _pdfRow('Filled Bottles Available', '${report.availableBottles}'),
              _pdfRow('Bottles With Customers', '${report.bottlesWithCustomers}'),
              _pdfRow('Damaged Bottles', '${report.damagedBottles}'),
              _pdfRow('Missing Bottles', '${report.missingBottles}'),
              _pdfRow('Donated Bottles', '${report.donatedBottles}'),
              _pdfRow('Inventory Audits', '${report.totalAudits}'),
              _pdfRow(
                'Last Audit',
                report.lastAuditDate != null
                    ? DateFormatter.format(report.lastAuditDate!)
                    : 'Never',
              ),
              _pdfRow('Missing Bottles Found', '${report.auditMissingBottles}'),
              _pdfRow(
                'Adjustment Quantity',
                '${report.totalAdjustmentQuantity >= 0 ? '+' : ''}${report.totalAdjustmentQuantity}',
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Customer Deposits',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              _pdfRow(
                'Total Deposits Held',
                CurrencyFormatter.format(report.totalDepositsHeld),
              ),
              _pdfRow(
                'Active Customers With Deposits',
                '${report.activeCustomersWithDeposits}',
              ),
              _pdfRow(
                'Total Deposits Added',
                CurrencyFormatter.format(report.totalDepositsAdded),
              ),
              _pdfRow(
                'Total Deposits Used',
                CurrencyFormatter.format(report.totalDepositsUsed),
              ),
              _pdfRow(
                'Current Deposit Liability',
                CurrencyFormatter.format(report.currentDepositLiability),
              ),
              pw.SizedBox(height: 10),
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
      sheet.appendRow([xl.TextCellValue('Revenue')]);
      sheet.appendRow([
        xl.TextCellValue('Delivery Revenue'),
        xl.DoubleCellValue(report.deliverySales),
      ]);
      sheet.appendRow([
        xl.TextCellValue('Dispenser Revenue'),
        xl.DoubleCellValue(report.dispenserSales),
      ]);
      sheet.appendRow([
        xl.TextCellValue('Total Sales'),
        xl.DoubleCellValue(report.totalSales),
      ]);
      sheet.appendRow([xl.TextCellValue('Supplies Purchased')]);
      sheet.appendRow([
        xl.TextCellValue('Supplies'),
        xl.DoubleCellValue(report.suppliesExpenses),
      ]);
      sheet.appendRow([
        xl.TextCellValue('Other Supplies'),
        xl.DoubleCellValue(report.otherSuppliesExpenses),
      ]);
      sheet.appendRow([
        xl.TextCellValue('Total Supplies Purchased'),
        xl.DoubleCellValue(report.totalSuppliesPurchased),
      ]);
      sheet.appendRow([xl.TextCellValue('Expenses')]);
      sheet.appendRow([
        xl.TextCellValue('Operations'),
        xl.DoubleCellValue(report.operationsExpenses),
      ]);
      sheet.appendRow([
        xl.TextCellValue('Maintenance'),
        xl.DoubleCellValue(report.maintenanceExpenses),
      ]);
      sheet.appendRow([
        xl.TextCellValue('Utilities'),
        xl.DoubleCellValue(report.utilitiesExpenses),
      ]);
      sheet.appendRow([
        xl.TextCellValue('Miscellaneous'),
        xl.DoubleCellValue(report.miscellaneousExpenses),
      ]);
      sheet.appendRow([
        xl.TextCellValue('Total Expenses'),
        xl.DoubleCellValue(report.totalExpenses),
      ]);
      sheet.appendRow([xl.TextCellValue('Savings Summary')]);
      sheet.appendRow([
        xl.TextCellValue('Current Savings'),
        xl.DoubleCellValue(report.currentSavings),
      ]);
      sheet.appendRow([
        xl.TextCellValue('Manual Savings Additions'),
        xl.DoubleCellValue(report.totalManualSavings),
      ]);
      sheet.appendRow([
        xl.TextCellValue('Net Savings'),
        xl.DoubleCellValue(report.netSavings),
      ]);
      sheet.appendRow([
        xl.TextCellValue('Net Profit'),
        xl.DoubleCellValue(report.netProfit),
      ]);
      sheet.appendRow([xl.TextCellValue('Inventory Ownership Changes')]);
      sheet.appendRow([
        xl.TextCellValue('Purchased New Bottles'),
        xl.TextCellValue('+${report.periodPurchasedNewBottles}'),
      ]);
      sheet.appendRow([
        xl.TextCellValue('Donated Bottles'),
        xl.TextCellValue('-${report.periodDonatedBottles}'),
      ]);
      sheet.appendRow([
        xl.TextCellValue('Damaged Bottles'),
        xl.TextCellValue('-${report.periodDamagedBottles}'),
      ]);
      sheet.appendRow([
        xl.TextCellValue('Missing Bottles'),
        xl.TextCellValue('-${report.periodMissingBottles}'),
      ]);
      sheet.appendRow([xl.TextCellValue('Inventory')]);
      sheet.appendRow([
        xl.TextCellValue('Total Bottles Owned'),
        xl.IntCellValue(report.totalBottlesOwned),
      ]);
      sheet.appendRow([
        xl.TextCellValue('Filled Bottles Available'),
        xl.IntCellValue(report.availableBottles),
      ]);
      sheet.appendRow([
        xl.TextCellValue('Bottles With Customers'),
        xl.IntCellValue(report.bottlesWithCustomers),
      ]);
      sheet.appendRow([
        xl.TextCellValue('Damaged Bottles'),
        xl.IntCellValue(report.damagedBottles),
      ]);
      sheet.appendRow([
        xl.TextCellValue('Missing Bottles'),
        xl.IntCellValue(report.missingBottles),
      ]);
      sheet.appendRow([
        xl.TextCellValue('Donated Bottles'),
        xl.IntCellValue(report.donatedBottles),
      ]);
      sheet.appendRow([
        xl.TextCellValue('Inventory Audits'),
        xl.IntCellValue(report.totalAudits),
      ]);
      sheet.appendRow([
        xl.TextCellValue('Last Audit'),
        xl.TextCellValue(
          report.lastAuditDate != null
              ? DateFormatter.format(report.lastAuditDate!)
              : 'Never',
        ),
      ]);
      sheet.appendRow([
        xl.TextCellValue('Missing Bottles Found'),
        xl.IntCellValue(report.auditMissingBottles),
      ]);
      sheet.appendRow([
        xl.TextCellValue('Adjustment Quantity'),
        xl.IntCellValue(report.totalAdjustmentQuantity),
      ]);
      sheet.appendRow([xl.TextCellValue('Customer Deposits')]);
      sheet.appendRow([
        xl.TextCellValue('Total Deposits Held'),
        xl.DoubleCellValue(report.totalDepositsHeld),
      ]);
      sheet.appendRow([
        xl.TextCellValue('Active Customers With Deposits'),
        xl.IntCellValue(report.activeCustomersWithDeposits),
      ]);
      sheet.appendRow([
        xl.TextCellValue('Total Deposits Added'),
        xl.DoubleCellValue(report.totalDepositsAdded),
      ]);
      sheet.appendRow([
        xl.TextCellValue('Total Deposits Used'),
        xl.DoubleCellValue(report.totalDepositsUsed),
      ]);
      sheet.appendRow([
        xl.TextCellValue('Current Deposit Liability'),
        xl.DoubleCellValue(report.currentDepositLiability),
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

class _ReportContent extends ConsumerWidget {
  final ReportSummary report;

  const _ReportContent({required this.report});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          label: 'Delivery Revenue',
          value: CurrencyFormatter.format(report.deliverySales),
        ),
        _MetricRow(
          label: 'Dispenser Revenue',
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
          label: 'Operations',
          value: CurrencyFormatter.format(report.operationsExpenses),
        ),
        _MetricRow(
          label: 'Maintenance',
          value: CurrencyFormatter.format(report.maintenanceExpenses),
        ),
        _MetricRow(
          label: 'Utilities',
          value: CurrencyFormatter.format(report.utilitiesExpenses),
        ),
        _MetricRow(
          label: 'Miscellaneous',
          value: CurrencyFormatter.format(report.miscellaneousExpenses),
        ),
        const Divider(),
        _MetricRow(
          label: 'Total Expenses',
          value: CurrencyFormatter.format(report.totalExpenses),
          isTotal: true,
          color: AppColors.error,
        ),
        const SizedBox(height: 16),

        // Supplies Purchased section
        _SectionHeader(
          title: 'Supplies Purchased',
          icon: Icons.inventory_outlined,
          color: AppColors.warning,
        ),
        const SizedBox(height: 8),
        _MetricRow(
          label: 'Supplies',
          value: CurrencyFormatter.format(report.suppliesExpenses),
        ),
        if (report.suppliesDetails.isNotEmpty) ...[
          const SizedBox(height: 4),
          ...report.suppliesDetails.map(
            (d) => _DetailRow(
              label: d.description,
              value: CurrencyFormatter.format(d.amount),
              subtitle: d.supplier,
            ),
          ),
        ],
        const SizedBox(height: 8),
        _MetricRow(
          label: 'Other Supplies',
          value: CurrencyFormatter.format(report.otherSuppliesExpenses),
        ),
        if (report.otherSuppliesDetails.isNotEmpty) ...[
          const SizedBox(height: 4),
          ...report.otherSuppliesDetails.map(
            (d) => _DetailRow(
              label: d.description,
              value: CurrencyFormatter.format(d.amount),
              subtitle: d.supplier,
            ),
          ),
        ],
        const SizedBox(height: 8),
        const Text(
          'Supply Purchase Details',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        if (report.otherSuppliesDetails.isEmpty && report.suppliesDetails.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'No supply purchase details for this period',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ),
        const Divider(),
        _MetricRow(
          label: 'Total Supplies Purchased',
          value: CurrencyFormatter.format(report.totalSuppliesPurchased),
          isTotal: true,
          color: AppColors.warning,
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => context.push('/reports/supplier-summary'),
          icon: const Icon(Icons.store_outlined, size: 18),
          label: const Text('View Supplier Summary'),
        ),
        const SizedBox(height: 16),

        // Savings section
        _SectionHeader(
          title: 'Savings Summary',
          icon: Icons.savings_outlined,
          color: AppColors.success,
        ),
        const SizedBox(height: 8),
        _MetricRow(
          label: 'Current Savings',
          value: CurrencyFormatter.format(report.currentSavings),
        ),
        _MetricRow(
          label: 'Manual Savings Additions',
          value: CurrencyFormatter.format(report.totalManualSavings),
        ),
        if (report.manualSavingsInPeriod > 0)
          _MetricRow(
            label: 'Manual Additions (This Period)',
            value: CurrencyFormatter.format(report.manualSavingsInPeriod),
          ),
        const Divider(),
        _MetricRow(
          label: 'Net Savings',
          value: CurrencyFormatter.format(report.netSavings),
          isTotal: true,
          color: AppColors.success,
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

        _SectionHeader(
          title: 'Inventory Ownership Changes',
          icon: Icons.add_circle_outline,
          color: AppColors.primary,
        ),
        const SizedBox(height: 8),
        _MetricRow(
          label: 'Purchased New Bottles',
          value: '+${report.periodPurchasedNewBottles}',
        ),
        _MetricRow(
          label: 'Donated Bottles',
          value: '-${report.periodDonatedBottles}',
        ),
        _MetricRow(
          label: 'Damaged Bottles',
          value: '-${report.periodDamagedBottles}',
        ),
        _MetricRow(
          label: 'Missing Bottles',
          value: '-${report.periodMissingBottles}',
        ),
        const SizedBox(height: 16),

        // Inventory snapshot
        _SectionHeader(
          title: 'Inventory',
          icon: Icons.inventory_2_outlined,
          color: AppColors.primary,
        ),
        const SizedBox(height: 8),
        _MetricRow(
          label: 'Total Bottles Owned',
          value: '${report.totalBottlesOwned}',
        ),
        _MetricRow(
          label: 'Filled Bottles Available',
          value: '${report.availableBottles}',
        ),
        _MetricRow(
          label: 'Bottles With Customers',
          value: '${report.bottlesWithCustomers}',
        ),
        _MetricRow(
          label: 'Damaged Bottles',
          value: '${report.damagedBottles}',
        ),
        _MetricRow(
          label: 'Missing Bottles',
          value: '${report.missingBottles}',
        ),
        _MetricRow(
          label: 'Donated Bottles',
          value: '${report.donatedBottles}',
        ),
        _MetricRow(
          label: 'Inventory Audits',
          value: '${report.totalAudits}',
        ),
        _MetricRow(
          label: 'Last Audit',
          value: report.lastAuditDate != null
              ? DateFormatter.format(report.lastAuditDate!)
              : 'Never',
        ),
        _MetricRow(
          label: 'Missing Bottles Found',
          value: '${report.auditMissingBottles}',
        ),
        _MetricRow(
          label: 'Adjustment Quantity',
          value:
              '${report.totalAdjustmentQuantity >= 0 ? '+' : ''}${report.totalAdjustmentQuantity}',
        ),
        const SizedBox(height: 16),

        _SectionHeader(
          title: 'Customer Deposits',
          icon: Icons.savings_outlined,
          color: AppColors.primary,
        ),
        const SizedBox(height: 8),
        _MetricRow(
          label: 'Total Deposits Held',
          value: CurrencyFormatter.format(report.totalDepositsHeld),
        ),
        _MetricRow(
          label: 'Active Customers With Deposits',
          value: '${report.activeCustomersWithDeposits}',
        ),
        _MetricRow(
          label: 'Total Deposits Added',
          value: CurrencyFormatter.format(report.totalDepositsAdded),
        ),
        _MetricRow(
          label: 'Total Deposits Used',
          value: CurrencyFormatter.format(report.totalDepositsUsed),
        ),
        _MetricRow(
          label: 'Current Deposit Liability',
          value: CurrencyFormatter.format(report.currentDepositLiability),
        ),
        const SizedBox(height: 32),

        // Delivery activity section
        _SectionHeader(
          title: 'Delivery Activity',
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;

  const _DetailRow({
    required this.label,
    required this.value,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 13),
                ),
                if (subtitle != null && subtitle!.isNotEmpty)
                  Text(
                    subtitle!,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
              ],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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
