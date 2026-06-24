import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../utils/currency_formatter.dart';
import '../utils/date_formatter.dart';
import '../../features/reports/domain/entities/report_summary.dart';

/// Builds the full printable business report PDF (v1.5.0).
class BusinessReportPdfBuilder {
  BusinessReportPdfBuilder._();

  static Future<pw.Document> build(ReportSummary report) async {
    final pdf = pw.Document();
    final periodTitle =
        '${_periodLabel(report.period)} (${DateFormatter.formatShort(report.startDate)} – ${DateFormatter.formatShort(report.endDate)})';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (ctx) => [
          pw.Text(
            'TubigTrack — Full Business Report',
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(periodTitle, style: const pw.TextStyle(fontSize: 11)),
          pw.SizedBox(height: 20),
          _section('Business Summary'),
          _row('Revenue (Total Sales)', CurrencyFormatter.format(report.totalSales)),
          _row('Delivery Revenue', CurrencyFormatter.format(report.deliverySales)),
          _row('Dispenser Revenue', CurrencyFormatter.format(report.dispenserSales)),
          _row('Walk-In Revenue', CurrencyFormatter.format(report.walkInRevenue)),
          _row('Expenses', CurrencyFormatter.format(report.totalExpenses)),
          _row('Net Profit', CurrencyFormatter.format(report.netProfit), bold: true),
          _row('Current Savings', CurrencyFormatter.format(report.currentSavings)),
          _row('Net Savings', CurrencyFormatter.format(report.netSavings)),
          _row('Deposits Held', CurrencyFormatter.format(report.totalDepositsHeld)),
          pw.SizedBox(height: 16),
          _section('Inventory Summary'),
          _row('Total Bottles Owned', '${report.totalBottlesOwned}'),
          _row('Filled Bottles Available', '${report.availableBottles}'),
          _row('Bottles With Customers', '${report.bottlesWithCustomers}'),
          _row('Customer-Owned Bottles', '${report.totalCustomerOwnedBottles}'),
          _row('Missing Bottles', '${report.missingBottles}'),
          _row('Damaged Bottles', '${report.damagedBottles}'),
          _row('Inventory Health', report.inventoryHealthLabel, bold: true),
          pw.SizedBox(height: 16),
          _section('Deliveries'),
          _row('Total Deliveries', '${report.totalDeliveries}'),
          _row('Bottles Delivered', '${report.totalBottlesDelivered}'),
          pw.SizedBox(height: 16),
          _section('Collections'),
          _row('Bottles Collected', '${report.periodCollections}'),
          pw.SizedBox(height: 16),
          _section('Payments'),
          _row('Payments Received', CurrencyFormatter.format(report.totalPaymentsReceived)),
          _row('Payment Transactions', '${report.periodPaymentsCount}'),
          pw.SizedBox(height: 16),
          _section('Supplier Deliveries'),
          _row('Filled Bottles Received',
              '+${report.periodSupplierFilledBottlesReceived}'),
          _row('Delivery Count', '${report.periodSupplierDeliveries}'),
          pw.SizedBox(height: 16),
          _section('Inventory Ownership Changes'),
          _row('New Bottles Purchased', '+${report.periodPurchasedNewBottles}'),
          _row('Filled Bottle Adjustments',
              '+${report.periodFilledBottleAdjustments}'),
          if (report.suppliesDetails.isNotEmpty ||
              report.otherSuppliesDetails.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            pw.Text('Purchase Details',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
            ...report.suppliesDetails.map(
              (d) => _row(
                d.description,
                CurrencyFormatter.format(d.amount),
              ),
            ),
            ...report.otherSuppliesDetails.map(
              (d) => _row(
                d.description,
                CurrencyFormatter.format(d.amount),
              ),
            ),
          ],
          pw.SizedBox(height: 16),
          _section('Walk-In Operations Summary'),
          _row('Borrow Bottle Sales', '${report.walkInBusinessBottleSalesCount}'),
          _row('Refill Own Bottle', '${report.walkInCustomerRefillsCount}'),
          _row('Bottle Exchanges', '${report.walkInExchangeCount}'),
          _row('Walk-In Revenue', CurrencyFormatter.format(report.walkInRevenue)),
          _row('Business Bottle Revenue',
              CurrencyFormatter.format(report.walkInBusinessBottleRevenue)),
          _row('Refill Revenue',
              CurrencyFormatter.format(report.walkInRefillRevenue)),
          _row('Exchange Revenue',
              CurrencyFormatter.format(report.walkInExchangeRevenue)),
          _row('Transaction Count', '${report.walkInTransactionCount}'),
          if (report.walkInDetails.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            pw.Text(
              'Walk-In Transactions',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
            ),
            ...report.walkInDetails.take(25).map(
                  (line) => _row(
                    '${DateFormatter.formatShort(line.date)} • ${line.typeLabel} • ${line.customerName}',
                    '${line.quantity} • ${CurrencyFormatter.format(line.amount)}',
                  ),
                ),
          ],
          pw.SizedBox(height: 16),
          _section('Business Timeline Summary'),
          pw.Text(
            report.businessTimelineSummary,
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 24),
          pw.Divider(),
          pw.SizedBox(height: 8),
          pw.Text(
            'Generated by TubigTrack • ${DateFormatter.format(DateTime.now())}',
            style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
        ],
      ),
    );

    return pdf;
  }

  static pw.Widget _section(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Text(
        title,
        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  static pw.Widget _row(String label, String value, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: bold ? pw.FontWeight.bold : null,
              ),
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: bold ? pw.FontWeight.bold : null,
            ),
          ),
        ],
      ),
    );
  }

  static String _periodLabel(ReportPeriod period) {
    switch (period) {
      case ReportPeriod.daily:
        return 'Daily Report';
      case ReportPeriod.weekly:
        return 'Weekly Report';
      case ReportPeriod.monthly:
        return 'Monthly Report';
      case ReportPeriod.yearly:
        return 'Yearly Report';
    }
  }
}
