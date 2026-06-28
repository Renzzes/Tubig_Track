import '../../features/inventory/domain/entities/bottle_transaction.dart';
import '../../features/inventory/domain/entities/inventory_adjustment.dart';
import '../../features/inventory/domain/entities/inventory_audit.dart';
import '../../features/supply_purchases/domain/entities/supply_purchase.dart';

enum InventoryActivityCategory {
  supplierDelivery,
  emptyBottleIntake,
  inventoryAdjustment,
  bottleCorrection,
  auditReconciliation,
  bottleCollection,
  addFilledBottles,
  other,
}

class InventoryActivityEntry {
  final DateTime date;
  final InventoryActivityCategory category;
  final String title;
  final String? subtitle;
  final String? detail;

  const InventoryActivityEntry({
    required this.date,
    required this.category,
    required this.title,
    this.subtitle,
    this.detail,
  });

  String get categoryLabel => switch (category) {
        InventoryActivityCategory.supplierDelivery => 'Supplier Delivery',
        InventoryActivityCategory.emptyBottleIntake => 'Empty Bottle Intake',
        InventoryActivityCategory.inventoryAdjustment => 'Inventory Adjustment',
        InventoryActivityCategory.bottleCorrection => 'Bottle Correction',
        InventoryActivityCategory.auditReconciliation => 'Audit Reconciliation',
        InventoryActivityCategory.bottleCollection => 'Customer Collection',
        InventoryActivityCategory.addFilledBottles => 'Add Filled Bottles',
        InventoryActivityCategory.other => 'Inventory Activity',
      };
}

InventoryActivityCategory categoryForTransaction(TransactionType type) {
  return switch (type) {
    TransactionType.emptyAdded => InventoryActivityCategory.emptyBottleIntake,
    TransactionType.adjustment ||
    TransactionType.emptyAdjustment =>
      InventoryActivityCategory.inventoryAdjustment,
    TransactionType.customerAdjustment =>
      InventoryActivityCategory.bottleCorrection,
    TransactionType.audit => InventoryActivityCategory.auditReconciliation,
    TransactionType.ret => InventoryActivityCategory.bottleCollection,
    TransactionType.added => InventoryActivityCategory.addFilledBottles,
    _ => InventoryActivityCategory.other,
  };
}

List<InventoryActivityEntry> buildInventoryActivityHistory({
  required List<BottleTransaction> transactions,
  required List<InventoryAdjustment> adjustments,
  required List<InventoryAudit> audits,
  required List<SupplyPurchase> supplyPurchases,
}) {
  final entries = <InventoryActivityEntry>[];

  for (final tx in transactions) {
    entries.add(
      InventoryActivityEntry(
        date: tx.date,
        category: categoryForTransaction(tx.transactionType),
        title: BottleTransaction.timelineLabel(
          tx.transactionType,
          tx.quantity,
          notes: tx.notes,
          reason: tx.reason,
        ),
        subtitle: tx.reason,
        detail: tx.notes,
      ),
    );
  }

  for (final purchase in supplyPurchases) {
    entries.add(
      InventoryActivityEntry(
        date: purchase.purchaseDate,
        category: InventoryActivityCategory.supplierDelivery,
        title: 'Supplier Delivery — +${purchase.quantity} Filled',
        subtitle: purchase.supplierName,
        detail: purchase.notes,
      ),
    );
  }

  for (final audit in audits) {
    if (audit.actionTaken == InventoryAuditAction.balanced) continue;
    entries.add(
      InventoryActivityEntry(
        date: audit.auditDate,
        category: InventoryActivityCategory.auditReconciliation,
        title:
            'Audit Reconciliation — ${audit.difference >= 0 ? '+' : ''}${audit.difference}',
        detail: audit.notes,
      ),
    );
  }

  entries.sort((a, b) => b.date.compareTo(a.date));
  return entries;
}

bool isEmptyBottleIntakeType(String transactionType) =>
    transactionType == 'empty_bottle_intake' || transactionType == 'empty_added';
