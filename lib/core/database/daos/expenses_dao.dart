import 'package:drift/drift.dart';
import '../tables/expenses_table.dart';
import '../app_database.dart';

part 'expenses_dao.g.dart';

@DriftAccessor(tables: [ExpensesTable])
class ExpensesDao extends DatabaseAccessor<AppDatabase>
    with _$ExpensesDaoMixin {
  ExpensesDao(super.db);

  Stream<List<ExpensesTableData>> watchAll() {
    return (select(expensesTable)
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  Future<List<ExpensesTableData>> getAll() {
    return (select(expensesTable)
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  Future<List<ExpensesTableData>> getByDateRange(
    DateTime start,
    DateTime end,
  ) {
    return (select(expensesTable)
          ..where(
            (t) =>
                t.date.isBiggerOrEqualValue(start) &
                t.date.isSmallerOrEqualValue(end),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  Future<ExpensesTableData?> getById(String id) {
    return (select(expensesTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<int> insertExpense(ExpensesTableCompanion companion) {
    return into(expensesTable).insert(companion);
  }

  Future<int> deleteExpense(String id) {
    return (delete(expensesTable)..where((t) => t.id.equals(id))).go();
  }

  Future<double> getTotalForDateRange(DateTime start, DateTime end) async {
    final amountExpr = expensesTable.amount.sum();
    final query = selectOnly(expensesTable)
      ..addColumns([amountExpr])
      ..where(
        expensesTable.date.isBiggerOrEqualValue(start) &
            expensesTable.date.isSmallerOrEqualValue(end),
      );
    final row = await query.getSingle();
    return row.read(amountExpr) ?? 0.0;
  }
}
