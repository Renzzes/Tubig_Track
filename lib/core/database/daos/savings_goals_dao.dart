import 'package:drift/drift.dart';
import '../tables/savings_goals_table.dart';
import '../app_database.dart';

part 'savings_goals_dao.g.dart';

@DriftAccessor(tables: [SavingsGoalsTable])
class SavingsGoalsDao extends DatabaseAccessor<AppDatabase>
    with _$SavingsGoalsDaoMixin {
  SavingsGoalsDao(super.db);

  Stream<List<SavingsGoalsTableData>> watchAll() {
    return (select(savingsGoalsTable)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Future<List<SavingsGoalsTableData>> getAll() {
    return (select(savingsGoalsTable)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Future<SavingsGoalsTableData?> getActiveGoal() {
    return (select(savingsGoalsTable)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<SavingsGoalsTableData?> getById(String id) {
    return (select(savingsGoalsTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<int> insertGoal(SavingsGoalsTableCompanion companion) {
    return into(savingsGoalsTable).insert(companion);
  }

  Future<bool> updateGoal(SavingsGoalsTableData row) {
    return update(savingsGoalsTable).replace(row);
  }

  Future<int> deleteGoal(String id) {
    return (delete(savingsGoalsTable)..where((t) => t.id.equals(id))).go();
  }

  Future<void> deactivateAllExcept(String? keepId) async {
    final all = await getAll();
    for (final g in all) {
      if (g.id == keepId) continue;
      if (g.isActive) {
        await update(savingsGoalsTable).replace(g.copyWith(isActive: false));
      }
    }
  }
}
