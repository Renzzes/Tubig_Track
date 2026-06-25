import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/recent_transaction.dart';
import '../screens/transaction_detail_screen.dart';

/// Opens the original record on tap; shows read-only details on long press.
class TransactionActivityHandler {
  TransactionActivityHandler._();

  static Future<void> onTap(BuildContext context, RecentTransaction tx) async {
    switch (tx.type) {
      case RecentTransactionType.delivery:
        context.push('/deliveries/${tx.sourceId}/edit');
      case RecentTransactionType.payment:
        if (tx.customerId != null) {
          context.push('/customers/${tx.customerId}');
        }
      case RecentTransactionType.expense:
        context.push('/expenses');
      case RecentTransactionType.dispenserSale:
        context.push('/dispenser-sales');
      case RecentTransactionType.walkInOperation:
        context.push('/walk-in-operations');
      case RecentTransactionType.savingsAddition:
        context.push('/savings');
      case RecentTransactionType.savingsTransfer:
      case RecentTransactionType.savingsWithdraw:
        context.push('/savings/account');
      case RecentTransactionType.supplyPurchase:
        context.push('/inventory/supply-purchases/${tx.sourceId}');
      case RecentTransactionType.bottleBorrow:
      case RecentTransactionType.bottleReturn:
      case RecentTransactionType.bottlePurchase:
      case RecentTransactionType.bottleDamaged:
      case RecentTransactionType.bottleMissing:
      case RecentTransactionType.bottleDonation:
      case RecentTransactionType.bottleAdjustment:
      case RecentTransactionType.bottleAudit:
        context.push('/inventory');
      case RecentTransactionType.depositAdded:
      case RecentTransactionType.depositUsed:
      case RecentTransactionType.depositAdjustment:
        if (tx.deliveryId != null) {
          context.push('/deliveries/${tx.deliveryId}/edit');
        } else if (tx.customerId != null) {
          context.push('/customers/${tx.customerId}/history/deposits');
        }
    }
  }

  static Future<void> onLongPress(
    BuildContext context,
    RecentTransaction tx,
  ) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionDetailScreen(transaction: tx),
      ),
    );
  }
}

/// Read-only transaction detail view.
class TransactionDetailBody extends StatelessWidget {
  final RecentTransaction transaction;

  const TransactionDetailBody({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final amountPrefix = transaction.isCredit ? '+' : '-';
    final amountColor =
        transaction.isCredit ? Colors.green[700] : Colors.red[700];
    final amountText = transaction.isInventoryEvent
        ? transaction.quantityLabel
        : '$amountPrefix${CurrencyFormatter.format(transaction.amount)}';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _DetailRow('Type', transaction.typeLabel),
        _DetailRow('Date', DateFormatter.formatDateTime(transaction.date)),
        _DetailRow(
          transaction.isInventoryEvent ? 'Quantity' : 'Amount',
          amountText,
          valueColor: amountColor,
        ),
        if (transaction.customerName != null)
          _DetailRow('Customer', transaction.customerName!),
        if (transaction.expenseCategory != null)
          _DetailRow('Category', transaction.expenseCategory!),
        if (transaction.deliveryId != null)
          _DetailRow('Related Delivery', transaction.deliveryId!),
        if (transaction.subtitle != null && transaction.subtitle!.isNotEmpty)
          _DetailRow('Notes', transaction.subtitle!),
        const SizedBox(height: 16),
        Text(
          'Tap the record type from Recent Transactions to open its source screen.',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
