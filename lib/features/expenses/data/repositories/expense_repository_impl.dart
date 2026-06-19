import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
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
  Future<void> addExpense(Expense expense) async {
    await _db.expensesDao.insertExpense(
      ExpensesTableCompanion.insert(
        id: expense.id,
        category: expense.category,
        amount: expense.amount,
        date: Value(expense.date),
        notes: Value(expense.notes),
      ),
    );
  }

  @override
  Future<void> deleteExpense(String id) async {
    await _db.expensesDao.deleteExpense(id);
  }
}
