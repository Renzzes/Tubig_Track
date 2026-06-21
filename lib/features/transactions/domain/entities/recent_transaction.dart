enum RecentTransactionType {
  delivery,
  payment,
  expense,
  bottleBorrow,
  bottleReturn,
  bottlePurchase,
  bottleDamaged,
  bottleMissing,
  bottleDonation,
  bottleAdjustment,
  bottleAudit,
  dispenserSale,
  savingsAddition,
  supplyPurchase,
  depositAdded,
  depositUsed,
  depositAdjustment,
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
      case RecentTransactionType.bottleMissing:
        return 'Missing Bottles';
      case RecentTransactionType.bottleDonation:
        return 'Donated Bottles';
      case RecentTransactionType.bottleAdjustment:
        return 'Inventory Adjustment';
      case RecentTransactionType.bottleAudit:
        return 'Inventory Audit';
      case RecentTransactionType.dispenserSale:
        return 'Dispenser Sale';
      case RecentTransactionType.savingsAddition:
        return 'Savings Addition';
      case RecentTransactionType.supplyPurchase:
        return 'Supply Purchase';
      case RecentTransactionType.depositAdded:
        return 'Deposit Added';
      case RecentTransactionType.depositUsed:
        return 'Deposit Used';
      case RecentTransactionType.depositAdjustment:
        return 'Deposit Adjustment';
    }
  }

  /// Parses legacy prefixed id if sourceId not set.
  static String parseSourceId(String prefixedId) {
    final idx = prefixedId.indexOf('_');
    if (idx <= 0) return prefixedId;
    return prefixedId.substring(idx + 1);
  }
}
