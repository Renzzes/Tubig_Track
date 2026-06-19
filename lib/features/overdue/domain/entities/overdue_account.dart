class OverdueAccount {
  final String customerId;
  final String customerName;
  final String? phone;
  final double balance;
  final int daysOverdue;

  const OverdueAccount({
    required this.customerId,
    required this.customerName,
    this.phone,
    required this.balance,
    required this.daysOverdue,
  });
}

class OverdueSummary {
  final int customerCount;
  final double totalAmount;

  const OverdueSummary({
    required this.customerCount,
    required this.totalAmount,
  });

  static const empty = OverdueSummary(customerCount: 0, totalAmount: 0);
}
