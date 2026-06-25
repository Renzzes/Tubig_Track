enum ReportPeriod { daily, weekly, monthly, yearly }

class WalkInReportLine {
  final DateTime date;
  final String typeLabel;
  final String customerName;
  final int quantity;
  final double amount;

  const WalkInReportLine({
    required this.date,
    required this.typeLabel,
    required this.customerName,
    required this.quantity,
    required this.amount,
  });
}

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

  // Savings snapshot (accumulated profit)
  final double currentSavings;
  final double ownerCapitalInPeriod;
  final double totalOwnerCapital;

  /// Business position snapshot (v1.7.0).
  final double unpaidReceivables;
  final int emptyBottlesReadyForRefill;
  final double savingsAccountBalance;

  // Inventory snapshot
  final int totalBottlesOwned;
  final int availableBottles;
  final int bottlesWithCustomers;
  final int damagedBottles;
  final int missingBottles;
  final int donatedBottles;

  /// Inventory ownership changes within the report period (counts, not pesos).
  final int periodPurchasedNewBottles;
  final int periodSupplierFilledBottlesReceived;
  final int periodFilledBottleAdjustments;
  final int periodDonatedBottles;
  final int periodDamagedBottles;
  final int periodMissingBottles;

  /// Customer-owned bottle activity in period (informational only).
  final int periodCustomerOwnedCollected;
  final int periodCustomerOwnedDelivered;

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

  /// Extended fields for full business report (v1.5.0).
  final int totalCustomerOwnedBottles;
  final String inventoryHealthLabel;
  final int periodCollections;
  final int periodPaymentsCount;
  final int periodSupplierDeliveries;
  final String businessTimelineSummary;

  /// Walk-in operations (v1.6.0).
  final double walkInRevenue;
  final int walkInTransactionCount;
  final int walkInBusinessBottleSalesCount;
  final int walkInCustomerRefillsCount;
  final int walkInExchangeCount;
  final double walkInBusinessBottleRevenue;
  final double walkInRefillRevenue;
  final double walkInExchangeRevenue;
  final List<WalkInReportLine> walkInDetails;

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
    required this.ownerCapitalInPeriod,
    required this.totalOwnerCapital,
    required this.unpaidReceivables,
    required this.emptyBottlesReadyForRefill,
    required this.savingsAccountBalance,
    required this.totalBottlesOwned,
    required this.availableBottles,
    required this.bottlesWithCustomers,
    required this.damagedBottles,
    required this.missingBottles,
    required this.donatedBottles,
    required this.periodPurchasedNewBottles,
    required this.periodSupplierFilledBottlesReceived,
    required this.periodFilledBottleAdjustments,
    required this.periodDonatedBottles,
    required this.periodDamagedBottles,
    required this.periodMissingBottles,
    required this.periodCustomerOwnedCollected,
    required this.periodCustomerOwnedDelivered,
    required this.totalAudits,
    required this.lastAuditDate,
    required this.auditMissingBottles,
    required this.totalAdjustmentQuantity,
    required this.totalDepositsHeld,
    required this.activeCustomersWithDeposits,
    required this.totalDepositsAdded,
    required this.totalDepositsUsed,
    required this.currentDepositLiability,
    required this.totalCustomerOwnedBottles,
    required this.inventoryHealthLabel,
    required this.periodCollections,
    required this.periodPaymentsCount,
    required this.periodSupplierDeliveries,
    required this.businessTimelineSummary,
    required this.walkInRevenue,
    required this.walkInTransactionCount,
    required this.walkInBusinessBottleSalesCount,
    required this.walkInCustomerRefillsCount,
    required this.walkInExchangeCount,
    required this.walkInBusinessBottleRevenue,
    required this.walkInRefillRevenue,
    required this.walkInExchangeRevenue,
    required this.walkInDetails,
  });

  /// Alias for [currentSavings].
  double get accumulatedProfit => currentSavings;

  double get totalBusinessMoney => currentSavings + totalOwnerCapital;

  double get businessCash => totalBusinessMoney - savingsAccountBalance;

  double get cashAvailable => businessCash - currentDepositLiability;
}
