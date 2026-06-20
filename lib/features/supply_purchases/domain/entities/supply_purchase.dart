class SupplyPurchase {
  final String id;
  final DateTime purchaseDate;
  final String supplierName;
  final String itemType;
  final int quantity;
  final double unitCost;
  final double totalCost;
  final String? notes;
  final String expenseId;
  final String? bottleTransactionId;

  const SupplyPurchase({
    required this.id,
    required this.purchaseDate,
    required this.supplierName,
    required this.itemType,
    required this.quantity,
    required this.unitCost,
    required this.totalCost,
    this.notes,
    required this.expenseId,
    this.bottleTransactionId,
  });

  String get description => '$quantity $itemType';

  static String stockKeyForItemType(String itemType) {
    switch (itemType) {
      case 'Gallons':
        return 'gallons';
      case 'Caps':
        return 'caps';
      case 'Water Stocks':
        return 'water_stocks';
      case 'Others':
        return 'others';
      default:
        return 'others';
    }
  }

  static bool affectsBottleInventory(String itemType) => itemType == 'Bottles';
}

class SupplierSummaryEntry {
  final String supplierName;
  final int purchaseCount;
  final double totalCost;

  const SupplierSummaryEntry({
    required this.supplierName,
    required this.purchaseCount,
    required this.totalCost,
  });
}

class SupplyPurchaseDetail {
  final String description;
  final double amount;
  final String? supplier;
  final DateTime date;

  const SupplyPurchaseDetail({
    required this.description,
    required this.amount,
    this.supplier,
    required this.date,
  });
}
