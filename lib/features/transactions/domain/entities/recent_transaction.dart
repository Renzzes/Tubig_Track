enum RecentTransactionType {
  delivery,
  payment,
  expense,
  bottleBorrow,
  bottleReturn,
  bottlePurchase,
  bottleDamaged,
  dispenserSale,
  savingsAddition,
  supplyPurchase,
}

class RecentTransaction {
  final String id;
  final String sourceId;
  final RecentTransactionType type;
  final DateTime date;
  final String title;
  final String? subtitle;
  final double amount;
  final bool isCredit;
  final String? customerId;
  final String? customerName;
  final String? deliveryId;
  final String? expenseCategory;

  const RecentTransaction({
    required this.id,
    required this.sourceId,
    required this.type,
    required this.date,
    required this.title,
    this.subtitle,
    required this.amount,
    required this.isCredit,
    this.customerId,
    this.customerName,
    this.deliveryId,
    this.expenseCategory,
  });

  String get typeLabel {
    switch (type) {
      case RecentTransactionType.delivery:
        return 'Delivery';
      case RecentTransactionType.payment:
        return 'Payment';
      case RecentTransactionType.expense:
        return 'Expense';
      case RecentTransactionType.bottleBorrow:
        return 'Bottle Borrow';
      case RecentTransactionType.bottleReturn:
        return 'Bottle Return';
      case RecentTransactionType.bottlePurchase:
        return 'Inventory Purchase';
      case RecentTransactionType.bottleDamaged:
        return 'Damaged Bottles';
      case RecentTransactionType.dispenserSale:
        return 'Dispenser Sale';
      case RecentTransactionType.savingsAddition:
        return 'Savings Addition';
      case RecentTransactionType.supplyPurchase:
        return 'Supply Purchase';
    }
  }

  /// Parses legacy prefixed id if sourceId not set.
  static String parseSourceId(String prefixedId) {
    final idx = prefixedId.indexOf('_');
    if (idx <= 0) return prefixedId;
    return prefixedId.substring(idx + 1);
  }
}
