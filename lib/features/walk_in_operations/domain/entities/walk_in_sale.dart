enum WalkInType {
  businessBottles,
  customerRefill,
  exchange,
}

extension WalkInTypeX on WalkInType {
  String get storageValue => switch (this) {
        WalkInType.businessBottles => 'BUSINESS_BOTTLES',
        WalkInType.customerRefill => 'CUSTOMER_REFILL',
        WalkInType.exchange => 'EXCHANGE',
      };

  String get label => switch (this) {
        WalkInType.businessBottles => 'Borrow Bottle',
        WalkInType.customerRefill => 'Refill Own Bottle',
        WalkInType.exchange => 'Bottle Exchange',
      };

  String get subtitle => switch (this) {
        WalkInType.businessBottles =>
          'Customer uses business-owned bottles',
        WalkInType.customerRefill => 'Customer brings their own bottles',
        WalkInType.exchange => 'Return empties, receive filled bottles',
      };

  String get timelineLabel => switch (this) {
        WalkInType.businessBottles => 'Walk-In Borrow Bottle',
        WalkInType.customerRefill => 'Walk-In Refill Own Bottle',
        WalkInType.exchange => 'Walk-In Exchange',
      };

  static WalkInType fromStorage(String value) => switch (value) {
        'BUSINESS_BOTTLES' => WalkInType.businessBottles,
        'CUSTOMER_REFILL' => WalkInType.customerRefill,
        'EXCHANGE' => WalkInType.exchange,
        _ => WalkInType.businessBottles,
      };
}

class WalkInSale {
  final String id;
  final String? customerId;
  final WalkInType walkInType;
  final int businessOwnedQuantity;
  final int customerOwnedQuantity;
  final int returnedEmptyQuantity;
  final double pricePerBottle;
  final double totalAmount;
  final String paymentMethod;
  final String? notes;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WalkInSale({
    required this.id,
    this.customerId,
    required this.walkInType,
    this.businessOwnedQuantity = 0,
    this.customerOwnedQuantity = 0,
    this.returnedEmptyQuantity = 0,
    required this.pricePerBottle,
    required this.totalAmount,
    this.paymentMethod = 'Cash',
    this.notes,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  int get primaryQuantity => switch (walkInType) {
        WalkInType.businessBottles => businessOwnedQuantity,
        WalkInType.customerRefill => customerOwnedQuantity,
        WalkInType.exchange => businessOwnedQuantity,
      };

  String get quantityDescription => switch (walkInType) {
        WalkInType.businessBottles => '$businessOwnedQuantity bottles borrowed',
        WalkInType.customerRefill => '$customerOwnedQuantity bottles refilled',
        WalkInType.exchange =>
          '$returnedEmptyQuantity returned, $businessOwnedQuantity filled given',
      };

  /// Bottles sold for revenue, savings, and reporting.
  int get bottlesSold => switch (walkInType) {
        WalkInType.businessBottles => businessOwnedQuantity,
        WalkInType.customerRefill => customerOwnedQuantity,
        WalkInType.exchange => businessOwnedQuantity,
      };

  static const String walkInCustomerLabel = 'Walk-In Customer';
}
