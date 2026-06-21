import '../../features/inventory/domain/entities/bottle_transaction.dart';
import '../../features/supply_purchases/domain/entities/supply_purchase.dart';
import '../utils/currency_formatter.dart';

enum BusinessTimelineFilter {
  all,
  deliveries,
  collections,
  payments,
  inventory,
  suppliers,
  audits,
}

class BusinessTimelineEntry {
  final DateTime date;
  final String headline;
  final String? subtitle;
  final BusinessTimelineFilter category;
  final String? entityId;

  const BusinessTimelineEntry({
    required this.date,
    required this.headline,
    this.subtitle,
    required this.category,
    this.entityId,
  });
}

List<BusinessTimelineEntry> buildBusinessTimeline({
  required List<BottleTransaction> transactions,
  required List<SupplyPurchase> supplyPurchases,
  required Set<String> supplyLinkedTxIds,
  required Map<String, String> customerNames,
  required List<({String id, String customerId, int quantity, DateTime date})>
      deliveries,
  required List<({double amount, DateTime date, String? customerName})>
      payments,
  required List<({String label, double amount, DateTime date, String? customerName})>
      deposits,
}) {
  final entries = <BusinessTimelineEntry>[];

  for (final d in deliveries) {
    final name = customerNames[d.customerId] ?? 'Customer';
    entries.add(
      BusinessTimelineEntry(
        date: d.date,
        headline: 'Delivered ${d.quantity} Bottles',
        subtitle: name,
        category: BusinessTimelineFilter.deliveries,
        entityId: d.id,
      ),
    );
  }

  for (final tx in transactions) {
    if (tx.transactionType == TransactionType.purchase &&
        supplyLinkedTxIds.contains(tx.id)) {
      continue;
    }
    if (tx.transactionType == TransactionType.borrow &&
        tx.isDeliveryLinked) {
      continue;
    }

    final customerName =
        tx.customerId != null ? customerNames[tx.customerId!] : null;
    final headline = BottleTransaction.timelineLabel(
      tx.transactionType,
      tx.quantity,
    );

    BusinessTimelineFilter category;
    switch (tx.transactionType) {
      case TransactionType.ret:
        category = BusinessTimelineFilter.collections;
      case TransactionType.audit:
        category = BusinessTimelineFilter.audits;
      case TransactionType.purchase:
        category = BusinessTimelineFilter.inventory;
      default:
        category = BusinessTimelineFilter.inventory;
    }

    entries.add(
      BusinessTimelineEntry(
        date: tx.date,
        headline: headline,
        subtitle: customerName,
        category: category,
        entityId: tx.id,
      ),
    );
  }

  for (final purchase in supplyPurchases) {
    final itemLabel = purchase.itemType == 'Bottles'
        ? '${purchase.quantity} Filled Bottles'
        : '${purchase.quantity} ${purchase.itemType}';
    entries.add(
      BusinessTimelineEntry(
        date: purchase.purchaseDate,
        headline: 'Purchased $itemLabel',
        subtitle: purchase.supplierName,
        category: BusinessTimelineFilter.suppliers,
        entityId: purchase.id,
      ),
    );
  }

  for (final p in payments) {
    entries.add(
      BusinessTimelineEntry(
        date: p.date,
        headline: 'Received Payment ${CurrencyFormatter.format(p.amount)}',
        subtitle: p.customerName,
        category: BusinessTimelineFilter.payments,
      ),
    );
  }

  for (final d in deposits) {
    entries.add(
      BusinessTimelineEntry(
        date: d.date,
        headline: d.label,
        subtitle: d.customerName,
        category: BusinessTimelineFilter.payments,
      ),
    );
  }

  entries.sort((a, b) => b.date.compareTo(a.date));
  return entries;
}

List<BusinessTimelineEntry> filterBusinessTimeline(
  List<BusinessTimelineEntry> entries,
  BusinessTimelineFilter filter,
) {
  if (filter == BusinessTimelineFilter.all) return entries;
  return entries.where((e) => e.category == filter).toList();
}

String businessTimelineDateKey(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final d = DateTime(date.year, date.month, date.day);
  if (d == today) return 'Today';
  final yesterday = today.subtract(const Duration(days: 1));
  if (d == yesterday) return 'Yesterday';
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
  return '${names[date.month - 1]} ${date.day}';
}
