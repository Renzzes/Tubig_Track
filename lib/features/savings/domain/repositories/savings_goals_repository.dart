import '../entities/savings_goal.dart';

abstract class SavingsGoalsRepository {
  Stream<List<SavingsGoal>> watchAll();
  Future<List<SavingsGoal>> getAll();
  Future<SavingsGoal?> getActiveGoal();
  Future<void> addGoal(SavingsGoal goal, {bool setActive = false});
  Future<void> updateGoal(SavingsGoal goal);
  Future<void> deleteGoal(String id);
  Future<void> setActiveGoal(String id);
  Future<SavingsInsights> getInsights();
}
