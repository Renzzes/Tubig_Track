class CustomerBottleBalance {
  final String customerId;
  final String customerName;
  final int bottlesHeld;
  final DateTime? lastDeliveryDate;

  const CustomerBottleBalance({
    required this.customerId,
    required this.customerName,
    required this.bottlesHeld,
    this.lastDeliveryDate,
  });
}
