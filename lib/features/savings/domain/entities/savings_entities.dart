enum SavingsLedgerType {
  deliveryProfit,
  walkInProfit,
  dispenserProfit,
  expenseDeduction,
  maintenanceDeduction,
  manualAddition,
  otherOperational,
  savingsTransfer,
  savingsWithdrawal,
}

extension SavingsLedgerTypeX on SavingsLedgerType {
  String get label {
    switch (this) {
      case SavingsLedgerType.deliveryProfit:
        return 'Delivery Profit';
      case SavingsLedgerType.walkInProfit:
        return 'Walk-In Profit';
      case SavingsLedgerType.dispenserProfit:
        return 'Dispenser Profit';
      case SavingsLedgerType.expenseDeduction:
        return 'Expense Deduction';
      case SavingsLedgerType.maintenanceDeduction:
        return 'Maintenance Cost';
      case SavingsLedgerType.manualAddition:
        return 'Owner Capital';
      case SavingsLedgerType.otherOperational:
        return 'Operational Cost';
      case SavingsLedgerType.savingsTransfer:
        return 'Transfer to Savings';
      case SavingsLedgerType.savingsWithdrawal:
        return 'Withdraw from Savings';
    }
  }
}

class SavingsLedgerEntry {
  final String id;
  final SavingsLedgerType type;
  final DateTime date;
  final double amount;
  final String? notes;

  const SavingsLedgerEntry({
    required this.id,
    required this.type,
    required this.date,
    required this.amount,
    this.notes,
  });

  bool get isCredit =>
      type == SavingsLedgerType.deliveryProfit ||
      type == SavingsLedgerType.walkInProfit ||
      type == SavingsLedgerType.dispenserProfit ||
      type == SavingsLedgerType.manualAddition ||
      type == SavingsLedgerType.savingsWithdrawal;

  bool get isSavingsTransfer =>
      type == SavingsLedgerType.savingsTransfer ||
      type == SavingsLedgerType.savingsWithdrawal;
}

class SavingsSummary {
  /// Profit accumulated from operations (excludes owner capital).
  final double currentSavings;
  final double deliveryProfit;
  final double walkInProfit;
  final double dispenserProfit;
  final double totalExpenses;
  final double maintenanceCosts;
  final double otherOperationalCosts;
  /// Owner investments / startup capital (not savings, not profit).
  final double ownerCapital;
  /// Money intentionally set aside in the savings account.
  final double savingsAccountBalance;

  const SavingsSummary({
    required this.currentSavings,
    required this.deliveryProfit,
    required this.walkInProfit,
    required this.dispenserProfit,
    required this.totalExpenses,
    required this.maintenanceCosts,
    required this.otherOperationalCosts,
    required this.ownerCapital,
    required this.savingsAccountBalance,
  });

  /// Alias for [currentSavings] — profit accumulated from business operations.
  double get accumulatedProfit => currentSavings;

  /// Total money in the business (profit + owner capital).
  double get totalBusinessMoney => currentSavings + ownerCapital;

  /// Operating cash not yet moved to the savings account.
  double get businessCash => totalBusinessMoney - savingsAccountBalance;
}

enum SavingsTransferType { transfer, withdraw }

extension SavingsTransferTypeX on SavingsTransferType {
  String get storage => switch (this) {
        SavingsTransferType.transfer => 'transfer',
        SavingsTransferType.withdraw => 'withdraw',
      };

  String get label => switch (this) {
        SavingsTransferType.transfer => 'Transfer to Savings',
        SavingsTransferType.withdraw => 'Withdraw from Savings',
      };

  static SavingsTransferType fromStorage(String value) => switch (value) {
        'withdraw' => SavingsTransferType.withdraw,
        _ => SavingsTransferType.transfer,
      };
}

class SavingsTransfer {
  final String id;
  final double amount;
  final SavingsTransferType type;
  final DateTime date;
  final String? notes;

  const SavingsTransfer({
    required this.id,
    required this.amount,
    required this.type,
    required this.date,
    this.notes,
  });
}

class SavingsContribution {
  final String id;
  final double amount;
  final DateTime date;
  final String? notes;

  const SavingsContribution({
    required this.id,
    required this.amount,
    required this.date,
    this.notes,
  });
}
