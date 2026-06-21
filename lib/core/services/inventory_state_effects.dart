import '../../features/inventory/domain/entities/bottle_transaction.dart';
import 'inventory_state_service.dart';

/// Applies direct stock-counter changes for bottle transaction types.
class InventoryStateEffects {
  InventoryStateEffects(this._state);

  final InventoryStateService _state;

  Future<void> applyTransaction(
    TransactionType type,
    int quantity, {
    bool reverse = false,
  }) async {
    if (quantity == 0 && type != TransactionType.adjustment) return;
    final sign = reverse ? -1 : 1;

    switch (type) {
      case TransactionType.ret:
        await _state.adjustEmpty(quantity * sign);
      case TransactionType.borrow:
        await _state.adjustFilled(-quantity * sign);
      case TransactionType.damaged:
      case TransactionType.missing:
      case TransactionType.donation:
        await _state.adjustFilled(-quantity * sign);
      case TransactionType.adjustment:
        await _state.adjustFilled(quantity * sign);
      case TransactionType.added:
        await _state.adjustFilled(quantity * sign);
      case TransactionType.purchase:
      case TransactionType.customerAdjustment:
      case TransactionType.audit:
        break;
    }
  }
}
