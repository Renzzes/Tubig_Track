class CustomerBottleBalance {
  final String customerId;
  final String customerName;
  final int bottlesHeld;
  final DateTime? lastDeliveryDate;
  final double unpaidBalance;

  const CustomerBottleBalance({
    required this.customerId,
    required this.customerName,
    required this.bottlesHeld,
    this.lastDeliveryDate,
    this.unpaidBalance = 0,
  });
}
