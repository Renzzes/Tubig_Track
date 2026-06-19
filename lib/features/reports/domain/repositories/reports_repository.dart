import '../entities/report_summary.dart';

abstract class ReportsRepository {
  Future<ReportSummary> getReport(ReportPeriod period);
  Future<ReportSummary> getCustomReport(DateTime start, DateTime end);
}
