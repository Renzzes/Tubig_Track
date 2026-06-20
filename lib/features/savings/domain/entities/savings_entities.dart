enum SavingsLedgerType {
  deliveryProfit,
  dispenserProfit,
  expenseDeduction,
  maintenanceDeduction,
  bottlePurchase,
  manualAddition,
  otherOperational,
}

extension SavingsLedgerTypeX on SavingsLedgerType {
  String get label {
    switch (this) {
      case SavingsLedgerType.deliveryProfit:
        return 'Delivery Profit';
      case SavingsLedgerType.dispenserProfit:
        return 'Dispenser Profit';
      case SavingsLedgerType.expenseDeduction:
        return 'Expense Deduction';
      case SavingsLedgerType.maintenanceDeduction:
        return 'Maintenance Cost';
      case SavingsLedgerType.bottlePurchase:
        return 'Bottle Purchase';
      case SavingsLedgerType.manualAddition:
        return 'Manual Savings Addition';
      case SavingsLedgerType.otherOperational:
        return 'Operational Cost';
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
      type == SavingsLedgerType.dispenserProfit ||
      type == SavingsLedgerType.manualAddition;
}

class SavingsSummary {
  final double currentSavings;
  final double deliveryProfit;
  final double dispenserProfit;
  final double totalExpenses;
  final double maintenanceCosts;
  final double bottlePurchases;
  final double otherOperationalCosts;
  final double manualAdditions;

  const SavingsSummary({
    required this.currentSavings,
    required this.deliveryProfit,
    required this.dispenserProfit,
    required this.totalExpenses,
    required this.maintenanceCosts,
    required this.bottlePurchases,
    required this.otherOperationalCosts,
    required this.manualAdditions,
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
