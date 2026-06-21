enum CustomerOwnedBottleEventType {
  setBalance,
  adjustBalance,
  collected,
  deliveryFilled,
}

extension CustomerOwnedBottleEventTypeX on CustomerOwnedBottleEventType {
  String get dbValue => switch (this) {
        CustomerOwnedBottleEventType.setBalance => 'set_balance',
        CustomerOwnedBottleEventType.adjustBalance => 'adjust_balance',
        CustomerOwnedBottleEventType.collected => 'collected',
        CustomerOwnedBottleEventType.deliveryFilled => 'delivery_filled',
      };

  static CustomerOwnedBottleEventType fromDb(String value) => switch (value) {
        'set_balance' => CustomerOwnedBottleEventType.setBalance,
        'adjust_balance' => CustomerOwnedBottleEventType.adjustBalance,
        'collected' => CustomerOwnedBottleEventType.collected,
        'delivery_filled' => CustomerOwnedBottleEventType.deliveryFilled,
        _ => CustomerOwnedBottleEventType.adjustBalance,
      };

  String get label => switch (this) {
        CustomerOwnedBottleEventType.setBalance =>
          'Set Customer-Owned Balance',
        CustomerOwnedBottleEventType.adjustBalance =>
          'Adjust Customer-Owned Balance',
        CustomerOwnedBottleEventType.collected => 'Collected Bottles',
        CustomerOwnedBottleEventType.deliveryFilled => 'Delivered Bottles',
      };
}

class CustomerOwnedBottleLog {
  final String id;
  final String customerId;
  final CustomerOwnedBottleEventType eventType;
  final int businessOwnedDelta;
  final int customerOwnedDelta;
  final int businessOwnedAfter;
  final int customerOwnedAfter;
  final DateTime date;
  final String? notes;
  final String? deliveryId;
  final String? bottleTransactionId;

  const CustomerOwnedBottleLog({
    required this.id,
    required this.customerId,
    required this.eventType,
    required this.businessOwnedDelta,
    required this.customerOwnedDelta,
    required this.businessOwnedAfter,
    required this.customerOwnedAfter,
    required this.date,
    this.notes,
    this.deliveryId,
    this.bottleTransactionId,
  });
}

class CustomerBottleOwnershipLedgerEntry {
  final DateTime date;
  final String headline;
  final int? businessOwnedDelta;
  final int? customerOwnedDelta;
  final int businessOwnedAfter;
  final int customerOwnedAfter;
  final String? notes;
  final String? sourceId;

  const CustomerBottleOwnershipLedgerEntry({
    required this.date,
    required this.headline,
    this.businessOwnedDelta,
    this.customerOwnedDelta,
    required this.businessOwnedAfter,
    required this.customerOwnedAfter,
    this.notes,
    this.sourceId,
  });

  bool get hasBusinessDelta =>
      businessOwnedDelta != null && businessOwnedDelta != 0;

  bool get hasCustomerOwnedDelta =>
      customerOwnedDelta != null && customerOwnedDelta != 0;
}
