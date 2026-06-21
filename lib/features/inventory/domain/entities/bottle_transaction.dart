enum TransactionType {
  borrow,
  ret,
  damaged,
  purchase,
  added,
  missing,
  donation,
  adjustment,
  audit,
  customerAdjustment,
}

class BottleTransaction {
  final String id;
  final String? customerId;
  final TransactionType transactionType;
  final int quantity;
  final DateTime date;
  final String? reason;
  final String? notes;

  const BottleTransaction({
    required this.id,
    this.customerId,
    required this.transactionType,
    required this.quantity,
    required this.date,
    this.reason,
    this.notes,
  });

  /// Delivery-linked rows cannot be edited manually.
  bool get isDeliveryLinked =>
      id.endsWith('_borrow') || id.endsWith('_collect');

  static TransactionType typeFromString(String s) {
    switch (s) {
      case 'return':
        return TransactionType.ret;
      case 'damaged':
        return TransactionType.damaged;
      case 'purchase':
        return TransactionType.purchase;
      case 'added':
        return TransactionType.added;
      case 'missing':
        return TransactionType.missing;
      case 'donation':
        return TransactionType.donation;
      case 'adjustment':
        return TransactionType.adjustment;
      case 'audit':
        return TransactionType.audit;
      case 'customer_adjustment':
        return TransactionType.customerAdjustment;
      default:
        return TransactionType.borrow;
    }
  }

  static String typeToString(TransactionType t) {
    switch (t) {
      case TransactionType.ret:
        return 'return';
      case TransactionType.damaged:
        return 'damaged';
      case TransactionType.purchase:
        return 'purchase';
      case TransactionType.added:
        return 'added';
      case TransactionType.missing:
        return 'missing';
      case TransactionType.donation:
        return 'donation';
      case TransactionType.adjustment:
        return 'adjustment';
      case TransactionType.audit:
        return 'audit';
      case TransactionType.customerAdjustment:
        return 'customer_adjustment';
      case TransactionType.borrow:
        return 'borrow';
    }
  }

  static String typeLabel(TransactionType t) {
    switch (t) {
      case TransactionType.ret:
        return 'Bottle Collection';
      case TransactionType.damaged:
        return 'Damaged Bottles';
      case TransactionType.purchase:
        return 'Purchase New Bottles';
      case TransactionType.added:
        return 'Inventory Adjustment';
      case TransactionType.missing:
        return 'Missing Bottles';
      case TransactionType.donation:
        return 'Donated Bottles';
      case TransactionType.adjustment:
        return 'Inventory Adjustment';
      case TransactionType.audit:
        return 'Inventory Audit';
      case TransactionType.customerAdjustment:
        return 'Bottle Correction';
      case TransactionType.borrow:
        return 'Bottle Delivery';
    }
  }

  /// Short timeline headline for inventory history.
  static String timelineLabel(TransactionType t, int quantity) {
    switch (t) {
      case TransactionType.ret:
        return 'Bottle Collection — $quantity Bottles';
      case TransactionType.damaged:
        return 'Marked $quantity Bottles Damaged';
      case TransactionType.purchase:
        return 'Added $quantity New Bottles to Inventory';
      case TransactionType.added:
        return 'Inventory Adjustment +$quantity Filled Bottles';
      case TransactionType.missing:
        return 'Marked $quantity Bottles Missing';
      case TransactionType.donation:
        return 'Donated $quantity Bottles';
      case TransactionType.adjustment:
        return quantity >= 0
            ? 'Inventory Adjustment +$quantity Filled Bottles'
            : 'Inventory Adjustment $quantity Filled Bottles';
      case TransactionType.audit:
        return 'Inventory Audit';
      case TransactionType.customerAdjustment:
        return quantity >= 0
            ? 'Corrected +$quantity Bottles'
            : 'Corrected $quantity Bottles';
      case TransactionType.borrow:
        return 'Bottle Delivery — $quantity Bottles';
    }
  }

  /// Customer-facing ledger label (delivery/collection workflow).
  static String ledgerLabel(TransactionType t) {
    switch (t) {
      case TransactionType.ret:
        return 'Collected';
      case TransactionType.borrow:
        return 'Delivered';
      case TransactionType.customerAdjustment:
        return 'Bottle Correction';
      default:
        return typeLabel(t);
    }
  }
}
