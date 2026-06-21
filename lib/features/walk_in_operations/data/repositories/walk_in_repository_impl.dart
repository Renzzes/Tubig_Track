import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/services/inventory_state_effects.dart';
import '../../../../core/services/inventory_state_service.dart';
import '../../../inventory/domain/entities/bottle_transaction.dart';
import '../../domain/entities/walk_in_sale.dart';
import '../../domain/repositories/walk_in_repository.dart';

class WalkInRepositoryImpl implements WalkInRepository {
  final AppDatabase _db;
  final InventoryStateService _state;
  final InventoryStateEffects _effects;

  WalkInRepositoryImpl(this._db)
      : _state = InventoryStateService(_db),
        _effects = InventoryStateEffects(InventoryStateService(_db));

  WalkInSale _map(WalkInSalesTableData row) {
    return WalkInSale(
      id: row.id,
      customerId: row.customerId,
      walkInType: WalkInTypeX.fromStorage(row.walkInType),
      businessOwnedQuantity: row.businessOwnedQuantity,
      customerOwnedQuantity: row.customerOwnedQuantity,
      returnedEmptyQuantity: row.returnedEmptyQuantity,
      pricePerBottle: row.pricePerBottle,
      totalAmount: row.totalAmount,
      paymentMethod: row.paymentMethod,
      notes: row.notes,
      date: row.date,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  @override
  Stream<List<WalkInSale>> watchAll() {
    return _db.walkInSalesDao.watchAll().map((rows) => rows.map(_map).toList());
  }

  @override
  Future<List<WalkInSale>> getAll() async {
    final rows = await _db.walkInSalesDao.getAll();
    return rows.map(_map).toList();
  }

  @override
  Future<List<WalkInSale>> getByDateRange(DateTime start, DateTime end) async {
    final rows = await _db.walkInSalesDao.getByDateRange(start, end);
    return rows.map(_map).toList();
  }

  @override
  Future<List<WalkInSale>> getByCustomer(String customerId) async {
    final rows = await _db.walkInSalesDao.getByCustomer(customerId);
    return rows.map(_map).toList();
  }

  @override
  Future<double> getTotalRevenueForDateRange(DateTime start, DateTime end) {
    return _db.walkInSalesDao.getTotalRevenueForDateRange(start, end);
  }

  @override
  Future<int> getCountForDateRange(DateTime start, DateTime end) {
    return _db.walkInSalesDao.getCountForDateRange(start, end);
  }

  @override
  Future<int> getTotalBottlesForDateRange(DateTime start, DateTime end) {
    return _db.walkInSalesDao.totalBottlesForDateRange(start, end);
  }

  Future<void> _ensureFilledAvailable(int quantity) async {
    final filled = await _state.getFilledBottlesAvailable();
    if (filled < quantity) {
      throw StateError(
        'Not enough filled bottles available ($filled on hand, $quantity requested).',
      );
    }
  }

  Future<void> _applyInventoryEffects(WalkInSale sale) async {
    switch (sale.walkInType) {
      case WalkInType.businessBottles:
        await _ensureFilledAvailable(sale.businessOwnedQuantity);
        if (sale.customerId != null && sale.businessOwnedQuantity > 0) {
          await _effects.applyTransaction(
            TransactionType.borrow,
            sale.businessOwnedQuantity,
          );
          await _db.bottleTransactionsDao.insertTransaction(
            BottleTransactionsTableCompanion.insert(
              id: '${sale.id}_walkin_borrow',
              customerId: Value(sale.customerId),
              transactionType: BottleTransaction.typeToString(
                TransactionType.borrow,
              ),
              quantity: sale.businessOwnedQuantity,
              date: Value(sale.date),
              reason: const Value('Walk-In Business Bottles'),
              notes: Value(sale.notes),
            ),
          );
        } else if (sale.businessOwnedQuantity > 0) {
          await _state.adjustFilled(-sale.businessOwnedQuantity);
        }
      case WalkInType.customerRefill:
        await _ensureFilledAvailable(sale.customerOwnedQuantity);
        await _state.adjustFilled(-sale.customerOwnedQuantity);
      case WalkInType.exchange:
        await _ensureFilledAvailable(sale.businessOwnedQuantity);
        await _state.adjustFilled(-sale.businessOwnedQuantity);
        if (sale.returnedEmptyQuantity > 0) {
          await _state.adjustEmpty(sale.returnedEmptyQuantity);
        }
    }
  }

  Future<void> _reverseInventoryEffects(WalkInSale sale) async {
    switch (sale.walkInType) {
      case WalkInType.businessBottles:
        if (sale.customerId != null && sale.businessOwnedQuantity > 0) {
          final txId = '${sale.id}_walkin_borrow';
          final existing = await _db.bottleTransactionsDao.getById(txId);
          if (existing != null) {
            await _effects.applyTransaction(
              TransactionType.borrow,
              existing.quantity,
              reverse: true,
            );
            await _db.bottleTransactionsDao.deleteTransaction(txId);
          }
        } else if (sale.businessOwnedQuantity > 0) {
          await _state.adjustFilled(sale.businessOwnedQuantity);
        }
      case WalkInType.customerRefill:
        await _state.adjustFilled(sale.customerOwnedQuantity);
      case WalkInType.exchange:
        await _state.adjustFilled(sale.businessOwnedQuantity);
        if (sale.returnedEmptyQuantity > 0) {
          await _state.adjustEmpty(-sale.returnedEmptyQuantity);
        }
    }
  }

  @override
  Future<void> recordWalkIn(WalkInSale sale) async {
    await _db.transaction(() async {
      await _applyInventoryEffects(sale);
      await _db.walkInSalesDao.insertSale(
        WalkInSalesTableCompanion.insert(
          id: sale.id,
          customerId: Value(sale.customerId),
          walkInType: sale.walkInType.storageValue,
          businessOwnedQuantity: Value(sale.businessOwnedQuantity),
          customerOwnedQuantity: Value(sale.customerOwnedQuantity),
          returnedEmptyQuantity: Value(sale.returnedEmptyQuantity),
          pricePerBottle: sale.pricePerBottle,
          totalAmount: sale.totalAmount,
          paymentMethod: Value(sale.paymentMethod),
          notes: Value(sale.notes),
          date: Value(sale.date),
          createdAt: Value(sale.createdAt),
          updatedAt: Value(sale.updatedAt),
        ),
      );
    });
  }

  @override
  Future<void> deleteWalkIn(String id) async {
    final existing = await _db.walkInSalesDao.getById(id);
    if (existing == null) return;
    final sale = _map(existing);

    await _db.transaction(() async {
      await _reverseInventoryEffects(sale);
      await _db.walkInSalesDao.deleteSale(id);
    });
  }
}
