import '../../../../core/database/app_database.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/expense_category_utils.dart';
import '../../domain/entities/report_summary.dart';
import '../../domain/repositories/reports_repository.dart';
import '../../../inventory/data/repositories/inventory_repository_impl.dart';
import '../../../savings/data/repositories/savings_repository_impl.dart';
import '../../../../core/utils/inventory_health_utils.dart';
import '../../../walk_in_operations/domain/entities/walk_in_sale.dart';
import '../../../customers/data/repositories/customer_repository_impl.dart';

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
    final walkInRevenue =
        await _db.walkInSalesDao.getTotalRevenueForDateRange(start, end);
    final totalSales = deliverySales + dispenserSales + walkInRevenue;

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
    final paymentsInPeriod =
        await _db.paymentsDao.getByDateRange(start, end);

    final deliveries = await _db.deliveriesDao.getByDateRange(start, end);
    final totalBottles =
        deliveries.fold<int>(0, (sum, d) => sum + d.quantity);

    final savingsRepo = SavingsRepositoryImpl(_db);
    final savingsSummary = await savingsRepo.getSummary();
    final ownerCapitalInPeriod =
        await _db.savingsDao.getTotalContributionsForDateRange(start, end);

    final inventory = await InventoryRepositoryImpl(_db).getSummary();
    final auditSummary = await InventoryRepositoryImpl(_db).getAuditSummary();
    final linkedBottleIds =
        await _db.supplyPurchasesDao.getLinkedBottleTransactionIds();
    final bottleTxsInPeriod =
        await _db.bottleTransactionsDao.getByDateRange(start, end);
    final supplyPurchasesInPeriod =
        await _db.supplyPurchasesDao.getByDateRange(start, end);

    var periodPurchasedNewBottles = 0;
    var periodFilledBottleAdjustments = 0;
    var periodDonatedBottles = 0;
    var periodDamagedBottles = 0;
    var periodMissingBottles = 0;
    for (final t in bottleTxsInPeriod) {
      switch (t.transactionType) {
        case 'purchase':
          if (linkedBottleIds.contains(t.id)) break;
          periodPurchasedNewBottles += t.quantity;
        case 'added':
          periodFilledBottleAdjustments += t.quantity;
        case 'adjustment':
          if (t.quantity > 0) {
            periodFilledBottleAdjustments += t.quantity;
          }
        case 'donation':
          periodDonatedBottles += t.quantity;
        case 'damaged':
          periodDamagedBottles += t.quantity;
        case 'missing':
          periodMissingBottles += t.quantity;
      }
    }

    var periodSupplierFilledBottlesReceived = 0;
    for (final sp in supplyPurchasesInPeriod) {
      periodSupplierFilledBottlesReceived += sp.quantity;
    }

    final ownedLogsInPeriod =
        await _db.customerOwnedBottleLogsDao.getByDateRange(start, end);
    var periodCustomerOwnedCollected = 0;
    var periodCustomerOwnedDelivered = 0;
    for (final log in ownedLogsInPeriod) {
      if (log.customerOwnedDelta < 0) {
        periodCustomerOwnedCollected += log.customerOwnedDelta.abs();
      } else if (log.customerOwnedDelta > 0 &&
          log.eventType == 'delivery_filled') {
        periodCustomerOwnedDelivered += log.customerOwnedDelta;
      }
    }

    final depositHeld = await _db.customerDepositsDao.getTotalDepositsHeld();
    final depositCustomers =
        await _db.customerDepositsDao.getCustomersWithDepositsCount();
    final depositAdded = await _db.customerDepositsDao.getTotalAdded();
    final depositUsed = await _db.customerDepositsDao.getTotalUsed();
    final unpaidReceivables = await _db.deliveriesDao.getTotalReceivables();

    final allCustomers = await CustomerRepositoryImpl(_db).getAll();

    var totalCustomerOwned = 0;
    for (final c in allCustomers) {
      totalCustomerOwned += c.customerOwnedBottlesHeld;
    }

    var periodCollections = 0;
    for (final t in bottleTxsInPeriod) {
      if (t.transactionType == 'return') periodCollections += t.quantity;
    }

    final consistency =
        await InventoryRepositoryImpl(_db).validateConsistency();
    final health = InventoryHealthUtils.compute(consistency);
    final healthLabel = InventoryHealthUtils.label(health);

    final timelineSummary =
        '${deliveries.length} deliveries, $periodCollections bottles collected, '
        '${paymentsInPeriod.length} payments, '
        '${supplyPurchasesInPeriod.length} supplier deliveries, '
        '${await _db.walkInSalesDao.getCountForDateRange(start, end)} walk-in operations '
        'in this period.';

    final walkInRows = await _db.walkInSalesDao.getByDateRange(start, end);
    final customerNameMap = {for (final c in allCustomers) c.id: c.name};
    final walkInDetails = walkInRows.map((row) {
      final type = WalkInTypeX.fromStorage(row.walkInType);
      final qty = switch (type) {
        WalkInType.businessBottles => row.businessOwnedQuantity,
        WalkInType.customerRefill => row.customerOwnedQuantity,
        WalkInType.exchange => row.businessOwnedQuantity,
      };
      return WalkInReportLine(
        date: row.date,
        typeLabel: type.label,
        customerName: row.customerId != null
            ? (customerNameMap[row.customerId] ?? WalkInSale.walkInCustomerLabel)
            : WalkInSale.walkInCustomerLabel,
        quantity: qty,
        amount: row.totalAmount,
      );
    }).toList();

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
      currentSavings: savingsSummary.currentSavings,
      ownerCapitalInPeriod: ownerCapitalInPeriod,
      totalOwnerCapital: savingsSummary.ownerCapital,
      unpaidReceivables: unpaidReceivables,
      emptyBottlesReadyForRefill: inventory.emptyBottlesReadyForRefill,
      savingsAccountBalance: savingsSummary.savingsAccountBalance,
      totalBottlesOwned: inventory.totalBottlesOwned,
      availableBottles: inventory.availableBottles,
      bottlesWithCustomers: inventory.bottlesWithCustomers,
      damagedBottles: inventory.damagedBottles,
      missingBottles: inventory.missingBottles,
      donatedBottles: inventory.donatedBottles,
      periodPurchasedNewBottles: periodPurchasedNewBottles,
      periodSupplierFilledBottlesReceived: periodSupplierFilledBottlesReceived,
      periodFilledBottleAdjustments: periodFilledBottleAdjustments,
      periodDonatedBottles: periodDonatedBottles,
      periodDamagedBottles: periodDamagedBottles,
      periodMissingBottles: periodMissingBottles,
      periodCustomerOwnedCollected: periodCustomerOwnedCollected,
      periodCustomerOwnedDelivered: periodCustomerOwnedDelivered,
      totalAudits: auditSummary.totalAudits,
      lastAuditDate: auditSummary.lastAuditDate,
      auditMissingBottles: auditSummary.missingBottlesFound,
      totalAdjustmentQuantity: auditSummary.adjustmentQuantity,
      totalDepositsHeld: depositHeld,
      activeCustomersWithDeposits: depositCustomers,
      totalDepositsAdded: depositAdded,
      totalDepositsUsed: depositUsed,
      currentDepositLiability: depositHeld,
      totalCustomerOwnedBottles: totalCustomerOwned,
      inventoryHealthLabel: healthLabel,
      periodCollections: periodCollections,
      periodPaymentsCount: paymentsInPeriod.length,
      periodSupplierDeliveries: supplyPurchasesInPeriod.length,
      businessTimelineSummary: timelineSummary,
      walkInRevenue: walkInRevenue,
      walkInTransactionCount: walkInRows.length,
      walkInBusinessBottleSalesCount: await _db.walkInSalesDao
          .countByTypeForDateRange('BUSINESS_BOTTLES', start, end),
      walkInCustomerRefillsCount: await _db.walkInSalesDao
          .countByTypeForDateRange('CUSTOMER_REFILL', start, end),
      walkInExchangeCount: await _db.walkInSalesDao
          .countByTypeForDateRange('EXCHANGE', start, end),
      walkInBusinessBottleRevenue: await _db.walkInSalesDao
          .revenueByTypeForDateRange('BUSINESS_BOTTLES', start, end),
      walkInRefillRevenue: await _db.walkInSalesDao
          .revenueByTypeForDateRange('CUSTOMER_REFILL', start, end),
      walkInExchangeRevenue: await _db.walkInSalesDao
          .revenueByTypeForDateRange('EXCHANGE', start, end),
      walkInDetails: walkInDetails,
    );
  }
}
