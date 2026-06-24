import '../entities/customer_bottle_reconciliation.dart';
import '../entities/customer_owned_bottle_log.dart';
import '../entities/customer_bottle_balance.dart';
import '../entities/bottle_transaction.dart';
import '../entities/inventory_adjustment.dart';
import '../entities/inventory_audit.dart';
import '../entities/inventory_audit_summary.dart';
import '../entities/inventory_summary.dart';
import '../../../../core/utils/inventory_calculator.dart';

abstract class InventoryRepository {
  Future<InventorySummary> getSummary();
  Future<List<CustomerBottleBalance>> getCustomerBottleBalances();
  Future<InventoryConsistencyReport> validateConsistency();
  Future<bool> hasInitialCustomerBottleBalance(String customerId);
  Future<void> setInitialCustomerBottleBalance({
    required String customerId,
    required int quantity,
    DateTime? date,
  });
  Future<void> adjustCustomerBottleBalance({
    required String customerId,
    required int quantityDelta,
    String? reason,
    String? notes,
    DateTime? date,
  });
  Stream<List<BottleTransaction>> watchAll();
  Future<List<BottleTransaction>> getAll();
  Future<void> recordTransaction(BottleTransaction transaction);
  Future<void> updateTransaction(BottleTransaction transaction);
  Future<void> deleteTransaction(String id);
  Future<void> updateTotalInventory(int newTotal);

  Stream<List<InventoryAudit>> watchAudits();
  Stream<List<InventoryAdjustment>> watchAdjustments();
  Future<InventoryAuditSummary> getAuditSummary();
  Future<void> performAudit({
    required int physicalCount,
    required InventoryAuditAction action,
    String? adjustmentReason,
    String? notes,
  });

  Future<void> recordCustomerBottleReconciliation({
    required String customerId,
    required int expectedCount,
    required int actualCount,
    String? reason,
    String? notes,
    required bool applyAdjustment,
  });

  /// Updates stored bottle counts when a physical count differs from system.
  Future<void> recordCustomerBottleCountCheck({
    required String customerId,
    required int expectedBusinessOwned,
    required int actualBusinessOwned,
    required int expectedCustomerOwned,
    required int actualCustomerOwned,
    String? notes,
  });

  Future<void> setPendingPhysicalBottleCount({
    required String customerId,
    int? actualCount,
  });

  Stream<List<CustomerBottleReconciliation>> watchReconciliations();

  Future<List<CustomerBottleReconciliation>> getReconciliationsByCustomer(
    String customerId,
  );

  Future<int> getCustomerOwnedBottlesHeld(String customerId);

  Future<List<CustomerOwnedBottleLog>> getCustomerOwnedLogs(String customerId);

  Stream<List<CustomerOwnedBottleLog>> watchCustomerOwnedLogs(String customerId);

  Future<void> setCustomerOwnedBottleBalance({
    required String customerId,
    required int quantity,
    DateTime? date,
    String? notes,
  });

  Future<void> adjustCustomerOwnedBottleBalance({
    required String customerId,
    required int quantityDelta,
    String? reason,
    String? notes,
    DateTime? date,
  });

  Future<void> collectBottlesFromCustomer({
    required String customerId,
    required int businessOwnedCollected,
    required int customerOwnedCollected,
    DateTime? date,
    String? notes,
  });

  Future<void> syncDeliveryCustomerOwnedFilled({
    required String deliveryId,
    required String customerId,
    required int businessOwnedDelivered,
    required int customerOwnedFilled,
    required DateTime date,
    required bool isCompleted,
    String? notes,
  });

  Future<void> reverseDeliveryCustomerOwnedFilled(String deliveryId);
}
