class Customer {
  final String id;
  final String name;
  final String? phone;
  final String? address;
  final String? notes;
  final int? pendingPhysicalBottleCount;
  final int customerOwnedBottlesHeld;
  final DateTime? lastPhysicalCountDate;
  final bool lastPhysicalCountVerified;
  final DateTime createdAt;

  const Customer({
    required this.id,
    required this.name,
    this.phone,
    this.address,
    this.notes,
    this.pendingPhysicalBottleCount,
    this.customerOwnedBottlesHeld = 0,
    this.lastPhysicalCountDate,
    this.lastPhysicalCountVerified = false,
    required this.createdAt,
  });

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? address,
    String? notes,
    int? pendingPhysicalBottleCount,
    int? customerOwnedBottlesHeld,
    DateTime? lastPhysicalCountDate,
    bool? lastPhysicalCountVerified,
    bool clearPendingPhysical = false,
    DateTime? createdAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      pendingPhysicalBottleCount: clearPendingPhysical
          ? null
          : (pendingPhysicalBottleCount ?? this.pendingPhysicalBottleCount),
      customerOwnedBottlesHeld:
          customerOwnedBottlesHeld ?? this.customerOwnedBottlesHeld,
      lastPhysicalCountDate:
          lastPhysicalCountDate ?? this.lastPhysicalCountDate,
      lastPhysicalCountVerified:
          lastPhysicalCountVerified ?? this.lastPhysicalCountVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Variance when a physical count was recorded but not yet adjusted.
  int? bottleVariance(int bottlesHeld) {
    if (pendingPhysicalBottleCount == null) return null;
    return pendingPhysicalBottleCount! - bottlesHeld;
  }
}

class CustomerStats {
  final int borrowedBottles;
  final int returnedBottles;
  final int damagedBottles;
  final int outstandingBottles;
  final int bottlesHeld;
  final int customerOwnedBottlesHeld;
  final int totalBottlesAtCustomer;
  final double unpaidBalance;
  final double depositBalance;
  final double totalAmountPaid;
  final int totalDeliveries;
  final double lifetimeRevenue;
  final int lifetimeBottlesDelivered;
  final DateTime? lastDeliveryDate;
  final DateTime? lastActivityDate;
  final bool hasInitialBalance;
  final int initialBottleBalance;
  final int operationalCollected;
  final int pendingDeliveryQty;

  const CustomerStats({
    required this.borrowedBottles,
    required this.returnedBottles,
    required this.damagedBottles,
    required this.outstandingBottles,
    required this.bottlesHeld,
    required this.customerOwnedBottlesHeld,
    required this.totalBottlesAtCustomer,
    required this.unpaidBalance,
    required this.depositBalance,
    required this.totalAmountPaid,
    required this.totalDeliveries,
    required this.lifetimeRevenue,
    required this.lifetimeBottlesDelivered,
    this.lastDeliveryDate,
    this.lastActivityDate,
    this.hasInitialBalance = false,
    this.initialBottleBalance = 0,
    this.operationalCollected = 0,
    this.pendingDeliveryQty = 0,
  });

  double get totalBalance => unpaidBalance + totalAmountPaid;
}
