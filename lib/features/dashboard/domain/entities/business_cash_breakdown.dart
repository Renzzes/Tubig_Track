/// Snapshot of business cash position for dashboard breakdown.
class BusinessCashBreakdown {
  final double ownerCapital;
  final double accumulatedProfit;
  final double totalBusinessMoney;
  final double savingsAccountBalance;
  final double businessCash;
  final double customerDepositsHeld;
  final double unpaidReceivables;
  final double cashAvailable;

  const BusinessCashBreakdown({
    required this.ownerCapital,
    required this.accumulatedProfit,
    required this.totalBusinessMoney,
    required this.savingsAccountBalance,
    required this.businessCash,
    required this.customerDepositsHeld,
    required this.unpaidReceivables,
    required this.cashAvailable,
  });
}
