class CustomerStatementLine {
  final DateTime date;
  final String description;
  final String detail;

  const CustomerStatementLine({
    required this.date,
    required this.description,
    required this.detail,
  });
}

class CustomerStatementData {
  final String customerName;
  final DateTime generatedAt;
  final int businessOwnedBottlesHeld;
  final int customerOwnedBottlesHeld;
  final int totalBottlesAtCustomer;
  final double outstandingBalance;
  final double depositBalance;
  final double totalPaid;
  final int missingBottles;
  final int damagedBottles;
  final List<CustomerStatementLine> recentDeliveries;
  final List<CustomerStatementLine> recentCollections;
  final List<CustomerStatementLine> recentPayments;
  final List<CustomerStatementLine> walkInBusinessBottleSales;
  final List<CustomerStatementLine> walkInRefills;
  final List<CustomerStatementLine> walkInExchanges;

  const CustomerStatementData({
    required this.customerName,
    required this.generatedAt,
    required this.businessOwnedBottlesHeld,
    required this.customerOwnedBottlesHeld,
    required this.totalBottlesAtCustomer,
    required this.outstandingBalance,
    required this.depositBalance,
    required this.totalPaid,
    required this.missingBottles,
    required this.damagedBottles,
    required this.recentDeliveries,
    required this.recentCollections,
    required this.recentPayments,
    this.walkInBusinessBottleSales = const [],
    this.walkInRefills = const [],
    this.walkInExchanges = const [],
  });
}
