import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/recent_transaction.dart';

class RecentTransactionsWidget extends StatelessWidget {
  final List<RecentTransaction> transactions;
  final int limit;

  const RecentTransactionsWidget({
    super.key,
    required this.transactions,
    this.limit = 10,
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

    final items = transactions.take(limit).toList();
    return Column(
      children: items.map((tx) {
        final time = DateFormat('hh:mm a').format(tx.date);
        final amountPrefix = tx.isCredit ? '+' : '-';
        final amountColor = tx.isCredit ? Colors.green[700] : Colors.red[700];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
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
                '$amountPrefix${CurrencyFormatter.format(tx.amount)}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: amountColor,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
