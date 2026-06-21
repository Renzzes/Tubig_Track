enum ReportPeriod { daily, weekly, monthly, yearly }

class SupplyDetailLine {
  final String description;
  final double amount;
  final String? supplier;

  const SupplyDetailLine({
    required this.description,
    required this.amount,
    this.supplier,
  });
}

class ReportSummary {
  final ReportPeriod period;
  final DateTime startDate;
  final DateTime endDate;

  // Revenue
  final double deliverySales;
  final double dispenserSales;
  final double totalSales;

  // Expenses by category group
  final double suppliesExpenses;
  final double otherSuppliesExpenses;
  final double totalSuppliesPurchased;
  final double operationsExpenses;
  final double maintenanceExpenses;
  final double utilitiesExpenses;
  final double miscellaneousExpenses;
  final double totalExpenses;

  // Supply drill-down
  final List<SupplyDetailLine> suppliesDetails;
  final List<SupplyDetailLine> otherSuppliesDetails;

  // Profit & operations
  final double netProfit;
  final int totalDeliveries;
  final int totalBottlesDelivered;
  final double totalPaymentsReceived;

  // Savings snapshot
  final double currentSavings;
  final double manualSavingsInPeriod;
  final double totalManualSavings;
  final double netSavings;

  // Inventory snapshot
  final int totalBottlesOwned;
  final int availableBottles;
  final int bottlesWithCustomers;
  final int damagedBottles;
  final int missingBottles;
  final int donatedBottles;

  /// Inventory ownership changes within the report period (counts, not pesos).
  final int periodPurchasedNewBottles;
  final int periodDonatedBottles;
  final int periodDamagedBottles;
  final int periodMissingBottles;

  final int totalAudits;
  final DateTime? lastAuditDate;
  final int auditMissingBottles;
  final int totalAdjustmentQuantity;

  // Customer deposits snapshot
  final double totalDepositsHeld;
  final int activeCustomersWithDeposits;
  final double totalDepositsAdded;
  final double totalDepositsUsed;
  final double currentDepositLiability;

  const ReportSummary({
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.deliverySales,
    required this.dispenserSales,
    required this.totalSales,
    required this.suppliesExpenses,
    required this.otherSuppliesExpenses,
    required this.totalSuppliesPurchased,
    required this.operationsExpenses,
    required this.maintenanceExpenses,
    required this.utilitiesExpenses,
    required this.miscellaneousExpenses,
    required this.totalExpenses,
    required this.suppliesDetails,
    required this.otherSuppliesDetails,
    required this.netProfit,
    required this.totalDeliveries,
    required this.totalBottlesDelivered,
    required this.totalPaymentsReceived,
    required this.currentSavings,
    required this.manualSavingsInPeriod,
    required this.totalManualSavings,
    required this.netSavings,
    required this.totalBottlesOwned,
    required this.availableBottles,
    required this.bottlesWithCustomers,
    required this.damagedBottles,
    required this.missingBottles,
    required this.donatedBottles,
    required this.periodPurchasedNewBottles,
    required this.periodDonatedBottles,
    required this.periodDamagedBottles,
    required this.periodMissingBottles,
    required this.totalAudits,
    required this.lastAuditDate,
    required this.auditMissingBottles,
    required this.totalAdjustmentQuantity,
    required this.totalDepositsHeld,
    required this.activeCustomersWithDeposits,
    required this.totalDepositsAdded,
    required this.totalDepositsUsed,
    required this.currentDepositLiability,
  });
}
