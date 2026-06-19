import '../../../../core/database/app_database.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/report_summary.dart';
import '../../domain/repositories/reports_repository.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final AppDatabase _db;

  ReportsRepositoryImpl(this._db);

  @override
  Future<ReportSummary> getReport(ReportPeriod period) async {
    final now = DateTime.now();
    DateTime start;
    DateTime end;

    switch (period) {
      case ReportPeriod.daily:
        start = DateFormatter.startOfDay(now);
        end = DateFormatter.endOfDay(now);
      case ReportPeriod.weekly:
        start = DateFormatter.startOfWeek(now);
        end = DateFormatter.endOfWeek(now);
      case ReportPeriod.monthly:
        start = DateFormatter.startOfMonth(now);
        end = DateFormatter.endOfMonth(now);
      case ReportPeriod.yearly:
        start = DateFormatter.startOfYear(now);
        end = DateFormatter.endOfYear(now);
    }

    return _buildReport(period, start, end);
  }

  @override
  Future<ReportSummary> getCustomReport(DateTime start, DateTime end) async {
    return _buildReport(ReportPeriod.daily, start, end);
  }

  Future<ReportSummary> _buildReport(
    ReportPeriod period,
    DateTime start,
    DateTime end,
  ) async {
    final deliverySales =
        await _db.deliveriesDao.getTotalSalesForDateRange(start, end);
    final dispenserSales =
        await _db.dispenserSalesDao.getTotalForDateRange(start, end);
    final totalSales = deliverySales + dispenserSales;

    final totalExpenses =
        await _db.expensesDao.getTotalForDateRange(start, end);

    final paymentsReceived =
        await _db.paymentsDao.getTotalForDateRange(start, end);

    final deliveries = await _db.deliveriesDao.getByDateRange(start, end);
    final totalBottles =
        deliveries.fold<int>(0, (sum, d) => sum + d.quantity);

    return ReportSummary(
      period: period,
      startDate: start,
      endDate: end,
      deliverySales: deliverySales,
      dispenserSales: dispenserSales,
      totalSales: totalSales,
      totalExpenses: totalExpenses,
      netProfit: totalSales - totalExpenses,
      totalDeliveries: deliveries.length,
      totalBottlesDelivered: totalBottles,
      totalPaymentsReceived: paymentsReceived,
    );
  }
}
