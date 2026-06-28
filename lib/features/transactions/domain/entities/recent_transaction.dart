enum RecentTransactionType {
  delivery,
  payment,
  expense,
  bottleBorrow,
  bottleReturn,
  bottlePurchase,
  bottleFilledAdded,
  bottleFilledAdjustment,
  bottleEmptyAdded,
  bottleEmptyAdjustment,
  bottleDamaged,
  bottleMissing,
  bottleDonation,
  bottleAdjustment,
  bottleAudit,
  dispenserSale,
  savingsAddition,
  savingsTransfer,
  savingsWithdraw,
  supplyPurchase,
  depositAdded,
  depositUsed,
  depositAdjustment,
  depositChangeGiven,
  walkInOperation,
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

  /// Inventory-only events that change bottle ownership, not cash balances.
  bool get isInventoryEvent {
    switch (type) {
      case RecentTransactionType.bottlePurchase:
      case RecentTransactionType.bottleFilledAdded:
      case RecentTransactionType.bottleFilledAdjustment:
      case RecentTransactionType.bottleEmptyAdded:
      case RecentTransactionType.bottleEmptyAdjustment:
      case RecentTransactionType.bottleDamaged:
      case RecentTransactionType.bottleMissing:
      case RecentTransactionType.bottleDonation:
      case RecentTransactionType.bottleAdjustment:
      case RecentTransactionType.bottleAudit:
      case RecentTransactionType.bottleBorrow:
      case RecentTransactionType.bottleReturn:
        return true;
      default:
        return false;
    }
  }

  String get quantityLabel {
    final qty = amount.toInt();
    final prefix = isCredit ? '+' : '-';
    return '$prefix$qty bottles';
  }

  String get typeLabel {
    switch (type) {
      case RecentTransactionType.delivery:
        return 'Delivery';
      case RecentTransactionType.payment:
        return 'Payment';
      case RecentTransactionType.expense:
        return 'Expense';
      case RecentTransactionType.bottleBorrow:
        return 'Bottle Delivery';
      case RecentTransactionType.bottleReturn:
        return 'Bottle Collection';
      case RecentTransactionType.bottlePurchase:
        return 'Purchase New Bottles';
      case RecentTransactionType.bottleFilledAdded:
        return 'Add Filled Bottles';
      case RecentTransactionType.bottleFilledAdjustment:
        return 'Adjust Filled Bottles';
      case RecentTransactionType.bottleEmptyAdded:
        return 'Add Empty Bottles';
      case RecentTransactionType.bottleEmptyAdjustment:
        return 'Adjust Empty Bottles';
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
        return 'Owner Capital';
      case RecentTransactionType.savingsTransfer:
        return 'Transfer to Savings';
      case RecentTransactionType.savingsWithdraw:
        return 'Withdraw from Savings';
      case RecentTransactionType.supplyPurchase:
        return 'Supplier Delivery';
      case RecentTransactionType.depositAdded:
        return 'Deposit Added';
      case RecentTransactionType.depositUsed:
        return 'Deposit Used';
      case RecentTransactionType.depositAdjustment:
        return 'Deposit Adjustment';
      case RecentTransactionType.depositChangeGiven:
        return 'Change Given';
      case RecentTransactionType.walkInOperation:
        return 'Walk-In Operation';
    }
  }

  /// Parses legacy prefixed id if sourceId not set.
  static String parseSourceId(String prefixedId) {
    final idx = prefixedId.indexOf('_');
    if (idx <= 0) return prefixedId;
    return prefixedId.substring(idx + 1);
  }
}
