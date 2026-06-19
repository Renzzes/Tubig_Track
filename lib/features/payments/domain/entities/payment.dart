class Payment {
  final String id;
  final String customerId;
  final String? deliveryId;
  final double amount;
  final DateTime paymentDate;
  final String? notes;

  const Payment({
    required this.id,
    required this.customerId,
    this.deliveryId,
    required this.amount,
    required this.paymentDate,
    this.notes,
  });
}
