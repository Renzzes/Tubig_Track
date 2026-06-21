import '../../../../core/constants/app_constants.dart';
import '../../features/inventory/domain/entities/bottle_transaction.dart';

class CustomerBottleLedgerEntry {
  final BottleTransaction transaction;
  final int balanceAfter;
  final int quantityDelta;

  const CustomerBottleLedgerEntry({
    required this.transaction,
    required this.balanceAfter,
    required this.quantityDelta,
  });

  String get actionLabel =>
      BottleTransaction.ledgerLabel(transaction.transactionType);

  bool get isIncrease => quantityDelta > 0;
}

/// Builds a running bottle balance ledger for one customer (newest first).
List<CustomerBottleLedgerEntry> buildCustomerBottleLedger(
  List<BottleTransaction> transactions,
) {
  final relevant = transactions
      .where(
        (t) =>
            t.transactionType == TransactionType.borrow ||
            t.transactionType == TransactionType.ret ||
            t.transactionType == TransactionType.customerAdjustment,
      )
      .toList()
    ..sort((a, b) => a.date.compareTo(b.date));

  var balance = 0;
  final chronological = <CustomerBottleLedgerEntry>[];

  for (final tx in relevant) {
    final delta = switch (tx.transactionType) {
      TransactionType.borrow => tx.quantity,
      TransactionType.ret => -tx.quantity,
      TransactionType.customerAdjustment => tx.quantity,
      _ => 0,
    };
    balance = (balance + delta).clamp(0, 999999);
    chronological.add(
      CustomerBottleLedgerEntry(
        transaction: tx,
        balanceAfter: balance,
        quantityDelta: delta,
      ),
    );
  }

  return chronological.reversed.toList();
}

int computeCustomerBottlesHeld(List<BottleTransaction> transactions) {
  var delivered = 0;
  var collected = 0;
  var adjustments = 0;
  for (final tx in transactions) {
    switch (tx.transactionType) {
      case TransactionType.borrow:
        delivered += tx.quantity;
      case TransactionType.ret:
        collected += tx.quantity;
      case TransactionType.customerAdjustment:
        adjustments += tx.quantity;
      default:
        break;
    }
  }
  return (delivered - collected + adjustments).clamp(0, 999999);
}

String ledgerHeadline(CustomerBottleLedgerEntry entry) {
  final qty = entry.transaction.quantity.abs();
  final reason = entry.transaction.reason;
  return switch (entry.transaction.transactionType) {
    TransactionType.borrow => 'Delivered $qty Bottles',
    TransactionType.ret => 'Collected $qty Bottles',
    TransactionType.customerAdjustment =>
      reason == AppConstants.initialBalanceMigrationReason
          ? 'Initial Balance +$qty'
          : entry.quantityDelta >= 0
              ? 'Customer Bottle Adjustment +$qty'
              : 'Customer Bottle Adjustment -$qty',
    _ => entry.actionLabel,
  };
}
