import '../../../../core/database/app_database.dart';
import '../../../../core/utils/supply_timeline_utils.dart';
import '../../../inventory/domain/entities/bottle_transaction.dart';
import '../../../supply_purchases/domain/entities/supply_purchase.dart';
import '../../domain/entities/recent_transaction.dart';
import '../../domain/repositories/recent_transactions_repository.dart';

class RecentTransactionsRepositoryImpl implements RecentTransactionsRepository {
  final AppDatabase _db;

  RecentTransactionsRepositoryImpl(this._db);

  @override
  Future<List<RecentTransaction>> getRecent({int limit = 50}) async {
    final all = await _buildAll();
    return all.take(limit).toList();
  }

  @override
  Future<List<RecentTransaction>> getAll() => _buildAll();

  Future<List<RecentTransaction>> _buildAll() async {
    final items = <RecentTransaction>[];

    final customers = await _db.customersDao.getAll();
    final customerMap = {for (final c in customers) c.id: c.name};

    final linkedBottleIds =
        await _db.supplyPurchasesDao.getLinkedBottleTransactionIds();

    for (final d in await _db.deliveriesDao.getAll()) {
      items.add(
        RecentTransaction(
          id: 'delivery_${d.id}',
          sourceId: d.id,
          type: RecentTransactionType.delivery,
          date: d.deliveryDate,
          title: customerMap[d.customerId] ?? 'Unknown',
          subtitle: '${d.quantity} bottles',
          amount: d.totalAmount,
          isCredit: true,
          customerId: d.customerId,
          customerName: customerMap[d.customerId],
        ),
      );
    }

    for (final p in await _db.paymentsDao.getAll()) {
      items.add(
        RecentTransaction(
          id: 'payment_${p.id}',
          sourceId: p.id,
          type: RecentTransactionType.payment,
          date: p.paymentDate,
          title: customerMap[p.customerId] ?? 'Unknown',
          subtitle: p.notes,
          amount: p.amount,
          isCredit: true,
          customerId: p.customerId,
          customerName: customerMap[p.customerId],
          deliveryId: p.deliveryId,
        ),
      );
    }

    for (final sp in await _db.supplyPurchasesDao.getAll()) {
      final purchase = SupplyPurchase(
        id: sp.id,
        purchaseDate: sp.purchaseDate,
        supplierName: sp.supplierName,
        itemType: sp.itemType,
        quantity: sp.quantity,
        unitCost: sp.unitCost,
        totalCost: sp.totalCost,
        notes: sp.notes,
        expenseId: sp.expenseId,
        bottleTransactionId: sp.bottleTransactionId,
        supplierId: sp.supplierId,
      );
      items.add(
        RecentTransaction(
          id: 'supply_${sp.id}',
          sourceId: sp.id,
          type: RecentTransactionType.supplyPurchase,
          date: sp.purchaseDate,
          title: SupplyTimelineUtils.supplierDeliveryHeadline(purchase),
          subtitle: sp.notes,
          amount: sp.totalCost,
          isCredit: false,
        ),
      );
    }

    for (final e in await _db.expensesDao.getAll()) {
      if (e.supplyPurchaseId != null) continue;
      items.add(
        RecentTransaction(
          id: 'expense_${e.id}',
          sourceId: e.id,
          type: RecentTransactionType.expense,
          date: e.date,
          title: e.description?.isNotEmpty == true
              ? e.description!
              : e.category,
          subtitle: e.supplier ?? e.notes,
          amount: e.amount,
          isCredit: false,
          expenseCategory: e.category,
        ),
      );
    }

    for (final s in await _db.dispenserSalesDao.getAll()) {
      items.add(
        RecentTransaction(
          id: 'dispenser_${s.id}',
          sourceId: s.id,
          type: RecentTransactionType.dispenserSale,
          date: s.date,
          title: 'Dispenser Sale',
          subtitle: s.notes,
          amount: s.amount,
          isCredit: true,
        ),
      );
    }

    for (final w in await _db.walkInSalesDao.getAll()) {
      final typeLabel = switch (w.walkInType) {
        'BUSINESS_BOTTLES' => 'Borrow Bottle',
        'CUSTOMER_REFILL' => 'Refill Own Bottle',
        'EXCHANGE' => 'Bottle Exchange',
        _ => 'Walk-In',
      };
      items.add(
        RecentTransaction(
          id: 'walkin_${w.id}',
          sourceId: w.id,
          type: RecentTransactionType.walkInOperation,
          date: w.date,
          title: typeLabel,
          subtitle: w.customerId != null
              ? customerMap[w.customerId]
              : 'Walk-In Customer',
          amount: w.totalAmount,
          isCredit: true,
          customerId: w.customerId,
          customerName:
              w.customerId != null ? customerMap[w.customerId] : null,
        ),
      );
    }

    for (final t in await _db.bottleTransactionsDao.getAll()) {
      if (linkedBottleIds.contains(t.id)) continue;
      RecentTransactionType type;
      switch (t.transactionType) {
        case 'return':
          type = RecentTransactionType.bottleReturn;
        case 'damaged':
          type = RecentTransactionType.bottleDamaged;
        case 'purchase':
          type = RecentTransactionType.bottlePurchase;
        case 'added':
          type = RecentTransactionType.bottleAdjustment;
        case 'missing':
          type = RecentTransactionType.bottleMissing;
        case 'donation':
          type = RecentTransactionType.bottleDonation;
        case 'adjustment':
          type = RecentTransactionType.bottleAdjustment;
        case 'audit':
          type = RecentTransactionType.bottleAudit;
        default:
          type = RecentTransactionType.bottleBorrow;
      }
      final txType = BottleTransaction.typeFromString(t.transactionType);
      final customerName =
          t.customerId != null ? customerMap[t.customerId] : null;
      items.add(
        RecentTransaction(
          id: 'bottle_${t.id}',
          sourceId: t.id,
          type: type,
          date: t.date,
          title: customerName != null
              ? '${BottleTransaction.timelineLabel(txType, t.quantity)} — $customerName'
              : BottleTransaction.timelineLabel(txType, t.quantity),
          subtitle: t.notes,
          amount: t.quantity.toDouble(),
          isCredit: type == RecentTransactionType.bottleReturn ||
              type == RecentTransactionType.bottlePurchase ||
              (type == RecentTransactionType.bottleAdjustment &&
                  t.quantity > 0),
          customerId: t.customerId,
          customerName: customerName,
        ),
      );
    }

    for (final c in await _db.savingsDao.getAll()) {
      items.add(
        RecentTransaction(
          id: 'savings_${c.id}',
          sourceId: c.id,
          type: RecentTransactionType.savingsAddition,
          date: c.date,
          title: 'Owner Capital',
          subtitle: c.notes,
          amount: c.amount,
          isCredit: true,
        ),
      );
    }

    for (final t in await _db.savingsTransfersDao.getAll()) {
      final isTransfer = t.transferType == 'transfer';
      items.add(
        RecentTransaction(
          id: 'savings_transfer_${t.id}',
          sourceId: t.id,
          type: isTransfer
              ? RecentTransactionType.savingsTransfer
              : RecentTransactionType.savingsWithdraw,
          date: t.date,
          title: isTransfer ? 'Transfer to Savings' : 'Withdraw from Savings',
          subtitle: t.notes,
          amount: t.amount,
          isCredit: !isTransfer,
        ),
      );
    }

    for (final d in await _db.customerDepositsDao.getAll()) {
      RecentTransactionType type;
      switch (d.transactionType) {
        case 'deposit_used':
          type = RecentTransactionType.depositUsed;
        case 'deposit_adjustment':
          type = RecentTransactionType.depositAdjustment;
        default:
          type = RecentTransactionType.depositAdded;
      }
      items.add(
        RecentTransaction(
          id: 'deposit_${d.id}',
          sourceId: d.id,
          type: type,
          date: d.createdAt,
          title: customerMap[d.customerId] ?? 'Unknown',
          subtitle: d.notes,
          amount: d.amount,
          isCredit: type == RecentTransactionType.depositAdded ||
              type == RecentTransactionType.depositAdjustment,
          customerId: d.customerId,
          customerName: customerMap[d.customerId],
          deliveryId: d.deliveryId,
        ),
      );
    }

    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }
}
