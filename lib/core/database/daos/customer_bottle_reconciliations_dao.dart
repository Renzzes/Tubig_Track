import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/customer_bottle_reconciliations_table.dart';

part 'customer_bottle_reconciliations_dao.g.dart';

@DriftAccessor(tables: [CustomerBottleReconciliationsTable])
class CustomerBottleReconciliationsDao
    extends DatabaseAccessor<AppDatabase>
    with _$CustomerBottleReconciliationsDaoMixin {
  CustomerBottleReconciliationsDao(super.db);

  Future<List<CustomerBottleReconciliationsTableData>> getAll() =>
      (select(customerBottleReconciliationsTable)
            ..orderBy([
              (t) => OrderingTerm(
                    expression: t.createdAt,
                    mode: OrderingMode.desc,
                  ),
            ]))
          .get();

  Stream<List<CustomerBottleReconciliationsTableData>> watchAll() =>
      (select(customerBottleReconciliationsTable)
            ..orderBy([
              (t) => OrderingTerm(
                    expression: t.createdAt,
                    mode: OrderingMode.desc,
                  ),
            ]))
          .watch();

  Future<List<CustomerBottleReconciliationsTableData>> getByCustomer(
    String customerId,
  ) =>
      (select(customerBottleReconciliationsTable)
            ..where((t) => t.customerId.equals(customerId))
            ..orderBy([
              (t) => OrderingTerm(
                    expression: t.createdAt,
                    mode: OrderingMode.desc,
                  ),
            ]))
          .get();

  Future<void> insertReconciliation(
    CustomerBottleReconciliationsTableCompanion row,
  ) =>
      into(customerBottleReconciliationsTable).insert(row);
}
