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
}

class RecentTransaction {
  final String id;
  final RecentTransactionType type;
  final DateTime date;
  final String title;
  final String? subtitle;
  final double amount;
  final bool isCredit;

  const RecentTransaction({
    required this.id,
    required this.type,
    required this.date,
    required this.title,
    this.subtitle,
    required this.amount,
    required this.isCredit,
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
    }
  }
}
