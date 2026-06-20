import '../entities/bottle_transaction.dart';
import '../entities/inventory_adjustment.dart';
import '../entities/inventory_audit.dart';
import '../entities/inventory_audit_summary.dart';
import '../entities/inventory_summary.dart';

abstract class InventoryRepository {
  Future<InventorySummary> getSummary();
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
}
