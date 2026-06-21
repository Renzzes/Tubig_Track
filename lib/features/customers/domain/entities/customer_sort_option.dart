enum CustomerSortOption {
  nameAsc,
  nameDesc,
  mostBottlesHeld,
  highestOutstanding,
  mostCustomerOwned,
  needsReconciliationFirst,
  recentlyActive;

  String get label => switch (this) {
        CustomerSortOption.nameAsc => 'Name A-Z',
        CustomerSortOption.nameDesc => 'Name Z-A',
        CustomerSortOption.mostBottlesHeld => 'Most Bottles Held',
        CustomerSortOption.highestOutstanding => 'Highest Outstanding Balance',
        CustomerSortOption.mostCustomerOwned => 'Most Customer-Owned Bottles',
        CustomerSortOption.needsReconciliationFirst =>
          'Needs Reconciliation First',
        CustomerSortOption.recentlyActive => 'Recently Active',
      };

  static CustomerSortOption fromStorage(String? value) {
    return CustomerSortOption.values.firstWhere(
      (o) => o.name == value,
      orElse: () => CustomerSortOption.nameAsc,
    );
  }
}
