import '../../../../core/constants/app_constants.dart';
import '../../features/inventory/domain/entities/bottle_transaction.dart';
import '../../features/inventory/domain/entities/customer_owned_bottle_log.dart';

/// Builds a unified ownership ledger (business-owned + customer-owned).
List<CustomerBottleOwnershipLedgerEntry> buildCustomerOwnershipLedger({
  required List<BottleTransaction> transactions,
  required List<CustomerOwnedBottleLog> logs,
}) {
  final loggedTxIds = logs
      .map((l) => l.bottleTransactionId)
      .whereType<String>()
      .toSet();
  final loggedDeliveryIds =
      logs.map((l) => l.deliveryId).whereType<String>().toSet();

  final events =
      <({DateTime date, CustomerBottleOwnershipLedgerEntry entry, bool fromLog})>[];

  for (final log in logs) {
    events.add((date: log.date, entry: _entryFromLog(log), fromLog: true));
  }

  for (final tx in transactions) {
    if (tx.transactionType == TransactionType.borrow &&
        tx.isDeliveryLinked &&
        loggedDeliveryIds.contains(tx.id.replaceAll('_borrow', ''))) {
      continue;
    }
    if (loggedTxIds.contains(tx.id)) continue;
    if (tx.transactionType != TransactionType.borrow &&
        tx.transactionType != TransactionType.ret &&
        tx.transactionType != TransactionType.customerAdjustment) {
      continue;
    }
    events.add((
      date: tx.date,
      entry: _entryFromTransaction(tx),
      fromLog: false,
    ));
  }

  events.sort((a, b) => a.date.compareTo(b.date));

  var businessBalance = 0;
  var customerOwnedBalance = 0;
  final chronological = <CustomerBottleOwnershipLedgerEntry>[];

  for (final event in events) {
    final raw = event.entry;
    if (event.fromLog) {
      businessBalance = raw.businessOwnedAfter;
      customerOwnedBalance = raw.customerOwnedAfter;
    } else {
      final businessDelta = raw.businessOwnedDelta ?? 0;
      final customerDelta = raw.customerOwnedDelta ?? 0;
      businessBalance = (businessBalance + businessDelta).clamp(0, 999999);
      customerOwnedBalance =
          (customerOwnedBalance + customerDelta).clamp(0, 999999);
    }

    chronological.add(
      CustomerBottleOwnershipLedgerEntry(
        date: raw.date,
        headline: raw.headline,
        businessOwnedDelta: raw.businessOwnedDelta,
        customerOwnedDelta: raw.customerOwnedDelta,
        businessOwnedAfter: businessBalance,
        customerOwnedAfter: customerOwnedBalance,
        notes: raw.notes,
        sourceId: raw.sourceId,
      ),
    );
  }

  return chronological.reversed.toList();
}

CustomerBottleOwnershipLedgerEntry _entryFromLog(CustomerOwnedBottleLog log) {
  return CustomerBottleOwnershipLedgerEntry(
    date: log.date,
    headline: log.eventType.label,
    businessOwnedDelta:
        log.businessOwnedDelta != 0 ? log.businessOwnedDelta : null,
    customerOwnedDelta:
        log.customerOwnedDelta != 0 ? log.customerOwnedDelta : null,
    businessOwnedAfter: log.businessOwnedAfter,
    customerOwnedAfter: log.customerOwnedAfter,
    notes: log.notes,
    sourceId: log.id,
  );
}

CustomerBottleOwnershipLedgerEntry _entryFromTransaction(
  BottleTransaction tx,
) {
  final qty = tx.quantity;
  final delta = switch (tx.transactionType) {
    TransactionType.borrow => qty,
    TransactionType.ret => -qty,
    TransactionType.customerAdjustment => qty,
    _ => 0,
  };

  final headline = switch (tx.transactionType) {
    TransactionType.borrow => 'Delivered Bottles',
    TransactionType.ret => 'Collected Bottles',
    TransactionType.customerAdjustment =>
      tx.reason == AppConstants.initialBalanceMigrationReason
          ? 'Set Business-Owned Balance'
          : 'Adjust Business-Owned Balance',
    _ => BottleTransaction.ledgerLabel(tx.transactionType),
  };

  return CustomerBottleOwnershipLedgerEntry(
    date: tx.date,
    headline: headline,
    businessOwnedDelta: delta != 0 ? delta : null,
    customerOwnedDelta: null,
    businessOwnedAfter: 0,
    customerOwnedAfter: 0,
    notes: tx.notes ?? tx.reason,
    sourceId: tx.id,
  );
}

String ownershipLedgerSubtitle(CustomerBottleOwnershipLedgerEntry entry) {
  final parts = <String>[];
  if (entry.hasBusinessDelta) {
    final sign = entry.businessOwnedDelta! >= 0 ? '+' : '';
    parts.add('Business-Owned: $sign${entry.businessOwnedDelta}');
  }
  if (entry.hasCustomerOwnedDelta) {
    final sign = entry.customerOwnedDelta! >= 0 ? '+' : '';
    parts.add('Customer-Owned: $sign${entry.customerOwnedDelta}');
  }
  return parts.join(' • ');
}

String ownershipBalanceAfterLabel(CustomerBottleOwnershipLedgerEntry entry) {
  return 'Business-Owned: ${entry.businessOwnedAfter} • '
      'Customer-Owned: ${entry.customerOwnedAfter}';
}
