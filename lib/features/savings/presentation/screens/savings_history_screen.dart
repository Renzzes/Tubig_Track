import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../domain/entities/savings_entities.dart';
import '../providers/savings_provider.dart';

class SavingsHistoryScreen extends ConsumerWidget {
  const SavingsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ledgerAsync = ref.watch(savingsLedgerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Savings History')),
      body: ledgerAsync.when(
        data: (entries) {
          if (entries.isEmpty) {
            return const Center(child: Text('No savings records yet'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final entry = entries[index];
              return _LedgerTile(entry: entry);
            },
          );
        },
        loading: () => const LoadingOverlay(),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _LedgerTile extends StatelessWidget {
  final SavingsLedgerEntry entry;

  const _LedgerTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final prefix = entry.isCredit ? '+' : '-';
    final color = entry.isCredit ? Colors.green[700] : Colors.red[700];

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        entry.type.label,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(DateFormatter.formatDateTime(entry.date)),
          if (entry.notes != null && entry.notes!.isNotEmpty)
            Text(
              entry.notes!,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
        ],
      ),
      trailing: Text(
        '$prefix${CurrencyFormatter.format(entry.amount)}',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
