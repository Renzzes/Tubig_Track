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

  /// Delivery-linked borrow rows cannot be edited manually.
  bool get isDeliveryLinked => id.endsWith('_borrow');

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
      case TransactionType.borrow:
        return 'borrow';
    }
  }

  static String typeLabel(TransactionType t) {
    switch (t) {
      case TransactionType.ret:
        return 'Return';
      case TransactionType.damaged:
        return 'Damaged';
      case TransactionType.purchase:
        return 'Purchase';
      case TransactionType.added:
        return 'Add Bottles';
      case TransactionType.missing:
        return 'Missing';
      case TransactionType.donation:
        return 'Donation';
      case TransactionType.adjustment:
        return 'Adjustment';
      case TransactionType.audit:
        return 'Audit';
      case TransactionType.borrow:
        return 'Borrow';
    }
  }

  /// Customer-facing ledger label (delivery/collection workflow).
  static String ledgerLabel(TransactionType t) {
    switch (t) {
      case TransactionType.ret:
        return 'Collected';
      case TransactionType.borrow:
        return 'Delivered';
      default:
        return typeLabel(t);
    }
  }
}
