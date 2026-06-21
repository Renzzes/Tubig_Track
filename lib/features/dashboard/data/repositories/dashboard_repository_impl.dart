import '../../../../core/database/app_database.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/bottle_verification_utils.dart';
import '../../../customers/data/repositories/customer_repository_impl.dart';
import '../../../inventory/data/repositories/inventory_repository_impl.dart';
import '../../../overdue/data/repositories/overdue_repository_impl.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final AppDatabase _db;

  DashboardRepositoryImpl(this._db);

  @override
  Future<DashboardSummary> getSummary() async {
    final now = DateTime.now();
    final start = DateFormatter.startOfDay(now);
    final end = DateFormatter.endOfDay(now);

    final deliverySales =
        await _db.deliveriesDao.getTotalSalesForDateRange(start, end);
    final dispenserSales =
        await _db.dispenserSalesDao.getTotalForDateRange(start, end);
    final walkInRevenue =
        await _db.walkInSalesDao.getTotalRevenueForDateRange(start, end);
    final todaySales = deliverySales + dispenserSales + walkInRevenue;

    final todayExpenses =
        await _db.expensesDao.getTotalForDateRange(start, end);
    final todayProfit = todaySales - todayExpenses;

    final todayDeliveriesCount = await _db.deliveriesDao.getTodayCount();

    final inventory = await InventoryRepositoryImpl(_db).getSummary();
    final auditSummary = await InventoryRepositoryImpl(_db).getAuditSummary();

    final unpaidReceivables = await _db.deliveriesDao.getTotalReceivables();
    final totalCustomers = await _db.customersDao.getCount();

    final overdueRepo = OverdueRepositoryImpl(_db);
    final overdueSummary = await overdueRepo.getSummary();

    final upcomingRows = await _db.deliveriesDao.getUpcomingForDashboard();
    final allCustomers = await _db.customersDao.watchAll().first;
    final customerMap = {for (final c in allCustomers) c.id: c.name};

    final upcomingDeliveries = upcomingRows
        .map(
          (row) => UpcomingDeliveryItem(
            customerId: row.customerId,
            customerName: customerMap[row.customerId] ?? 'Unknown',
            deliveryDate: row.deliveryDate,
            deliveryTime: row.deliveryTime,
            quantity: row.quantity,
          ),
        )
        .toList();

    final customerDepositsHeld =
        await _db.customerDepositsDao.getTotalDepositsHeld();

    final domainCustomers = await CustomerRepositoryImpl(_db).getAll();
    final verification = BottleVerificationUtils.summarize(domainCustomers);
    final bottleBalances =
        await _db.bottleTransactionsDao.getCustomerBottleBalances();

    var customersWithMissingBottles = 0;
    for (final c in domainCustomers) {
      final held = bottleBalances[c.id] ?? 0;
      final variance = c.bottleVariance(held);
      if (variance != null && variance < 0) {
        customersWithMissingBottles++;
      }
    }

    final auditRecommended = auditSummary.lastAuditDate == null ||
        DateTime.now().difference(auditSummary.lastAuditDate!).inDays >= 30;

    final todayWalkInCount =
        await _db.walkInSalesDao.getCountForDateRange(start, end);
    final todayWalkInBottles =
        await _db.walkInSalesDao.totalBottlesForDateRange(start, end);

    return DashboardSummary(
      todaySales: todaySales,
      todayExpenses: todayExpenses,
      todayProfit: todayProfit,
      todayDeliveriesCount: todayDeliveriesCount,
      availableBottles: inventory.availableBottles,
      borrowedBottles: inventory.bottlesWithCustomers,
      unpaidReceivables: unpaidReceivables,
      totalCustomers: totalCustomers,
      overdueCustomerCount: overdueSummary.customerCount,
      overdueTotalAmount: overdueSummary.totalAmount,
      lastInventoryAuditDate: auditSummary.lastAuditDate,
      customerDepositsHeld: customerDepositsHeld,
      upcomingDeliveries: upcomingDeliveries,
      customersNeedingReconciliation: verification.needsReconciliation,
      customersWithMissingBottles: customersWithMissingBottles,
      inventoryAuditRecommended: auditRecommended,
      todayWalkInSalesCount: todayWalkInCount,
      todayWalkInRevenue: walkInRevenue,
      todayWalkInBottles: todayWalkInBottles,
    );
  }
}
