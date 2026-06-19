import '../entities/expense.dart';

abstract class ExpenseRepository {
  Stream<List<Expense>> watchAll();
  Future<List<Expense>> getAll();
  Future<List<Expense>> getByDateRange(DateTime start, DateTime end);
  Future<void> addExpense(Expense expense);
  Future<void> deleteExpense(String id);
}
