import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/savings_entities.dart';
import '../../domain/entities/savings_goal.dart';
import '../../domain/repositories/savings_goals_repository.dart';
import '../../domain/repositories/savings_repository.dart';

class SavingsGoalsRepositoryImpl implements SavingsGoalsRepository {
  final AppDatabase _db;
  final SavingsRepository _savingsRepo;

  SavingsGoalsRepositoryImpl(this._db, this._savingsRepo);

  SavingsGoal _map(SavingsGoalsTableData row) {
    return SavingsGoal(
      id: row.id,
      name: row.name,
      targetAmount: row.targetAmount,
      targetDate: row.targetDate,
      notes: row.notes,
      isActive: row.isActive,
      createdAt: row.createdAt,
    );
  }

  @override
  Stream<List<SavingsGoal>> watchAll() {
    return _db.savingsGoalsDao.watchAll().map((rows) => rows.map(_map).toList());
  }

  @override
  Future<List<SavingsGoal>> getAll() async {
    final rows = await _db.savingsGoalsDao.getAll();
    return rows.map(_map).toList();
  }

  @override
  Future<SavingsGoal?> getActiveGoal() async {
    final row = await _db.savingsGoalsDao.getActiveGoal();
    return row == null ? null : _map(row);
  }

  @override
  Future<void> addGoal(SavingsGoal goal, {bool setActive = false}) async {
    if (setActive) {
      await _db.savingsGoalsDao.deactivateAllExcept(goal.id);
    }
    await _db.savingsGoalsDao.insertGoal(
      SavingsGoalsTableCompanion.insert(
        id: goal.id,
        name: goal.name,
        targetAmount: goal.targetAmount,
        targetDate: Value(goal.targetDate),
        notes: Value(goal.notes),
        isActive: Value(setActive || goal.isActive),
        createdAt: Value(goal.createdAt),
      ),
    );
  }

  @override
  Future<void> updateGoal(SavingsGoal goal) async {
    await _db.savingsGoalsDao.updateGoal(
      SavingsGoalsTableData(
        id: goal.id,
        name: goal.name,
        targetAmount: goal.targetAmount,
        targetDate: goal.targetDate,
        notes: goal.notes,
        isActive: goal.isActive,
        createdAt: goal.createdAt,
      ),
    );
  }

  @override
  Future<void> deleteGoal(String id) async {
    await _db.savingsGoalsDao.deleteGoal(id);
  }

  @override
  Future<void> setActiveGoal(String id) async {
    await _db.savingsGoalsDao.deactivateAllExcept(id);
    final row = await _db.savingsGoalsDao.getById(id);
    if (row != null) {
      await _db.savingsGoalsDao.updateGoal(row.copyWith(isActive: true));
    }
  }

  @override
  Future<SavingsInsights> getInsights() async {
    final ledger = await _savingsRepo.getLedgerHistory();
    final monthly = <String, double>{};

    for (final e in ledger) {
      final key = '${e.date.year}-${e.date.month.toString().padLeft(2, '0')}';
      final delta = switch (e.type) {
        SavingsLedgerType.deliveryProfit ||
        SavingsLedgerType.dispenserProfit ||
        SavingsLedgerType.manualAddition =>
          e.amount,
        _ => -e.amount,
      };
      monthly[key] = (monthly[key] ?? 0) + delta;
    }

    if (monthly.isEmpty) {
      return const SavingsInsights(
        averageMonthlySavings: 0,
        highestMonthlySavings: 0,
        lowestMonthlySavings: 0,
        trend: SavingsTrend.stable,
      );
    }

    final values = monthly.values.toList();
    final avg = values.fold(0.0, (s, v) => s + v) / values.length;
    final highest = values.reduce((a, b) => a > b ? a : b);
    final lowest = values.reduce((a, b) => a < b ? a : b);

    SavingsTrend trend = SavingsTrend.stable;
    if (values.length >= 2) {
      final sortedKeys = monthly.keys.toList()..sort();
      final recent = monthly[sortedKeys.last] ?? 0;
      final previous = monthly[sortedKeys[sortedKeys.length - 2]] ?? 0;
      if (recent > previous * 1.05) {
        trend = SavingsTrend.increasing;
      } else if (recent < previous * 0.95) {
        trend = SavingsTrend.decreasing;
      }
    }

    return SavingsInsights(
      averageMonthlySavings: avg,
      highestMonthlySavings: highest,
      lowestMonthlySavings: lowest,
      trend: trend,
    );
  }
}
