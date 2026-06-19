enum TransactionType { borrow, ret, damaged, purchase }

class BottleTransaction {
  final String id;
  final String? customerId;
  final TransactionType transactionType;
  final int quantity;
  final DateTime date;
  final String? notes;

  const BottleTransaction({
    required this.id,
    this.customerId,
    required this.transactionType,
    required this.quantity,
    required this.date,
    this.notes,
  });

  static TransactionType typeFromString(String s) {
    switch (s) {
      case 'return':
        return TransactionType.ret;
      case 'damaged':
        return TransactionType.damaged;
      case 'purchase':
        return TransactionType.purchase;
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
      case TransactionType.borrow:
        return 'Borrow';
    }
  }
}
