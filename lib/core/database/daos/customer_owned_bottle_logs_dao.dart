import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/customer_owned_bottle_logs_table.dart';

part 'customer_owned_bottle_logs_dao.g.dart';

@DriftAccessor(tables: [CustomerOwnedBottleLogsTable])
class CustomerOwnedBottleLogsDao extends DatabaseAccessor<AppDatabase>
    with _$CustomerOwnedBottleLogsDaoMixin {
  CustomerOwnedBottleLogsDao(super.db);

  Future<List<CustomerOwnedBottleLogsTableData>> getByCustomer(
    String customerId,
  ) =>
      (select(customerOwnedBottleLogsTable)
            ..where((t) => t.customerId.equals(customerId))
            ..orderBy([
              (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
            ]))
          .get();

  Stream<List<CustomerOwnedBottleLogsTableData>> watchByCustomer(
    String customerId,
  ) =>
      (select(customerOwnedBottleLogsTable)
            ..where((t) => t.customerId.equals(customerId))
            ..orderBy([
              (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
            ]))
          .watch();

  Future<CustomerOwnedBottleLogsTableData?> getByDeliveryId(
    String deliveryId,
  ) =>
      (select(customerOwnedBottleLogsTable)
            ..where((t) => t.deliveryId.equals(deliveryId)))
          .getSingleOrNull();

  Future<List<CustomerOwnedBottleLogsTableData>> getByDateRange(
    DateTime start,
    DateTime end,
  ) =>
      (select(customerOwnedBottleLogsTable)
            ..where((t) => t.date.isBetweenValues(start, end))
            ..orderBy([
              (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
            ]))
          .get();

  Future<void> insertLog(CustomerOwnedBottleLogsTableCompanion row) =>
      into(customerOwnedBottleLogsTable).insert(row);

  Future<int> deleteById(String id) =>
      (delete(customerOwnedBottleLogsTable)..where((t) => t.id.equals(id)))
          .go();

  Future<int> deleteByDeliveryId(String deliveryId) =>
      (delete(customerOwnedBottleLogsTable)
            ..where((t) => t.deliveryId.equals(deliveryId)))
          .go();
}
