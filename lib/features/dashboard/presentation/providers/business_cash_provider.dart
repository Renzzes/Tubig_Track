import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../savings/presentation/providers/savings_provider.dart';
import '../../domain/entities/business_cash_breakdown.dart';
import 'dashboard_provider.dart';

final businessCashBreakdownProvider =
    FutureProvider<BusinessCashBreakdown>((ref) async {
  ref.watch(savingsSummaryProvider);
  ref.watch(dashboardSummaryProvider);
  final savings = await ref.read(savingsSummaryProvider.future);
  final dashboard = await ref.read(dashboardSummaryProvider.future);
  return BusinessCashBreakdown(
    ownerCapital: savings.ownerCapital,
    accumulatedProfit: savings.accumulatedProfit,
    totalBusinessMoney: savings.totalBusinessMoney,
    savingsAccountBalance: savings.savingsAccountBalance,
    businessCash: savings.businessCash,
    customerDepositsHeld: dashboard.customerDepositsHeld,
    unpaidReceivables: dashboard.unpaidReceivables,
    cashAvailable: savings.businessCash - dashboard.customerDepositsHeld,
  );
});
