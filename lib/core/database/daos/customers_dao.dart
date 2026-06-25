import 'package:drift/drift.dart';
import '../tables/customers_table.dart';
import '../app_database.dart';

part 'customers_dao.g.dart';

@DriftAccessor(tables: [CustomersTable])
class CustomersDao extends DatabaseAccessor<AppDatabase>
    with _$CustomersDaoMixin {
  CustomersDao(super.db);

  Stream<List<CustomerTableData>> watchAll() {
    return (select(customersTable)
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  Future<List<CustomerTableData>> getAll() {
    return (select(customersTable)
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  Stream<List<CustomerTableData>> watchSearch(String query) {
    final q = '%${query.toLowerCase()}%';
    return (select(customersTable)
          ..where(
            (t) =>
                t.name.lower().like(q) |
                t.phone.lower().like(q) |
                t.address.lower().like(q),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  Future<CustomerTableData?> getById(String id) {
    return (select(customersTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<int> insertCustomer(CustomersTableCompanion companion) {
    return into(customersTable).insert(companion);
  }

  Future<bool> updateCustomer(CustomersTableCompanion companion) {
    return update(customersTable).replace(companion);
  }

  Future<int> deleteCustomer(String id) {
    return (delete(customersTable)..where((t) => t.id.equals(id))).go();
  }

  Future<int> getCount() async {
    final countExpr = customersTable.id.count();
    final query = selectOnly(customersTable)..addColumns([countExpr]);
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }

  Future<void> updateCustomerOwnedBottlesHeld(String customerId, int count) {
    return (update(customersTable)..where((t) => t.id.equals(customerId)))
        .write(CustomersTableCompanion(
      customerOwnedBottlesHeld: Value(count),
    ));
  }

  Future<void> updatePendingPhysicalBottleCount(
    String customerId,
    int? actualCount,
  ) {
    return (update(customersTable)..where((t) => t.id.equals(customerId)))
        .write(CustomersTableCompanion(
      pendingPhysicalBottleCount: Value(actualCount),
    ));
  }

  Future<void> updatePhysicalCountVerification(
    String customerId,
    DateTime date,
  ) {
    return (update(customersTable)..where((t) => t.id.equals(customerId)))
        .write(CustomersTableCompanion(
      lastPhysicalCountDate: Value(date),
      lastPhysicalCountVerified: const Value(true),
    ));
  }
}

typedef CustomerTableData = CustomersTableData;
