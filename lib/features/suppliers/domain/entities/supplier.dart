class Supplier {
  final String id;
  final String name;
  final String? contactPerson;
  final String? mobile;
  final String? address;
  final String? notes;
  final DateTime createdAt;

  const Supplier({
    required this.id,
    required this.name,
    this.contactPerson,
    this.mobile,
    this.address,
    this.notes,
    required this.createdAt,
  });
}

class SupplierAnalytics {
  final int totalPurchases;
  final double totalAmount;
  final DateTime? lastPurchaseDate;
  final String? mostPurchasedItem;

  const SupplierAnalytics({
    required this.totalPurchases,
    required this.totalAmount,
    this.lastPurchaseDate,
    this.mostPurchasedItem,
  });
}
