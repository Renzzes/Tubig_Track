import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/utils/date_formatter.dart';
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

    final initialStr = await _db.settingsDao.getValue(
      AppConstants.settingTotalBottleInventory,
    );
    final initialInventory = int.tryParse(initialStr ?? '') ??
        AppConstants.defaultBottleInventory;

    final borrowed =
        await _db.bottleTransactionsDao.getTotalByType('borrow');
    final returned =
        await _db.bottleTransactionsDao.getTotalByType('return');
    final damaged =
        await _db.bottleTransactionsDao.getTotalByType('damaged');
    final purchased =
        await _db.bottleTransactionsDao.getTotalByType('purchase');

    final totalBottles = initialInventory + purchased - damaged;
    final borrowedOutstanding = (borrowed - returned).clamp(0, 999999);
    final availableBottles =
        (totalBottles - borrowedOutstanding).clamp(0, 999999);

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

    return DashboardSummary(
      todaySales: todaySales,
      todayExpenses: todayExpenses,
      todayProfit: todayProfit,
      todayDeliveriesCount: todayDeliveriesCount,
      availableBottles: availableBottles,
      borrowedBottles: borrowedOutstanding,
      unpaidReceivables: unpaidReceivables,
      totalCustomers: totalCustomers,
      overdueCustomerCount: overdueSummary.customerCount,
      overdueTotalAmount: overdueSummary.totalAmount,
      upcomingDeliveries: upcomingDeliveries,
    );
  }
}
