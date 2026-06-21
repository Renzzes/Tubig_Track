import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/recent_transaction.dart';
import '../utils/transaction_activity_handler.dart';

class RecentTransactionsWidget extends StatelessWidget {
  final List<RecentTransaction> transactions;
  final int limit;
  final bool grouped;

  const RecentTransactionsWidget({
    super.key,
    required this.transactions,
    this.limit = 10,
    this.grouped = true,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'No transactions yet',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ),
      );
    }

    if (!grouped) {
      return Column(
        children: transactions
            .take(limit)
            .map((tx) => _TransactionTile(tx: tx))
            .toList(),
      );
    }

    final financial = transactions.where((tx) => !tx.isInventoryEvent).toList();
    final inventory = transactions.where((tx) => tx.isInventoryEvent).toList();

    final financialLimit = (limit * 0.6).ceil().clamp(1, limit);
    final inventoryLimit = limit - financialLimit;

    final financialItems = financial.take(financialLimit).toList();
    final inventoryItems = inventory.take(inventoryLimit).toList();

    if (financialItems.isEmpty && inventoryItems.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'No transactions yet',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (financialItems.isNotEmpty) ...[
          _SectionLabel(
            title: 'Financial Transactions',
            subtitle: 'Savings, expenses, payments, deposits',
          ),
          ...financialItems.map((tx) => _TransactionTile(tx: tx)),
        ],
        if (financialItems.isNotEmpty && inventoryItems.isNotEmpty)
          const SizedBox(height: 12),
        if (inventoryItems.isNotEmpty) ...[
          _SectionLabel(
            title: 'Inventory Events',
            subtitle: 'Ownership changes only — no cash impact',
          ),
          ...inventoryItems.map((tx) => _TransactionTile(tx: tx)),
        ],
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionLabel({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final RecentTransaction tx;

  const _TransactionTile({required this.tx});

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('hh:mm a').format(tx.date);
    final isInventory = tx.isInventoryEvent;

    final amountPrefix = tx.isCredit ? '+' : '-';
    final amountColor = tx.isCredit ? Colors.green[700] : Colors.red[700];
    final trailingText = isInventory
        ? tx.quantityLabel
        : '$amountPrefix${CurrencyFormatter.format(tx.amount)}';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => TransactionActivityHandler.onTap(context, tx),
        onLongPress: () => TransactionActivityHandler.onLongPress(context, tx),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 64,
                child: Text(
                  time,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.typeLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      tx.title,
                      style: const TextStyle(fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (tx.subtitle != null)
                      Text(
                        tx.subtitle!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    Text(
                      DateFormatter.format(tx.date),
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Text(
                trailingText,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: amountColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
