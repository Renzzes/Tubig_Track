import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/inventory_validation.dart';

Future<void> showInventoryValidationDialog(
  BuildContext context,
  InventoryValidationException error,
) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Inventory Validation Failed'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Bottles Owned: ${error.totalBottlesOwned}'),
          Text('Calculated Inventory: ${error.calculatedInventory}'),
          const SizedBox(height: 12),
          Text(error.message),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

/// Shows validation errors from repository calls in inventory sheets.
Future<void> handleInventorySaveError(
  BuildContext context,
  Object error,
) async {
  if (error is InventoryValidationException) {
    await showInventoryValidationDialog(context, error);
    return;
  }
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $error'),
        backgroundColor: AppColors.error,
      ),
    );
  }
}
