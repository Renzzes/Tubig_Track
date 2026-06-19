import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/dispenser_sale.dart';
import '../../domain/repositories/dispenser_sale_repository.dart';

class DispenserSaleRepositoryImpl implements DispenserSaleRepository {
  final AppDatabase _db;

  DispenserSaleRepositoryImpl(this._db);

  DispenserSale _map(DispenserSalesTableData row) {
    return DispenserSale(
      id: row.id,
      amount: row.amount,
      date: row.date,
      notes: row.notes,
    );
  }

  @override
  Stream<List<DispenserSale>> watchAll() {
    return _db.dispenserSalesDao.watchAll().map(
          (rows) => rows.map(_map).toList(),
        );
  }

  @override
  Future<List<DispenserSale>> getAll() async {
    final rows = await _db.dispenserSalesDao.getAll();
    return rows.map(_map).toList();
  }

  @override
  Future<List<DispenserSale>> getByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final rows = await _db.dispenserSalesDao.getByDateRange(start, end);
    return rows.map(_map).toList();
  }

  @override
  Future<void> addSale(DispenserSale sale) async {
    await _db.dispenserSalesDao.insertSale(
      DispenserSalesTableCompanion.insert(
        id: sale.id,
        amount: sale.amount,
        date: Value(sale.date),
        notes: Value(sale.notes),
      ),
    );
  }

  @override
  Future<void> deleteSale(String id) async {
    await _db.dispenserSalesDao.deleteSale(id);
  }
}
