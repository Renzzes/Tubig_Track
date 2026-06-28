enum DepositTransactionType {
  depositAdded,
  depositUsed,
  depositAdjustment,
  changeGiven,
}

class CustomerDeposit {
  final String id;
  final String customerId;
  final double amount;
  final DepositTransactionType transactionType;
  final DateTime createdAt;
  final String? notes;
  final String? deliveryId;

  const CustomerDeposit({
    required this.id,
    required this.customerId,
    required this.amount,
    required this.transactionType,
    required this.createdAt,
    this.notes,
    this.deliveryId,
  });

  static DepositTransactionType typeFromString(String s) {
    switch (s) {
      case 'deposit_used':
        return DepositTransactionType.depositUsed;
      case 'deposit_adjustment':
        return DepositTransactionType.depositAdjustment;
      case 'change_given':
        return DepositTransactionType.changeGiven;
      default:
        return DepositTransactionType.depositAdded;
    }
  }

  static String typeToString(DepositTransactionType t) {
    switch (t) {
      case DepositTransactionType.depositUsed:
        return 'deposit_used';
      case DepositTransactionType.depositAdjustment:
        return 'deposit_adjustment';
      case DepositTransactionType.changeGiven:
        return 'change_given';
      case DepositTransactionType.depositAdded:
        return 'deposit_added';
    }
  }

  static String typeLabel(DepositTransactionType t) {
    switch (t) {
      case DepositTransactionType.depositUsed:
        return 'Deposit Used';
      case DepositTransactionType.depositAdjustment:
        return 'Deposit Adjustment';
      case DepositTransactionType.changeGiven:
        return 'Change Given';
      case DepositTransactionType.depositAdded:
        return 'Deposit Added';
    }
  }
}
