import '../../../../core/database/app_database.dart';
import '../../../../core/utils/date_formatter.dart';
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
    final todaySales = deliverySales + dispenserSales;

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
    );
  }
}
