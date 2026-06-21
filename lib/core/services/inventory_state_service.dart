import '../constants/app_constants.dart';
import '../database/app_database.dart';

/// Persists and adjusts the two directly-tracked bottle stock counters.
class InventoryStateService {
  final AppDatabase _db;

  InventoryStateService(this._db);

  Future<int> getFilledBottlesAvailable() async {
    final raw = await _db.settingsDao.getValue(
      AppConstants.settingFilledBottlesAvailable,
    );
    return int.tryParse(raw ?? '') ?? 0;
  }

  Future<int> getEmptyBottlesReadyForRefill() async {
    final raw = await _db.settingsDao.getValue(
      AppConstants.settingEmptyBottlesReadyForRefill,
    );
    return int.tryParse(raw ?? '') ?? 0;
  }

  Future<void> setFilledBottlesAvailable(int value) async {
    await _db.settingsDao.setValue(
      AppConstants.settingFilledBottlesAvailable,
      value.clamp(0, 999999).toString(),
    );
  }

  Future<void> setEmptyBottlesReadyForRefill(int value) async {
    await _db.settingsDao.setValue(
      AppConstants.settingEmptyBottlesReadyForRefill,
      value.clamp(0, 999999).toString(),
    );
  }

  Future<void> adjustFilled(int delta) async {
    if (delta == 0) return;
    final current = await getFilledBottlesAvailable();
    await setFilledBottlesAvailable(current + delta);
  }

  Future<void> adjustEmpty(int delta) async {
    if (delta == 0) return;
    final current = await getEmptyBottlesReadyForRefill();
    await setEmptyBottlesReadyForRefill(current + delta);
  }

  /// Supplier delivery of filled bottles: add to filled stock, consume empties.
  Future<void> applySupplierFilledDelivery(int quantity) async {
    if (quantity <= 0) return;
    final empty = await getEmptyBottlesReadyForRefill();
    final consumed = quantity.clamp(0, empty);
    await adjustFilled(quantity);
    if (consumed > 0) await adjustEmpty(-consumed);
  }

  /// Reverse a supplier filled-bottle delivery.
  Future<void> reverseSupplierFilledDelivery(int quantity) async {
    if (quantity <= 0) return;
    await adjustFilled(-quantity);
    await adjustEmpty(quantity);
  }
}
