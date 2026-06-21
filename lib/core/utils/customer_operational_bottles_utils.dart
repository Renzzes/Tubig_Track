import '../../features/deliveries/domain/entities/delivery.dart';

/// Operational bottle counters for customer profile UI (v1.6.1).
///
/// These reflect the current collect → deliver cycle only. Historical ledger,
/// reports, and statements continue to use lifetime transaction totals.
class CustomerOperationalBottlesUtils {
  CustomerOperationalBottlesUtils._();

  static int pendingDeliveryQty(List<Delivery> deliveries) {
    return deliveries
        .where(
          (d) =>
              d.deliveryStatus == DeliveryStatus.scheduled ||
              d.deliveryStatus == DeliveryStatus.inProgress,
        )
        .fold(0, (sum, d) => sum + d.quantity);
  }

  static DateTime? lastCompletedDeliveryDate(List<Delivery> deliveries) {
    DateTime? latest;
    for (final d in deliveries) {
      if (d.deliveryStatus != DeliveryStatus.completed) continue;
      if (latest == null || d.deliveryDate.isAfter(latest)) {
        latest = d.deliveryDate;
      }
    }
    return latest;
  }

  /// Bottles collected from the customer that are waiting to be delivered.
  ///
  /// Counts return transactions after the most recent completed delivery.
  /// When a delivery completes, the cycle resets and this returns 0 until
  /// new bottles are collected.
  static int operationalCollected({
    required List<Delivery> deliveries,
    required Iterable<({DateTime date, int quantity, String id})> returnEntries,
  }) {
    final lastCompleted = lastCompletedDeliveryDate(deliveries);

    var count = 0;
    for (final entry in returnEntries) {
      if (entry.id.endsWith('_collect')) continue;
      if (lastCompleted != null && !entry.date.isAfter(lastCompleted)) {
        continue;
      }
      count += entry.quantity;
    }
    return count;
  }

  static bool hasActiveDelivery(List<Delivery> deliveries) {
    return deliveries.any(
      (d) =>
          d.deliveryStatus == DeliveryStatus.scheduled ||
          d.deliveryStatus == DeliveryStatus.inProgress,
    );
  }
}
