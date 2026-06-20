import 'package:drift/drift.dart';
import '../tables/savings_contributions_table.dart';
import '../app_database.dart';

part 'savings_dao.g.dart';

@DriftAccessor(tables: [SavingsContributionsTable])
class SavingsDao extends DatabaseAccessor<AppDatabase> with _$SavingsDaoMixin {
  SavingsDao(super.db);

  Stream<List<SavingsContributionsTableData>> watchAll() {
    return (select(savingsContributionsTable)
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  Future<List<SavingsContributionsTableData>> getAll() {
    return (select(savingsContributionsTable)
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  Future<int> insertContribution(SavingsContributionsTableCompanion companion) {
    return into(savingsContributionsTable).insert(companion);
  }

  Future<int> deleteContribution(String id) {
    return (delete(savingsContributionsTable)..where((t) => t.id.equals(id)))
        .go();
  }

  Future<double> getTotalContributions() async {
    final amountExpr = savingsContributionsTable.amount.sum();
    final query = selectOnly(savingsContributionsTable)..addColumns([amountExpr]);
    final row = await query.getSingle();
    return row.read(amountExpr) ?? 0.0;
  }

  Future<double> getTotalContributionsForDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final amountExpr = savingsContributionsTable.amount.sum();
    final query = selectOnly(savingsContributionsTable)
      ..addColumns([amountExpr])
      ..where(
        savingsContributionsTable.date.isBiggerOrEqualValue(start) &
            savingsContributionsTable.date.isSmallerOrEqualValue(end),
      );
    final row = await query.getSingle();
    return row.read(amountExpr) ?? 0.0;
  }
}
