import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../data/repositories/inventory_repository_impl.dart';
import '../../domain/entities/bottle_transaction.dart';
import '../../domain/entities/inventory_adjustment.dart';
import '../../domain/entities/inventory_audit.dart';
import '../../domain/entities/inventory_audit_summary.dart';
import '../../domain/entities/inventory_summary.dart';
import '../../domain/entities/customer_bottle_balance.dart';
import '../../domain/entities/customer_bottle_reconciliation.dart';
import '../../domain/entities/customer_owned_bottle_log.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../../../core/utils/inventory_calculator.dart';
import '../../../customers/presentation/providers/customers_provider.dart';
import '../../../supply_purchases/presentation/providers/supply_purchase_provider.dart';
import '../../../savings/presentation/providers/savings_goals_provider.dart';

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return InventoryRepositoryImpl(db);
});

final bottleTransactionsStreamProvider =
    StreamProvider<List<BottleTransaction>>((ref) {
  return ref.watch(inventoryRepositoryProvider).watchAll();
});

final inventorySummaryProvider = FutureProvider<InventorySummary>((ref) async {
  ref.watch(bottleTransactionsStreamProvider);
  ref.watch(supplyPurchasesStreamProvider);
  return ref.read(inventoryRepositoryProvider).getSummary();
});

final inventoryAuditsStreamProvider = StreamProvider<List<InventoryAudit>>((ref) {
  ref.watch(bottleTransactionsStreamProvider);
  return ref.watch(inventoryRepositoryProvider).watchAudits();
});

final inventoryAdjustmentsStreamProvider =
    StreamProvider<List<InventoryAdjustment>>((ref) {
  ref.watch(bottleTransactionsStreamProvider);
  return ref.watch(inventoryRepositoryProvider).watchAdjustments();
});

final inventoryAuditSummaryProvider = FutureProvider<InventoryAuditSummary>((ref) async {
  ref.watch(inventoryAuditsStreamProvider);
  ref.watch(inventoryAdjustmentsStreamProvider);
  return ref.read(inventoryRepositoryProvider).getAuditSummary();
});

final customerBottleBalancesProvider =
    FutureProvider<List<CustomerBottleBalance>>((ref) async {
  ref.watch(bottleTransactionsStreamProvider);
  ref.watch(customersStreamProvider);
  return ref.read(inventoryRepositoryProvider).getCustomerBottleBalances();
});

final customerOwnedLogsStreamProvider =
    StreamProvider.family<List<CustomerOwnedBottleLog>, String>((ref, customerId) {
  ref.watch(bottleTransactionsStreamProvider);
  return ref.watch(inventoryRepositoryProvider).watchCustomerOwnedLogs(customerId);
});

void refreshInventoryProviders(WidgetRef ref) {
  ref.invalidate(bottleTransactionsStreamProvider);
  ref.invalidate(inventorySummaryProvider);
  ref.invalidate(inventoryAuditsStreamProvider);
  ref.invalidate(inventoryAdjustmentsStreamProvider);
  ref.invalidate(inventoryAuditSummaryProvider);
  ref.invalidate(customerBottleBalancesProvider);
  ref.invalidate(inventoryConsistencyProvider);
  ref.invalidate(bottleReconciliationsStreamProvider);
  ref.invalidate(supplyPurchasesStreamProvider);
  ref.invalidate(lowStockItemsProvider);
}

final inventoryConsistencyProvider =
    FutureProvider<InventoryConsistencyReport>((ref) async {
  ref.watch(bottleTransactionsStreamProvider);
  ref.watch(customerBottleBalancesProvider);
  return ref.read(inventoryRepositoryProvider).validateConsistency();
});

final bottleReconciliationsStreamProvider =
    StreamProvider<List<CustomerBottleReconciliation>>((ref) {
  return ref.watch(inventoryRepositoryProvider).watchReconciliations();
});
