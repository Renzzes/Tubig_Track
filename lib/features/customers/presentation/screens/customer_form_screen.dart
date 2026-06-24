import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../providers/customers_provider.dart';
import '../widgets/customer_bottle_reconcile_dialog.dart';
import '../../domain/entities/customer.dart';

class CustomerFormScreen extends ConsumerStatefulWidget {
  final String? customerId;

  const CustomerFormScreen({super.key, this.customerId});

  @override
  ConsumerState<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends ConsumerState<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _isLoading = false;
  bool _initialized = false;

  bool get isEditing => widget.customerId != null;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _initFromCustomer(Customer customer) {
    if (_initialized) return;
    _nameCtrl.text = customer.name;
    _phoneCtrl.text = customer.phone ?? '';
    _addressCtrl.text = customer.address ?? '';
    _notesCtrl.text = customer.notes ?? '';
    _initialized = true;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final repo = ref.read(customerRepositoryProvider);

      if (isEditing) {
        final existing =
            await repo.getById(widget.customerId!);
        if (existing == null) return;
        await repo.updateCustomer(
          existing.copyWith(
            name: _nameCtrl.text.trim(),
            phone: _phoneCtrl.text.trim().isEmpty
                ? null
                : _phoneCtrl.text.trim(),
            address: _addressCtrl.text.trim().isEmpty
                ? null
                : _addressCtrl.text.trim(),
            notes: _notesCtrl.text.trim().isEmpty
                ? null
                : _notesCtrl.text.trim(),
          ),
        );
      } else {
        await repo.addCustomer(
          Customer(
            id: const Uuid().v4(),
            name: _nameCtrl.text.trim(),
            phone: _phoneCtrl.text.trim().isEmpty
                ? null
                : _phoneCtrl.text.trim(),
            address: _addressCtrl.text.trim().isEmpty
                ? null
                : _addressCtrl.text.trim(),
            notes: _notesCtrl.text.trim().isEmpty
                ? null
                : _notesCtrl.text.trim(),
            createdAt: DateTime.now(),
          ),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(isEditing ? 'Customer updated!' : 'Customer added!'),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isEditing) {
      final customerAsync = ref.watch(customerByIdProvider(widget.customerId!));
      customerAsync.whenData((c) {
        if (c != null) _initFromCustomer(c);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Customer' : 'Add Customer'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppTextField(
              label: 'Name *',
              controller: _nameCtrl,
              autofocus: true,
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Phone Number',
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              prefixIcon: const Icon(Icons.phone_outlined),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Address',
              controller: _addressCtrl,
              maxLines: 2,
              textInputAction: TextInputAction.next,
              prefixIcon: const Icon(Icons.location_on_outlined),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Notes',
              controller: _notesCtrl,
              maxLines: 3,
              hint: 'Optional notes...',
            ),
            if (isEditing) ...[
              const SizedBox(height: 24),
              _BottleOwnershipManagementSection(
                customerId: widget.customerId!,
              ),
            ],
            const SizedBox(height: 32),
            ResponsivePrimaryButton(
              onPressed: _isLoading ? null : _save,
              isLoading: _isLoading,
              child: Text(isEditing ? 'Update Customer' : 'Add Customer'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottleOwnershipManagementSection extends ConsumerWidget {
  final String customerId;

  const _BottleOwnershipManagementSection({required this.customerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(customerStatsProvider(customerId));

    return statsAsync.when(
      data: (stats) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bottle Ownership Management',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Set or adjust business-owned and customer-owned bottle balances.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              Text(
                'Business-Owned',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.push(
                        '/customers/$customerId/initial-balance',
                      ),
                      icon: Icon(
                        stats.hasInitialBalance
                            ? Icons.edit_outlined
                            : Icons.playlist_add,
                      ),
                      label: Text(
                        stats.hasInitialBalance
                            ? 'Edit Business-Owned'
                            : 'Set Business-Owned',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.push(
                        '/customers/$customerId/adjust-bottles',
                      ),
                      icon: const Icon(Icons.tune_outlined),
                      label: const Text('Adjust Business-Owned'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Customer-Owned',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.push(
                        '/customers/$customerId/set-customer-owned-balance',
                      ),
                      icon: const Icon(Icons.playlist_add),
                      label: const Text('Set Customer-Owned'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.push(
                        '/customers/$customerId/adjust-customer-owned-bottles',
                      ),
                      icon: const Icon(Icons.tune_outlined),
                      label: const Text('Adjust Customer-Owned'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => CustomerBottleReconcileDialog.show(
                    context,
                    ref,
                    customerId: customerId,
                    expectedBottles: stats.bottlesHeld,
                  ),
                  icon: const Icon(Icons.balance_outlined),
                  label: const Text('Reconcile Bottles'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Currently held: ${stats.bottlesHeld} business-owned, '
                  '${stats.customerOwnedBottlesHeld} customer-owned',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (e, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Unable to load bottle balances: $e'),
        ),
      ),
    );
  }
}
