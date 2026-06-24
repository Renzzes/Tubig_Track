enum CustomerSortOption {
  nameAsc,
  nameDesc,
  mostBottlesHeld,
  highestOutstanding,
  mostCustomerOwned,
  recentlyActive;

  String get label => switch (this) {
        CustomerSortOption.nameAsc => 'Name A-Z',
        CustomerSortOption.nameDesc => 'Name Z-A',
        CustomerSortOption.mostBottlesHeld => 'Most Bottles Held',
        CustomerSortOption.highestOutstanding => 'Highest Outstanding Balance',
        CustomerSortOption.mostCustomerOwned => 'Most Customer-Owned Bottles',
        CustomerSortOption.recentlyActive => 'Recently Active',
      };

  static CustomerSortOption fromStorage(String? value) {
    if (value == null) return CustomerSortOption.nameAsc;
    for (final option in CustomerSortOption.values) {
      if (option.name == value) return option;
    }
    return CustomerSortOption.nameAsc;
  }
}
