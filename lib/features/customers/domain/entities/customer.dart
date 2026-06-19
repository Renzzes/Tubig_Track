class Customer {
  final String id;
  final String name;
  final String? phone;
  final String? address;
  final String? notes;
  final DateTime createdAt;

  const Customer({
    required this.id,
    required this.name,
    this.phone,
    this.address,
    this.notes,
    required this.createdAt,
  });

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? address,
    String? notes,
    DateTime? createdAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class CustomerStats {
  final int borrowedBottles;
  final int returnedBottles;
  final int damagedBottles;
  final int outstandingBottles;
  final double unpaidBalance;
  final double totalAmountPaid;
  final int totalDeliveries;
  final double lifetimeRevenue;
  final int lifetimeBottlesDelivered;
  final DateTime? lastDeliveryDate;

  const CustomerStats({
    required this.borrowedBottles,
    required this.returnedBottles,
    required this.damagedBottles,
    required this.outstandingBottles,
    required this.unpaidBalance,
    required this.totalAmountPaid,
    required this.totalDeliveries,
    required this.lifetimeRevenue,
    required this.lifetimeBottlesDelivered,
    this.lastDeliveryDate,
  });

  double get totalBalance => unpaidBalance + totalAmountPaid;
}
