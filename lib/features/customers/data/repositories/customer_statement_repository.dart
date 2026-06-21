import '../../../../core/database/app_database.dart';
import '../../../../core/utils/bottle_verification_utils.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../inventory/data/repositories/inventory_repository_impl.dart';
import '../../data/repositories/customer_repository_impl.dart';
import '../../domain/entities/customer_statement_data.dart';
import '../../../walk_in_operations/domain/entities/walk_in_sale.dart';

class CustomerStatementRepository {
  final AppDatabase _db;

  CustomerStatementRepository(this._db);

  Future<CustomerStatementData?> buildForCustomer(String customerId) async {
    final customerRow = await _db.customersDao.getById(customerId);
    if (customerRow == null) return null;

    final customerRepo = CustomerRepositoryImpl(_db);
    final customer = (await customerRepo.getAll())
        .firstWhere((c) => c.id == customerId);
    final stats = await customerRepo.getCustomerStats(customerId);

    final reconciliations =
        await InventoryRepositoryImpl(_db).getReconciliationsByCustomer(
      customerId,
    );
    var missingBottles = 0;
    for (final r in reconciliations) {
      if (r.variance < 0) missingBottles += r.variance.abs();
    }
    final pendingVariance = customer.bottleVariance(stats.bottlesHeld);
    if (pendingVariance != null && pendingVariance < 0) {
      missingBottles += pendingVariance.abs();
    }

    final deliveries = await _db.deliveriesDao.getByCustomer(customerId);
    final completed = deliveries
        .where((d) => d.deliveryStatus == 'completed')
        .toList()
      ..sort((a, b) => b.deliveryDate.compareTo(a.deliveryDate));

    final recentDeliveries = completed.take(5).map((d) {
      return CustomerStatementLine(
        date: d.deliveryDate,
        description: '${d.quantity} bottles',
        detail: CurrencyFormatter.format(d.totalAmount),
      );
    }).toList();

    final bottleTxs = await _db.bottleTransactionsDao.getByCustomer(customerId);
    final returns = bottleTxs.where((t) => t.transactionType == 'return').toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final recentCollections = returns.take(5).map((t) {
      return CustomerStatementLine(
        date: t.date,
        description: '${t.quantity} bottles collected',
        detail: t.notes ?? '',
      );
    }).toList();

    final payments = (await _db.paymentsDao.getByCustomer(customerId)).toList()
      ..sort((a, b) => b.paymentDate.compareTo(a.paymentDate));

    final recentPayments = payments.take(5).map((p) {
      return CustomerStatementLine(
        date: p.paymentDate,
        description: 'Payment received',
        detail: CurrencyFormatter.format(p.amount),
      );
    }).toList();

    final walkInRows = await _db.walkInSalesDao.getByCustomer(customerId);
    final walkInBusiness = <CustomerStatementLine>[];
    final walkInRefills = <CustomerStatementLine>[];
    final walkInExchanges = <CustomerStatementLine>[];
    for (final row in walkInRows.take(10)) {
      final type = WalkInTypeX.fromStorage(row.walkInType);
      final line = CustomerStatementLine(
        date: row.date,
        description: WalkInTypeX.fromStorage(row.walkInType).label,
        detail: CurrencyFormatter.format(row.totalAmount),
      );
      switch (type) {
        case WalkInType.businessBottles:
          walkInBusiness.add(line);
        case WalkInType.customerRefill:
          walkInRefills.add(line);
        case WalkInType.exchange:
          walkInExchanges.add(line);
      }
    }

    return CustomerStatementData(
      customerName: customer.name,
      generatedAt: DateTime.now(),
      businessOwnedBottlesHeld: stats.bottlesHeld,
      customerOwnedBottlesHeld: stats.customerOwnedBottlesHeld,
      totalBottlesAtCustomer: stats.totalBottlesAtCustomer,
      outstandingBalance: stats.unpaidBalance,
      depositBalance: stats.depositBalance,
      totalPaid: stats.totalAmountPaid,
      missingBottles: missingBottles,
      damagedBottles: stats.damagedBottles,
      verificationStatus: BottleVerificationUtils.statusFor(customer).label,
      recentDeliveries: recentDeliveries,
      recentCollections: recentCollections,
      recentPayments: recentPayments,
      walkInBusinessBottleSales: walkInBusiness,
      walkInRefills: walkInRefills,
      walkInExchanges: walkInExchanges,
    );
  }

  static String formatLineDate(DateTime date) => DateFormatter.format(date);
}
