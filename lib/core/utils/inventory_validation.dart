import '../../features/inventory/domain/entities/bottle_transaction.dart';
import '../../features/inventory/domain/entities/inventory_summary.dart';

/// Thrown when an inventory operation would break the bottle balance equation.
class InventoryValidationException implements Exception {
  final int totalBottlesOwned;
  final int calculatedInventory;

  const InventoryValidationException({
    required this.totalBottlesOwned,
    required this.calculatedInventory,
  });

  bool get exceedsOwned => calculatedInventory > totalBottlesOwned;

  String get message {
    if (exceedsOwned) {
      return 'Your inventory exceeds the number of bottles owned.\n'
          'Please review the adjustment.';
    }
    return 'Your inventory does not account for all owned bottles.\n'
        'Please review the adjustment.';
  }

  @override
  String toString() => 'InventoryValidationException($message)';
}

/// Validates projected bottle location totals against total owned.
class InventoryValidation {
  InventoryValidation._();

  static void validateProjectedBalance({
    required InventorySummary summary,
    required int filledDelta,
    required int emptyDelta,
    required int customerDelta,
    required int damagedDelta,
    required int missingDelta,
    required int totalOwnedDelta,
  }) {
    final projectedSum = (summary.filledBottlesAvailable + filledDelta) +
        (summary.emptyBottlesReadyForRefill + emptyDelta) +
        (summary.bottlesWithCustomers + customerDelta) +
        (summary.damagedBottles + damagedDelta) +
        (summary.missingBottles + missingDelta);
    final projectedTotal = summary.totalBottlesOwned + totalOwnedDelta;

    if (projectedSum > projectedTotal) {
      throw InventoryValidationException(
        totalBottlesOwned: projectedTotal,
        calculatedInventory: projectedSum,
      );
    }
  }

  static void validateTransaction({
    required InventorySummary summary,
    required TransactionType type,
    required int quantity,
  }) {
    switch (type) {
      case TransactionType.purchase:
        return;
      case TransactionType.added:
        validateProjectedBalance(
          summary: summary,
          filledDelta: quantity,
          emptyDelta: 0,
          customerDelta: 0,
          damagedDelta: 0,
          missingDelta: 0,
          totalOwnedDelta: 0,
        );
      case TransactionType.adjustment:
        validateProjectedBalance(
          summary: summary,
          filledDelta: quantity,
          emptyDelta: 0,
          customerDelta: 0,
          damagedDelta: 0,
          missingDelta: 0,
          totalOwnedDelta: 0,
        );
      case TransactionType.emptyAdded:
        validateProjectedBalance(
          summary: summary,
          filledDelta: 0,
          emptyDelta: quantity,
          customerDelta: 0,
          damagedDelta: 0,
          missingDelta: 0,
          totalOwnedDelta: 0,
        );
      case TransactionType.emptyAdjustment:
        validateProjectedBalance(
          summary: summary,
          filledDelta: 0,
          emptyDelta: quantity,
          customerDelta: 0,
          damagedDelta: 0,
          missingDelta: 0,
          totalOwnedDelta: 0,
        );
      case TransactionType.ret:
        validateProjectedBalance(
          summary: summary,
          filledDelta: 0,
          emptyDelta: quantity,
          customerDelta: -quantity,
          damagedDelta: 0,
          missingDelta: 0,
          totalOwnedDelta: 0,
        );
      case TransactionType.borrow:
        validateProjectedBalance(
          summary: summary,
          filledDelta: -quantity,
          emptyDelta: 0,
          customerDelta: quantity,
          damagedDelta: 0,
          missingDelta: 0,
          totalOwnedDelta: 0,
        );
      case TransactionType.damaged:
        validateProjectedBalance(
          summary: summary,
          filledDelta: -quantity,
          emptyDelta: 0,
          customerDelta: 0,
          damagedDelta: quantity,
          missingDelta: 0,
          totalOwnedDelta: -quantity,
        );
      case TransactionType.missing:
        validateProjectedBalance(
          summary: summary,
          filledDelta: -quantity,
          emptyDelta: 0,
          customerDelta: 0,
          damagedDelta: 0,
          missingDelta: quantity,
          totalOwnedDelta: -quantity,
        );
      case TransactionType.donation:
        validateProjectedBalance(
          summary: summary,
          filledDelta: -quantity,
          emptyDelta: 0,
          customerDelta: 0,
          damagedDelta: 0,
          missingDelta: 0,
          totalOwnedDelta: -quantity,
        );
      case TransactionType.customerAdjustment:
        validateProjectedBalance(
          summary: summary,
          filledDelta: 0,
          emptyDelta: 0,
          customerDelta: quantity,
          damagedDelta: 0,
          missingDelta: 0,
          totalOwnedDelta: 0,
        );
      case TransactionType.audit:
        return;
    }
  }
}
