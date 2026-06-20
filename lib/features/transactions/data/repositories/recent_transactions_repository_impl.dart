import '../../../../core/database/app_database.dart';
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

    for (final d in await _db.deliveriesDao.getAll()) {
      items.add(
        RecentTransaction(
          id: 'delivery_${d.id}',
          type: RecentTransactionType.delivery,
          date: d.deliveryDate,
          title: customerMap[d.customerId] ?? 'Unknown',
          subtitle: '${d.quantity} bottles',
          amount: d.totalAmount,
          isCredit: true,
        ),
      );
    }

    for (final p in await _db.paymentsDao.getAll()) {
      items.add(
        RecentTransaction(
          id: 'payment_${p.id}',
          type: RecentTransactionType.payment,
          date: p.paymentDate,
          title: customerMap[p.customerId] ?? 'Unknown',
          subtitle: p.notes,
          amount: p.amount,
          isCredit: true,
        ),
      );
    }

    for (final e in await _db.expensesDao.getAll()) {
      items.add(
        RecentTransaction(
          id: 'expense_${e.id}',
          type: RecentTransactionType.expense,
          date: e.date,
          title: e.category,
          subtitle: e.notes,
          amount: e.amount,
          isCredit: false,
        ),
      );
    }

    for (final s in await _db.dispenserSalesDao.getAll()) {
      items.add(
        RecentTransaction(
          id: 'dispenser_${s.id}',
          type: RecentTransactionType.dispenserSale,
          date: s.date,
          title: 'Walk-in Sale',
          subtitle: s.notes,
          amount: s.amount,
          isCredit: true,
        ),
      );
    }

    for (final t in await _db.bottleTransactionsDao.getAll()) {
      RecentTransactionType type;
      switch (t.transactionType) {
        case 'return':
          type = RecentTransactionType.bottleReturn;
        case 'damaged':
          type = RecentTransactionType.bottleDamaged;
        case 'purchase':
          type = RecentTransactionType.bottlePurchase;
        default:
          type = RecentTransactionType.bottleBorrow;
      }
      final customerName =
          t.customerId != null ? customerMap[t.customerId] : null;
      items.add(
        RecentTransaction(
          id: 'bottle_${t.id}',
          type: type,
          date: t.date,
          title: customerName ?? _typeTitle(type),
          subtitle: '${t.quantity} bottles',
          amount: t.quantity.toDouble(),
          isCredit: type == RecentTransactionType.bottleReturn ||
              type == RecentTransactionType.bottlePurchase,
        ),
      );
    }

    for (final c in await _db.savingsDao.getAll()) {
      items.add(
        RecentTransaction(
          id: 'savings_${c.id}',
          type: RecentTransactionType.savingsAddition,
          date: c.date,
          title: 'Manual Savings',
          subtitle: c.notes,
          amount: c.amount,
          isCredit: true,
        ),
      );
    }

    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  String _typeTitle(RecentTransactionType type) {
    switch (type) {
      case RecentTransactionType.bottlePurchase:
        return 'Inventory Purchase';
      case RecentTransactionType.bottleDamaged:
        return 'Damaged Bottles';
      case RecentTransactionType.bottleReturn:
        return 'Bottle Return';
      default:
        return 'Bottle Borrow';
    }
  }
}
