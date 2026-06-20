import 'package:flutter/material.dart';

import '../../domain/entities/recent_transaction.dart';
import '../utils/transaction_activity_handler.dart';

class TransactionDetailScreen extends StatelessWidget {
  final RecentTransaction transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction Details')),
      body: TransactionDetailBody(transaction: transaction),
    );
  }
}
