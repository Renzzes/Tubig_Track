import 'package:drift/drift.dart';
import '../tables/suppliers_table.dart';
import '../app_database.dart';

part 'suppliers_dao.g.dart';

@DriftAccessor(tables: [SuppliersTable])
class SuppliersDao extends DatabaseAccessor<AppDatabase>
    with _$SuppliersDaoMixin {
  SuppliersDao(super.db);

  Stream<List<SuppliersTableData>> watchAll() {
    return (select(suppliersTable)
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  Future<List<SuppliersTableData>> getAll() {
    return (select(suppliersTable)
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  Future<SuppliersTableData?> getById(String id) {
    return (select(suppliersTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<int> insertSupplier(SuppliersTableCompanion companion) {
    return into(suppliersTable).insert(companion);
  }

  Future<bool> updateSupplier(SuppliersTableCompanion companion) {
    return update(suppliersTable).replace(companion);
  }

  Future<int> deleteSupplier(String id) {
    return (delete(suppliersTable)..where((t) => t.id.equals(id))).go();
  }
}
