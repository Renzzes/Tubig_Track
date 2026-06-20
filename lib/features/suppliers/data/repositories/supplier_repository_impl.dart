import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/supplier.dart';
import '../../domain/repositories/supplier_repository.dart';

class SupplierRepositoryImpl implements SupplierRepository {
  final AppDatabase _db;

  SupplierRepositoryImpl(this._db);

  Supplier _map(SuppliersTableData row) {
    return Supplier(
      id: row.id,
      name: row.name,
      contactPerson: row.contactPerson,
      mobile: row.mobile,
      address: row.address,
      notes: row.notes,
      createdAt: row.createdAt,
    );
  }

  @override
  Stream<List<Supplier>> watchAll() {
    return _db.suppliersDao.watchAll().map((rows) => rows.map(_map).toList());
  }

  @override
  Future<List<Supplier>> getAll() async {
    final rows = await _db.suppliersDao.getAll();
    return rows.map(_map).toList();
  }

  @override
  Future<Supplier?> getById(String id) async {
    final row = await _db.suppliersDao.getById(id);
    return row == null ? null : _map(row);
  }

  @override
  Future<SupplierAnalytics> getAnalytics(String supplierId) async {
    final supplier = await getById(supplierId);
    if (supplier == null) {
      return const SupplierAnalytics(totalPurchases: 0, totalAmount: 0);
    }

    final purchases = await _db.supplyPurchasesDao.getAll();
    final matched = purchases.where(
      (p) =>
          p.supplierId == supplierId ||
          p.supplierName.toLowerCase() == supplier.name.toLowerCase(),
    );

    if (matched.isEmpty) {
      return const SupplierAnalytics(totalPurchases: 0, totalAmount: 0);
    }

    final totalAmount = matched.fold(0.0, (s, p) => s + p.totalCost);
    final lastDate = matched
        .map((p) => p.purchaseDate)
        .reduce((a, b) => a.isAfter(b) ? a : b);

    final itemCounts = <String, int>{};
    for (final p in matched) {
      itemCounts[p.itemType] = (itemCounts[p.itemType] ?? 0) + p.quantity;
    }
    String? topItem;
    var topQty = 0;
    itemCounts.forEach((item, qty) {
      if (qty > topQty) {
        topQty = qty;
        topItem = item;
      }
    });

    return SupplierAnalytics(
      totalPurchases: matched.length,
      totalAmount: totalAmount,
      lastPurchaseDate: lastDate,
      mostPurchasedItem: topItem,
    );
  }

  @override
  Future<void> addSupplier(Supplier supplier) async {
    await _db.suppliersDao.insertSupplier(
      SuppliersTableCompanion.insert(
        id: supplier.id,
        name: supplier.name,
        contactPerson: Value(supplier.contactPerson),
        mobile: Value(supplier.mobile),
        address: Value(supplier.address),
        notes: Value(supplier.notes),
        createdAt: Value(supplier.createdAt),
      ),
    );
  }

  @override
  Future<void> updateSupplier(Supplier supplier) async {
    await _db.suppliersDao.updateSupplier(
      SuppliersTableCompanion(
        id: Value(supplier.id),
        name: Value(supplier.name),
        contactPerson: Value(supplier.contactPerson),
        mobile: Value(supplier.mobile),
        address: Value(supplier.address),
        notes: Value(supplier.notes),
        createdAt: Value(supplier.createdAt),
      ),
    );
  }

  @override
  Future<void> deleteSupplier(String id) async {
    await _db.suppliersDao.deleteSupplier(id);
  }
}
