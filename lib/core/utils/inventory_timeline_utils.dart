import '../../features/inventory/domain/entities/bottle_transaction.dart';
import '../../features/supply_purchases/domain/entities/supply_purchase.dart';
import 'supply_timeline_utils.dart';

class InventoryTimelineEntry {
  final DateTime date;
  final String headline;
  final String? subtitle;
  final TransactionType? transactionType;
  final String? transactionId;
  final BottleTransaction? transaction;

  const InventoryTimelineEntry({
    required this.date,
    required this.headline,
    this.subtitle,
    this.transactionType,
    this.transactionId,
    this.transaction,
  });

  bool get isEditable =>
      transaction != null && !transaction!.isDeliveryLinked;
}

List<InventoryTimelineEntry> buildInventoryTimeline({
  required List<BottleTransaction> transactions,
  required List<SupplyPurchase> supplyPurchases,
  required Set<String> supplyLinkedTxIds,
  required Map<String, String> customerNames,
}) {
  final entries = <InventoryTimelineEntry>[];

  for (final tx in transactions) {
    if (tx.transactionType == TransactionType.purchase &&
        supplyLinkedTxIds.contains(tx.id)) {
      continue;
    }

    final customerName =
        tx.customerId != null ? customerNames[tx.customerId!] : null;
    final headline = BottleTransaction.timelineLabel(
      tx.transactionType,
      tx.quantity,
      notes: tx.notes,
      reason: tx.reason,
    );

    final subtitle = tx.transactionType == TransactionType.emptyAdded
        ? tx.reason
        : customerName;

    entries.add(
      InventoryTimelineEntry(
        date: tx.date,
        headline: headline,
        subtitle: subtitle,
        transactionType: tx.transactionType,
        transactionId: tx.id,
        transaction: tx,
      ),
    );
  }

  for (final purchase in supplyPurchases) {
    entries.add(
      InventoryTimelineEntry(
        date: purchase.purchaseDate,
        headline: SupplyTimelineUtils.supplierDeliveryHeadline(purchase),
        subtitle: purchase.notes,
      ),
    );
  }

  entries.sort((a, b) => b.date.compareTo(a.date));
  return entries;
}

String timelineDateKey(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final d = DateTime(date.year, date.month, date.day);
  if (d == today) return 'Today';
  final yesterday = today.subtract(const Duration(days: 1));
  if (d == yesterday) return 'Yesterday';
  return '${_monthName(date.month)} ${date.day}';
}

String _monthName(int month) {
  const names = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return names[month - 1];
}
