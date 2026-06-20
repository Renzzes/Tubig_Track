import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../../deliveries/presentation/providers/deliveries_provider.dart';
import '../../../dispenser_sales/presentation/providers/dispenser_sales_provider.dart';
import '../../../expenses/presentation/providers/expenses_provider.dart';
import '../../../savings/presentation/providers/savings_provider.dart';
import '../../../supply_purchases/presentation/providers/supply_purchase_provider.dart';
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

final reportSummaryProvider = FutureProvider<ReportSummary>((ref) async {
  ref.watch(selectedPeriodProvider);
  ref.watch(deliveriesStreamProvider);
  ref.watch(expensesStreamProvider);
  ref.watch(dispenserSalesStreamProvider);
  ref.watch(savingsSummaryProvider);
  ref.watch(supplyPurchasesStreamProvider);
  final period = ref.read(selectedPeriodProvider);
  return ref.watch(reportsRepositoryProvider).getReport(period);
});
