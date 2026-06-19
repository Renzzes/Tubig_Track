enum ReportPeriod { daily, weekly, monthly, yearly }

class ReportSummary {
  final ReportPeriod period;
  final DateTime startDate;
  final DateTime endDate;
  final double deliverySales;
  final double dispenserSales;
  final double totalSales;
  final double totalExpenses;
  final double netProfit;
  final int totalDeliveries;
  final int totalBottlesDelivered;
  final double totalPaymentsReceived;

  const ReportSummary({
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.deliverySales,
    required this.dispenserSales,
    required this.totalSales,
    required this.totalExpenses,
    required this.netProfit,
    required this.totalDeliveries,
    required this.totalBottlesDelivered,
    required this.totalPaymentsReceived,
  });
}
