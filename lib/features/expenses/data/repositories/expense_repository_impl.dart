import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../../supply_purchases/data/repositories/supply_purchase_repository_impl.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final AppDatabase _db;

  ExpenseRepositoryImpl(this._db);

  Expense _map(ExpensesTableData row) {
    return Expense(
      id: row.id,
      category: row.category,
      amount: row.amount,
      date: row.date,
      notes: row.notes,
      description: row.description,
      supplier: row.supplier,
      quantity: row.quantity,
      unitCost: row.unitCost,
      supplyPurchaseId: row.supplyPurchaseId,
    );
  }

  @override
  Stream<List<Expense>> watchAll() {
    return _db.expensesDao.watchAll().map(
          (rows) => rows.map(_map).toList(),
        );
  }

  @override
  Future<List<Expense>> getAll() async {
    final rows = await _db.expensesDao.getAll();
    return rows.map(_map).toList();
  }

  @override
  Future<List<Expense>> getByDateRange(DateTime start, DateTime end) async {
    final rows = await _db.expensesDao.getByDateRange(start, end);
    return rows.map(_map).toList();
  }

  @override
  Future<Expense?> getById(String id) async {
    final row = await _db.expensesDao.getById(id);
    return row == null ? null : _map(row);
  }

  @override
  Future<void> addExpense(Expense expense) async {
    await _db.expensesDao.insertExpense(
      ExpensesTableCompanion.insert(
        id: expense.id,
        category: expense.category,
        amount: expense.amount,
        date: Value(expense.date),
        notes: Value(expense.notes),
        description: Value(expense.description),
        supplier: Value(expense.supplier),
        quantity: Value(expense.quantity),
        unitCost: Value(expense.unitCost),
        supplyPurchaseId: Value(expense.supplyPurchaseId),
      ),
    );
  }

  @override
  Future<void> deleteExpense(String id) async {
    final row = await _db.expensesDao.getById(id);
    if (row?.supplyPurchaseId != null) {
      await SupplyPurchaseRepositoryImpl(_db)
          .deletePurchase(row!.supplyPurchaseId!);
      return;
    }
    await _db.expensesDao.deleteExpense(id);
  }
}
