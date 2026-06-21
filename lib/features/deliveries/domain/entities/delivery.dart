enum PaymentStatus { paid, unpaid, partial }

enum DeliveryStatus { scheduled, inProgress, completed, cancelled }

class Delivery {
  final String id;
  final String customerId;
  final int quantity;
  final double pricePerBottle;
  final double totalAmount;
  final PaymentStatus paymentStatus;
  final double amountPaid;
  final double depositApplied;
  final double remainingBalance;
  final DateTime deliveryDate;
  final String? deliveryTime;
  final DeliveryStatus deliveryStatus;
  final int collectedEmptyBottles;
  final String? notes;
  final String? receiptNumber;

  const Delivery({
    required this.id,
    required this.customerId,
    required this.quantity,
    required this.pricePerBottle,
    required this.totalAmount,
    required this.paymentStatus,
    required this.amountPaid,
    this.depositApplied = 0,
    required this.remainingBalance,
    required this.deliveryDate,
    this.deliveryTime,
    this.deliveryStatus = DeliveryStatus.completed,
    this.collectedEmptyBottles = 0,
    this.notes,
    this.receiptNumber,
  });

  Delivery copyWith({
    String? id,
    String? customerId,
    int? quantity,
    double? pricePerBottle,
    double? totalAmount,
    PaymentStatus? paymentStatus,
    double? amountPaid,
    double? depositApplied,
    double? remainingBalance,
    DateTime? deliveryDate,
    String? deliveryTime,
    DeliveryStatus? deliveryStatus,
    int? collectedEmptyBottles,
    String? notes,
    String? receiptNumber,
  }) {
    return Delivery(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      quantity: quantity ?? this.quantity,
      pricePerBottle: pricePerBottle ?? this.pricePerBottle,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      amountPaid: amountPaid ?? this.amountPaid,
      depositApplied: depositApplied ?? this.depositApplied,
      remainingBalance: remainingBalance ?? this.remainingBalance,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      collectedEmptyBottles:
          collectedEmptyBottles ?? this.collectedEmptyBottles,
      notes: notes ?? this.notes,
      receiptNumber: receiptNumber ?? this.receiptNumber,
    );
  }

  static PaymentStatus paymentStatusFromString(String s) {
    switch (s) {
      case 'paid':
        return PaymentStatus.paid;
      case 'partial':
        return PaymentStatus.partial;
      default:
        return PaymentStatus.unpaid;
    }
  }

  static String paymentStatusToString(PaymentStatus s) {
    switch (s) {
      case PaymentStatus.paid:
        return 'paid';
      case PaymentStatus.partial:
        return 'partial';
      case PaymentStatus.unpaid:
        return 'unpaid';
    }
  }

  // Legacy aliases for backward compat
  static PaymentStatus statusFromString(String s) =>
      paymentStatusFromString(s);
  static String statusToString(PaymentStatus s) => paymentStatusToString(s);

  static DeliveryStatus deliveryStatusFromString(String s) {
    switch (s) {
      case 'scheduled':
        return DeliveryStatus.scheduled;
      case 'in_progress':
        return DeliveryStatus.inProgress;
      case 'cancelled':
        return DeliveryStatus.cancelled;
      default:
        return DeliveryStatus.completed;
    }
  }

  static String deliveryStatusToString(DeliveryStatus s) {
    switch (s) {
      case DeliveryStatus.scheduled:
        return 'scheduled';
      case DeliveryStatus.inProgress:
        return 'in_progress';
      case DeliveryStatus.cancelled:
        return 'cancelled';
      case DeliveryStatus.completed:
        return 'completed';
    }
  }
}
