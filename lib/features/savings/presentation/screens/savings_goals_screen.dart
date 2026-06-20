import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../domain/entities/savings_goal.dart';
import '../providers/savings_goals_provider.dart';
import '../providers/savings_provider.dart';

class SavingsGoalsScreen extends ConsumerWidget {
  const SavingsGoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(savingsGoalsStreamProvider);
    final savingsAsync = ref.watch(savingsSummaryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Savings Goals')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showGoalSheet(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Goal'),
      ),
      body: goalsAsync.when(
        data: (goals) {
          if (goals.isEmpty) {
            return const Center(child: Text('No savings goals yet'));
          }
          final current = savingsAsync.value?.currentSavings ?? 0;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: goals.length,
            itemBuilder: (_, i) {
              final g = goals[i];
              final progress = g.progressPercent(current);
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(g.name,
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                      ),
                      if (g.isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Active',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              )),
                        ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      LinearProgressIndicator(value: progress / 100),
                      const SizedBox(height: 6),
                      Text(
                        '${progress.toStringAsFixed(0)}% — ${CurrencyFormatter.format(current)} / ${CurrencyFormatter.format(g.targetAmount)}',
                      ),
                      if (g.targetDate != null)
                        Text(
                          'Target: ${DateFormatter.format(g.targetDate!)}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                    ],
                  ),
                  onTap: () => _showGoalSheet(context, ref, existing: g),
                  onLongPress: () async {
                    await ref
                        .read(savingsGoalsRepositoryProvider)
                        .setActiveGoal(g.id);
                    ref.invalidate(activeSavingsGoalProvider);
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Future<void> _showGoalSheet(
    BuildContext context,
    WidgetRef ref, {
    SavingsGoal? existing,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _GoalFormSheet(existing: existing),
    );
  }
}

class _GoalFormSheet extends ConsumerStatefulWidget {
  final SavingsGoal? existing;

  const _GoalFormSheet({this.existing});

  @override
  ConsumerState<_GoalFormSheet> createState() => _GoalFormSheetState();
}

class _GoalFormSheetState extends ConsumerState<_GoalFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _notesCtrl;
  DateTime? _targetDate;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _amountCtrl = TextEditingController(
      text: e != null ? '${e.targetAmount}' : '',
    );
    _notesCtrl = TextEditingController(text: e?.notes ?? '');
    _targetDate = e?.targetDate;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final repo = ref.read(savingsGoalsRepositoryProvider);
    final goal = SavingsGoal(
      id: widget.existing?.id ?? const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      targetAmount: double.parse(_amountCtrl.text.trim()),
      targetDate: _targetDate,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      isActive: widget.existing?.isActive ?? true,
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );
    if (widget.existing != null) {
      await repo.updateGoal(goal);
    } else {
      await repo.addGoal(goal, setActive: true);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.existing == null ? 'Add Savings Goal' : 'Edit Goal',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Goal Name *',
                  controller: _nameCtrl,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Target Amount *',
                  controller: _amountCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (double.tryParse(v) == null) return 'Invalid';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Target Date (optional)'),
                  subtitle: Text(
                    _targetDate != null
                        ? DateFormatter.format(_targetDate!)
                        : 'Not set',
                  ),
                  trailing: const Icon(Icons.calendar_today_outlined),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: _targetDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (d != null) setState(() => _targetDate = d);
                  },
                ),
                AppTextField(label: 'Notes', controller: _notesCtrl, maxLines: 2),
                const SizedBox(height: 20),
                ResponsivePrimaryButton(
                  onPressed: _save,
                  child: const Text('Save Goal'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
