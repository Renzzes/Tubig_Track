import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

enum DuplicateCustomerDialogAction {
  viewExisting,
  proceedAnyway,
  cancel,
}

String _displayValue(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return '—';
  return trimmed;
}

class _DuplicateCompareSection extends StatelessWidget {
  final String title;
  final String? phone;
  final String? address;
  final String? name;

  const _DuplicateCompareSection({
    required this.title,
    this.phone,
    this.address,
    this.name,
  });

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: labelStyle),
        const SizedBox(height: 8),
        if (name != null) ...[
          _CompareRow(label: 'Name', value: _displayValue(name)),
          const SizedBox(height: 4),
        ],
        _CompareRow(label: 'Phone', value: _displayValue(phone)),
        const SizedBox(height: 4),
        _CompareRow(label: 'Address', value: _displayValue(address)),
      ],
    );
  }
}

class _CompareRow extends StatelessWidget {
  final String label;
  final String value;

  const _CompareRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 64,
          child: Text(
            '$label:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

Future<DuplicateCustomerDialogAction?> showDuplicateCustomerNameDialog(
  BuildContext context, {
  required String existingName,
  required String? existingPhone,
  required String? existingAddress,
  required String? newPhone,
  required String? newAddress,
  required bool isEditing,
}) {
  return showDialog<DuplicateCustomerDialogAction>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Customer Already Exists'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Name:',
              style: Theme.of(ctx).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              existingName,
              style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'A customer with this name already exists.',
              style: Theme.of(ctx).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Creating another customer will create a separate customer '
              'profile with its own balances, bottle records, and delivery '
              'history.',
              style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 16),
            _DuplicateCompareSection(
              title: 'Existing',
              phone: existingPhone,
              address: existingAddress,
            ),
            const SizedBox(height: 16),
            _DuplicateCompareSection(
              title: 'New',
              phone: newPhone,
              address: newAddress,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.pop(ctx, DuplicateCustomerDialogAction.viewExisting),
          child: const Text('View Existing'),
        ),
        TextButton(
          onPressed: () =>
              Navigator.pop(ctx, DuplicateCustomerDialogAction.proceedAnyway),
          child: Text(isEditing ? 'Save Duplicate' : 'Create New Customer'),
        ),
        TextButton(
          onPressed: () =>
              Navigator.pop(ctx, DuplicateCustomerDialogAction.cancel),
          child: const Text('Cancel'),
        ),
      ],
    ),
  );
}

Future<DuplicateCustomerDialogAction?> showDuplicateCustomerPhoneDialog(
  BuildContext context, {
  required String existingName,
  required String? existingPhone,
  required String? existingAddress,
  required String newName,
  required String newPhone,
  required String? newAddress,
  required bool isEditing,
}) {
  return showDialog<DuplicateCustomerDialogAction>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Phone Number Already Exists'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'This phone number already belongs to another customer.',
              style: Theme.of(ctx).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              isEditing
                  ? 'Saving will keep this phone on a separate customer '
                      'profile with its own balances, bottle records, and '
                      'delivery history.'
                  : 'Creating another customer will create a separate '
                      'customer profile with its own balances, bottle '
                      'records, and delivery history.',
              style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 16),
            _DuplicateCompareSection(
              title: 'Existing',
              name: existingName,
              phone: existingPhone,
              address: existingAddress,
            ),
            const SizedBox(height: 16),
            _DuplicateCompareSection(
              title: 'New',
              name: newName,
              phone: newPhone,
              address: newAddress,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.pop(ctx, DuplicateCustomerDialogAction.viewExisting),
          child: const Text('View Existing'),
        ),
        TextButton(
          onPressed: () =>
              Navigator.pop(ctx, DuplicateCustomerDialogAction.proceedAnyway),
          child: Text(isEditing ? 'Save Duplicate' : 'Create New Customer'),
        ),
        TextButton(
          onPressed: () =>
              Navigator.pop(ctx, DuplicateCustomerDialogAction.cancel),
          child: const Text('Cancel'),
        ),
      ],
    ),
  );
}
