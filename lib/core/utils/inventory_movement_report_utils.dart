const supplierDeliveriesFilledLabel = 'Supplier Deliveries';
const manualAdjustmentFilledLabel = 'Manual Adjustment';

/// Positive filled-bottle additions from manual tools (add / adjust up).
int manualFilledBottlesAddedFromTransactions(
  Iterable<({String transactionType, int quantity})> transactions,
) {
  var manual = 0;
  for (final t in transactions) {
    switch (t.transactionType) {
      case 'added':
      case 'adjustment':
        if (t.quantity > 0) manual += t.quantity;
    }
  }
  return manual;
}

Map<String, int> buildFilledBottlesAddedBySource({
  required int supplierDeliveriesQuantity,
  required int manualAdjustmentQuantity,
}) {
  final bySource = <String, int>{};
  if (supplierDeliveriesQuantity > 0) {
    bySource[supplierDeliveriesFilledLabel] = supplierDeliveriesQuantity;
  }
  if (manualAdjustmentQuantity > 0) {
    bySource[manualAdjustmentFilledLabel] = manualAdjustmentQuantity;
  }
  return bySource;
}

int totalFilledBottlesAdded(Map<String, int> bySource) =>
    bySource.values.fold(0, (sum, count) => sum + count);

List<MapEntry<String, int>> orderedFilledBottlesAddedBreakdown(
  Map<String, int> breakdown,
) {
  const order = [
    supplierDeliveriesFilledLabel,
    manualAdjustmentFilledLabel,
  ];
  final shown = <String>{};
  final result = <MapEntry<String, int>>[];

  for (final label in order) {
    final count = breakdown[label] ?? 0;
    if (count <= 0) continue;
    shown.add(label);
    result.add(MapEntry(label, count));
  }

  for (final entry in breakdown.entries) {
    if (entry.value > 0 && !shown.contains(entry.key)) {
      result.add(MapEntry(entry.key, entry.value));
    }
  }

  return result;
}

/// Filled added minus empty received in the same period.
int netFilledBottlesAdded({
  required int totalFilledAdded,
  required int totalEmptyReceived,
}) =>
    totalFilledAdded - totalEmptyReceived;

String formatNetFilledBottlesAdded(int net) {
  if (net > 0) return '+$net Bottles';
  if (net < 0) return '$net Bottles';
  return '0 Bottles';
}
