import 'package:flutter_test/flutter_test.dart';
import 'package:tubig_track/features/dashboard/domain/entities/dashboard_summary.dart';

void main() {
  group('DashboardSummary action alerts (v1.5.0)', () {
    test('hasActionRequired when any alert is active', () {
      const summary = DashboardSummary(
        todaySales: 0,
        todayExpenses: 0,
        todayProfit: 0,
        todayDeliveriesCount: 0,
        availableBottles: 0,
        borrowedBottles: 0,
        unpaidReceivables: 0,
        totalCustomers: 0,
        overdueCustomerCount: 2,
        overdueTotalAmount: 100,
        lastInventoryAuditDate: null,
        customerDepositsHeld: 0,
        upcomingDeliveries: [],
        customersWithMissingBottles: 0,
        inventoryAuditRecommended: false,
        todayWalkInSalesCount: 0,
        todayWalkInRevenue: 0,
        todayWalkInBottles: 0,
      );
      expect(summary.hasActionRequired, isTrue);
    });

    test('hasActionRequired false when all clear', () {
      final summary = DashboardSummary(
        todaySales: 0,
        todayExpenses: 0,
        todayProfit: 0,
        todayDeliveriesCount: 0,
        availableBottles: 0,
        borrowedBottles: 0,
        unpaidReceivables: 0,
        totalCustomers: 0,
        overdueCustomerCount: 0,
        overdueTotalAmount: 0,
        lastInventoryAuditDate: DateTime(2026, 6, 1),
        customerDepositsHeld: 0,
        upcomingDeliveries: [],
        customersWithMissingBottles: 0,
        inventoryAuditRecommended: false,
        todayWalkInSalesCount: 0,
        todayWalkInRevenue: 0,
        todayWalkInBottles: 0,
      );
      expect(summary.hasActionRequired, isFalse);
    });
  });
}
