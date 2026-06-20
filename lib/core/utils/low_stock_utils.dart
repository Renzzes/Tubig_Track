import '../../features/settings/domain/entities/app_settings.dart';
import '../../features/inventory/domain/entities/inventory_summary.dart';

class LowStockItem {
  final String label;
  final int remaining;
  final int minimum;

  const LowStockItem({
    required this.label,
    required this.remaining,
    required this.minimum,
  });
}

class LowStockUtils {
  LowStockUtils._();

  static List<LowStockItem> check(
    InventorySummary inventory,
    AppSettings settings,
  ) {
    final items = <LowStockItem>[];
    if (inventory.availableBottles <= settings.minBottles) {
      items.add(LowStockItem(
        label: 'Bottles',
        remaining: inventory.availableBottles,
        minimum: settings.minBottles,
      ));
    }
    if (inventory.gallonsStock <= settings.minGallons) {
      items.add(LowStockItem(
        label: 'Gallons',
        remaining: inventory.gallonsStock,
        minimum: settings.minGallons,
      ));
    }
    if (inventory.capsStock <= settings.minCaps) {
      items.add(LowStockItem(
        label: 'Caps',
        remaining: inventory.capsStock,
        minimum: settings.minCaps,
      ));
    }
    if (inventory.waterStocks <= settings.minWaterStocks) {
      items.add(LowStockItem(
        label: 'Water Stocks',
        remaining: inventory.waterStocks,
        minimum: settings.minWaterStocks,
      ));
    }
    return items;
  }
}
