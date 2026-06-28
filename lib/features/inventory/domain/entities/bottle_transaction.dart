enum TransactionType {
  borrow,
  ret,
  damaged,
  purchase,
  added,
  missing,
  donation,
  adjustment,
  emptyAdded,
  emptyAdjustment,
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
      case 'empty_added':
      case 'empty_bottle_intake':
        return TransactionType.emptyAdded;
      case 'empty_adjustment':
        return TransactionType.emptyAdjustment;
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
      case TransactionType.emptyAdded:
        return 'empty_bottle_intake';
      case TransactionType.emptyAdjustment:
        return 'empty_adjustment';
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
        return 'Add Filled Bottles';
      case TransactionType.missing:
        return 'Missing Bottles';
      case TransactionType.donation:
        return 'Donated Bottles';
      case TransactionType.adjustment:
        return 'Adjust Filled Bottles';
      case TransactionType.emptyAdded:
        return 'Add Empty Bottles';
      case TransactionType.emptyAdjustment:
        return 'Adjust Empty Bottles';
      case TransactionType.audit:
        return 'Inventory Audit';
      case TransactionType.customerAdjustment:
        return 'Bottle Correction';
      case TransactionType.borrow:
        return 'Bottle Delivery';
    }
  }

  /// Short timeline headline for inventory history.
  static String timelineLabel(
    TransactionType t,
    int quantity, {
    String? notes,
    String? reason,
  }) {
    final countTransition = _countTransitionLabel(notes);
    switch (t) {
      case TransactionType.ret:
        return 'Collect Bottles — −$quantity Customer / +$quantity Empty';
      case TransactionType.damaged:
        return 'Marked $quantity Bottles Damaged';
      case TransactionType.purchase:
        return 'Added $quantity New Bottles to Inventory';
      case TransactionType.added:
        return 'Supplier Stock Added — +$quantity Filled Bottles';
      case TransactionType.missing:
        return 'Marked $quantity Bottles Missing';
      case TransactionType.donation:
        return 'Donated $quantity Bottles';
      case TransactionType.adjustment:
        if (countTransition != null) {
          return 'Inventory Adjustment — Filled $countTransition '
              '(${quantity >= 0 ? '+' : ''}$quantity)';
        }
        return quantity >= 0
            ? 'Inventory Adjustment +$quantity Filled Bottles'
            : 'Inventory Adjustment $quantity Filled Bottles';
      case TransactionType.emptyAdded:
        final source = (reason != null && reason.isNotEmpty)
            ? reason
            : 'Manual Entry';
        final detail = notes != null && notes.isNotEmpty ? '\n$notes' : '';
        return 'Empty Bottle Intake — +$quantity Empty\nSource: $source$detail';
      case TransactionType.emptyAdjustment:
        if (countTransition != null) {
          return 'Inventory Adjustment — Empty $countTransition '
              '(${quantity >= 0 ? '+' : ''}$quantity)';
        }
        return quantity >= 0
            ? 'Inventory Adjustment +$quantity Empty Bottles'
            : 'Inventory Adjustment $quantity Empty Bottles';
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

  static String? _countTransitionLabel(String? notes) {
    if (notes == null || !notes.contains('→')) return null;
    return notes.trim();
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
      case TransactionType.added:
        return 'Supplier Stock Added';
      case TransactionType.emptyAdded:
        return 'Empty Bottle Intake';
      case TransactionType.adjustment:
      case TransactionType.emptyAdjustment:
        return 'Inventory Adjustment';
      default:
        return typeLabel(t);
    }
  }
}
