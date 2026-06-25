import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/savings_transfers_table.dart';

part 'savings_transfers_dao.g.dart';

@DriftAccessor(tables: [SavingsTransfersTable])
class SavingsTransfersDao extends DatabaseAccessor<AppDatabase>
    with _$SavingsTransfersDaoMixin {
  SavingsTransfersDao(super.db);

  Stream<List<SavingsTransfersTableData>> watchAll() {
    return (select(savingsTransfersTable)
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  Future<List<SavingsTransfersTableData>> getAll() {
    return (select(savingsTransfersTable)
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  Future<int> insertTransfer(SavingsTransfersTableCompanion companion) {
    return into(savingsTransfersTable).insert(companion);
  }

  Future<double> _sumForType(String type) async {
    final amountExpr = savingsTransfersTable.amount.sum();
    final query = selectOnly(savingsTransfersTable)
      ..addColumns([amountExpr])
      ..where(savingsTransfersTable.transferType.equals(type));
    final row = await query.getSingle();
    return row.read(amountExpr) ?? 0.0;
  }

  Future<double> getSavingsAccountBalance() async {
    final transferred = await _sumForType('transfer');
    final withdrawn = await _sumForType('withdraw');
    return transferred - withdrawn;
  }

  Future<double> getTotalTransferredForDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final amountExpr = savingsTransfersTable.amount.sum();
    final query = selectOnly(savingsTransfersTable)
      ..addColumns([amountExpr])
      ..where(
        savingsTransfersTable.transferType.equals('transfer') &
            savingsTransfersTable.date.isBiggerOrEqualValue(start) &
            savingsTransfersTable.date.isSmallerOrEqualValue(end),
      );
    final row = await query.getSingle();
    return row.read(amountExpr) ?? 0.0;
  }
}
