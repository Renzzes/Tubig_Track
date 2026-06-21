import '../../features/supply_purchases/domain/entities/supply_purchase.dart';

class SupplyTimelineUtils {
  SupplyTimelineUtils._();

  static String supplierDeliveryHeadline(SupplyPurchase purchase) {
    final supplier = purchase.supplierName.trim();
    if (supplier.isNotEmpty) {
      return 'Supplier Delivered ${purchase.quantity} Filled Bottles from $supplier';
    }
    return 'Supplier Delivered ${purchase.quantity} Filled Bottles';
  }
}
