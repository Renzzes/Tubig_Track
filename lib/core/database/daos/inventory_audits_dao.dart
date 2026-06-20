import 'package:drift/drift.dart';
import '../tables/inventory_audits_table.dart';
import '../app_database.dart';

part 'inventory_audits_dao.g.dart';

@DriftAccessor(tables: [InventoryAuditsTable])
class InventoryAuditsDao extends DatabaseAccessor<AppDatabase>
    with _$InventoryAuditsDaoMixin {
  InventoryAuditsDao(super.db);

  Stream<List<InventoryAuditsTableData>> watchAll() {
    return (select(inventoryAuditsTable)
          ..orderBy([(t) => OrderingTerm.desc(t.auditDate)]))
        .watch();
  }

  Future<List<InventoryAuditsTableData>> getAll() {
    return (select(inventoryAuditsTable)
          ..orderBy([(t) => OrderingTerm.desc(t.auditDate)]))
        .get();
  }

  Future<InventoryAuditsTableData?> getLatest() {
    return (select(inventoryAuditsTable)
          ..orderBy([(t) => OrderingTerm.desc(t.auditDate)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<int> getCount() async {
    final countExpr = inventoryAuditsTable.id.count();
    final q = selectOnly(inventoryAuditsTable)..addColumns([countExpr]);
    final row = await q.getSingle();
    return row.read(countExpr) ?? 0;
  }

  Future<int> insertAudit(InventoryAuditsTableCompanion companion) {
    return into(inventoryAuditsTable).insert(companion);
  }
}
