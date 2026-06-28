/// Source of empty bottles entering warehouse inventory.
enum EmptyBottleSource {
  walkInCustomer,
  customerCollection,
  inventoryAudit,
  manualEntry,
  supplierExchange,
  other,
}

extension EmptyBottleSourceX on EmptyBottleSource {
  String get label => switch (this) {
        EmptyBottleSource.walkInCustomer => 'Walk-in Customer',
        EmptyBottleSource.customerCollection => 'Customer Collection',
        EmptyBottleSource.inventoryAudit => 'Inventory Audit',
        EmptyBottleSource.manualEntry => 'Manual Entry',
        EmptyBottleSource.supplierExchange => 'Supplier Exchange',
        EmptyBottleSource.other => 'Other',
      };

  static EmptyBottleSource? fromLabel(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    for (final source in EmptyBottleSource.values) {
      if (source.label == value.trim()) return source;
    }
    return EmptyBottleSource.other;
  }
}

const unspecifiedEmptyBottleSourceLabel = 'Unspecified';

/// Normalizes stored [reason] to a display label for intake reports.
String emptyBottleIntakeSourceLabel(String? reason) {
  final matched = EmptyBottleSourceX.fromLabel(reason);
  if (matched != null) return matched.label;
  if (reason != null && reason.trim().isNotEmpty) return reason.trim();
  return unspecifiedEmptyBottleSourceLabel;
}

void addEmptyBottleIntakeToBreakdown(
  Map<String, int> breakdown,
  String? reason,
  int quantity,
) {
  if (quantity <= 0) return;
  final label = emptyBottleIntakeSourceLabel(reason);
  breakdown[label] = (breakdown[label] ?? 0) + quantity;
}

/// Sources with counts, in enum order, then unspecified and any extras.
List<MapEntry<String, int>> orderedEmptyBottleIntakeBreakdown(
  Map<String, int> breakdown,
) {
  final shown = <String>{};
  final result = <MapEntry<String, int>>[];

  void addIfPresent(String label) {
    final count = breakdown[label] ?? 0;
    if (count <= 0 || shown.contains(label)) return;
    shown.add(label);
    result.add(MapEntry(label, count));
  }

  for (final source in EmptyBottleSource.values) {
    addIfPresent(source.label);
  }
  addIfPresent(unspecifiedEmptyBottleSourceLabel);

  for (final entry in breakdown.entries) {
    if (entry.value > 0 && !shown.contains(entry.key)) {
      result.add(MapEntry(entry.key, entry.value));
    }
  }

  return result;
}
