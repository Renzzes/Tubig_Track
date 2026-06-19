import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../data/repositories/reports_repository_impl.dart';
import '../../domain/entities/report_summary.dart';
import '../../domain/repositories/reports_repository.dart';

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ReportsRepositoryImpl(db);
});

class _SelectedPeriod extends Notifier<ReportPeriod> {
  @override
  ReportPeriod build() => ReportPeriod.daily;

  void select(ReportPeriod period) => state = period;
}

final selectedPeriodProvider =
    NotifierProvider<_SelectedPeriod, ReportPeriod>(_SelectedPeriod.new);

final reportSummaryProvider = FutureProvider<ReportSummary>((ref) {
  final period = ref.watch(selectedPeriodProvider);
  return ref.watch(reportsRepositoryProvider).getReport(period);
});
