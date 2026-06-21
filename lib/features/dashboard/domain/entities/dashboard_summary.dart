class UpcomingDeliveryItem {
  final String customerId;
  final String customerName;
  final DateTime deliveryDate;
  final String? deliveryTime;
  final int quantity;

  const UpcomingDeliveryItem({
    required this.customerId,
    required this.customerName,
    required this.deliveryDate,
    this.deliveryTime,
    required this.quantity,
  });
}

class DashboardSummary {
  final double todaySales;
  final double todayExpenses;
  final double todayProfit;
  final int todayDeliveriesCount;
  final int availableBottles;
  final int borrowedBottles;
  final double unpaidReceivables;
  final int totalCustomers;
  final int overdueCustomerCount;
  final double overdueTotalAmount;
  final DateTime? lastInventoryAuditDate;
  final double customerDepositsHeld;
  final List<UpcomingDeliveryItem> upcomingDeliveries;

  /// Action Required alerts (v1.5.0).
  final int customersNeedingReconciliation;
  final int customersWithMissingBottles;
  final bool inventoryAuditRecommended;

  /// Walk-in operations today (v1.6.0).
  final int todayWalkInSalesCount;
  final double todayWalkInRevenue;
  final int todayWalkInBottles;

  const DashboardSummary({
    required this.todaySales,
    required this.todayExpenses,
    required this.todayProfit,
    required this.todayDeliveriesCount,
    required this.availableBottles,
    required this.borrowedBottles,
    required this.unpaidReceivables,
    required this.totalCustomers,
    required this.overdueCustomerCount,
    required this.overdueTotalAmount,
    required this.lastInventoryAuditDate,
    required this.customerDepositsHeld,
    required this.upcomingDeliveries,
    required this.customersNeedingReconciliation,
    required this.customersWithMissingBottles,
    required this.inventoryAuditRecommended,
    required this.todayWalkInSalesCount,
    required this.todayWalkInRevenue,
    required this.todayWalkInBottles,
  });

  bool get hasActionRequired =>
      customersNeedingReconciliation > 0 ||
      customersWithMissingBottles > 0 ||
      overdueCustomerCount > 0 ||
      inventoryAuditRecommended;
}
