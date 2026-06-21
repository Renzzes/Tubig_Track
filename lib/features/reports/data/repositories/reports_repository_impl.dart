import '../../../../core/database/app_database.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/expense_category_utils.dart';
import '../../domain/entities/report_summary.dart';
import '../../domain/repositories/reports_repository.dart';
import '../../../inventory/data/repositories/inventory_repository_impl.dart';
import '../../../savings/data/repositories/savings_repository_impl.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final AppDatabase _db;

  ReportsRepositoryImpl(this._db);

  @override
  Future<ReportSummary> getReport(ReportPeriod period) async {
    final now = DateTime.now();
    DateTime start;
    DateTime end;

    switch (period) {
      case ReportPeriod.daily:
        start = DateFormatter.startOfDay(now);
        end = DateFormatter.endOfDay(now);
      case ReportPeriod.weekly:
        start = DateFormatter.startOfWeek(now);
        end = DateFormatter.endOfWeek(now);
      case ReportPeriod.monthly:
        start = DateFormatter.startOfMonth(now);
        end = DateFormatter.endOfMonth(now);
      case ReportPeriod.yearly:
        start = DateFormatter.startOfYear(now);
        end = DateFormatter.endOfYear(now);
    }

    return _buildReport(period, start, end);
  }

  @override
  Future<ReportSummary> getCustomReport(DateTime start, DateTime end) async {
    return _buildReport(ReportPeriod.daily, start, end);
  }

  Future<ReportSummary> _buildReport(
    ReportPeriod period,
    DateTime start,
    DateTime end,
  ) async {
    final deliverySales =
        await _db.deliveriesDao.getTotalSalesForDateRange(start, end);
    final dispenserSales =
        await _db.dispenserSalesDao.getTotalForDateRange(start, end);
    final totalSales = deliverySales + dispenserSales;

    final expenseRows = await _db.expensesDao.getByDateRange(start, end);
    final expenseData = expenseRows
        .map((e) => (category: e.category, amount: e.amount))
        .toList();

    final suppliesExpenses = ExpenseCategoryUtils.sumForGroup(
      expenseData,
      ExpenseCategoryUtils.supplies,
    );
    final otherSuppliesExpenses = ExpenseCategoryUtils.sumForGroup(
      expenseData,
      ExpenseCategoryUtils.otherSupplies,
    );
    final totalSuppliesPurchased = suppliesExpenses + otherSuppliesExpenses;
    final operationsExpenses = ExpenseCategoryUtils.sumForGroup(
      expenseData,
      ExpenseCategoryUtils.operations,
    );
    final maintenanceExpenses = ExpenseCategoryUtils.sumForGroup(
      expenseData,
      ExpenseCategoryUtils.maintenance,
    );
    final utilitiesExpenses = ExpenseCategoryUtils.sumForGroup(
      expenseData,
      ExpenseCategoryUtils.utilities,
    );
    final miscellaneousExpenses = ExpenseCategoryUtils.sumForGroup(
      expenseData,
      ExpenseCategoryUtils.miscellaneous,
    );
    final totalExpenses = expenseData.fold(0.0, (s, e) => s + e.amount);

    final suppliesDetails = <SupplyDetailLine>[];
    final otherSuppliesDetails = <SupplyDetailLine>[];
    for (final e in expenseRows) {
      final group = ExpenseCategoryUtils.reportGroupFor(e.category);
      final desc = e.description?.isNotEmpty == true
          ? e.description!
          : (e.notes?.isNotEmpty == true ? e.notes! : e.category);
      final line = SupplyDetailLine(
        description: desc,
        amount: e.amount,
        supplier: e.supplier,
      );
      if (group == ExpenseCategoryUtils.supplies) {
        suppliesDetails.add(line);
      } else if (group == ExpenseCategoryUtils.otherSupplies) {
        otherSuppliesDetails.add(line);
      }
    }

    final paymentsReceived =
        await _db.paymentsDao.getTotalForDateRange(start, end);

    final deliveries = await _db.deliveriesDao.getByDateRange(start, end);
    final totalBottles =
        deliveries.fold<int>(0, (sum, d) => sum + d.quantity);

    final savingsRepo = SavingsRepositoryImpl(_db);
    final savingsSummary = await savingsRepo.getSummary();
    final manualInPeriod =
        await _db.savingsDao.getTotalContributionsForDateRange(start, end);

    final businessSavings =
        savingsSummary.currentSavings - savingsSummary.manualAdditions;
    final netSavings = savingsSummary.currentSavings;

    final inventory = await InventoryRepositoryImpl(_db).getSummary();
    final auditSummary = await InventoryRepositoryImpl(_db).getAuditSummary();
    final linkedBottleIds =
        await _db.supplyPurchasesDao.getLinkedBottleTransactionIds();
    final bottleTxsInPeriod =
        await _db.bottleTransactionsDao.getByDateRange(start, end);

    var periodPurchasedNewBottles = 0;
    var periodDonatedBottles = 0;
    var periodDamagedBottles = 0;
    var periodMissingBottles = 0;
    for (final t in bottleTxsInPeriod) {
      switch (t.transactionType) {
        case 'purchase':
        case 'added':
          if (linkedBottleIds.contains(t.id)) break;
          periodPurchasedNewBottles += t.quantity;
        case 'donation':
          periodDonatedBottles += t.quantity;
        case 'damaged':
          periodDamagedBottles += t.quantity;
        case 'missing':
          periodMissingBottles += t.quantity;
      }
    }

    final depositHeld = await _db.customerDepositsDao.getTotalDepositsHeld();
    final depositCustomers =
        await _db.customerDepositsDao.getCustomersWithDepositsCount();
    final depositAdded = await _db.customerDepositsDao.getTotalAdded();
    final depositUsed = await _db.customerDepositsDao.getTotalUsed();

    return ReportSummary(
      period: period,
      startDate: start,
      endDate: end,
      deliverySales: deliverySales,
      dispenserSales: dispenserSales,
      totalSales: totalSales,
      suppliesExpenses: suppliesExpenses,
      otherSuppliesExpenses: otherSuppliesExpenses,
      totalSuppliesPurchased: totalSuppliesPurchased,
      operationsExpenses: operationsExpenses,
      maintenanceExpenses: maintenanceExpenses,
      utilitiesExpenses: utilitiesExpenses,
      miscellaneousExpenses: miscellaneousExpenses,
      totalExpenses: totalExpenses,
      suppliesDetails: suppliesDetails,
      otherSuppliesDetails: otherSuppliesDetails,
      netProfit: totalSales - totalExpenses,
      totalDeliveries: deliveries.length,
      totalBottlesDelivered: totalBottles,
      totalPaymentsReceived: paymentsReceived,
      currentSavings: businessSavings,
      manualSavingsInPeriod: manualInPeriod,
      totalManualSavings: savingsSummary.manualAdditions,
      netSavings: netSavings,
      totalBottlesOwned: inventory.totalBottlesOwned,
      availableBottles: inventory.availableBottles,
      bottlesWithCustomers: inventory.bottlesWithCustomers,
      damagedBottles: inventory.damagedBottles,
      missingBottles: inventory.missingBottles,
      donatedBottles: inventory.donatedBottles,
      periodPurchasedNewBottles: periodPurchasedNewBottles,
      periodDonatedBottles: periodDonatedBottles,
      periodDamagedBottles: periodDamagedBottles,
      periodMissingBottles: periodMissingBottles,
      totalAudits: auditSummary.totalAudits,
      lastAuditDate: auditSummary.lastAuditDate,
      auditMissingBottles: auditSummary.missingBottlesFound,
      totalAdjustmentQuantity: auditSummary.adjustmentQuantity,
      totalDepositsHeld: depositHeld,
      activeCustomersWithDeposits: depositCustomers,
      totalDepositsAdded: depositAdded,
      totalDepositsUsed: depositUsed,
      currentDepositLiability: depositHeld,
    );
  }
}
