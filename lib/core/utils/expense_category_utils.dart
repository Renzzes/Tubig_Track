/// Maps expense categories to report groupings.
/// Supports legacy category names stored in existing records.
class ExpenseCategoryUtils {
  ExpenseCategoryUtils._();

  static const supplies = 'Supplies';
  static const otherSupplies = 'Other Supplies';
  static const operations = 'Operations';
  static const maintenance = 'Maintenance';
  static const utilities = 'Utilities';
  static const miscellaneous = 'Miscellaneous';

  static const reportGroups = [
    supplies,
    otherSupplies,
    operations,
    maintenance,
    utilities,
    miscellaneous,
  ];

  static String reportGroupFor(String category) {
    switch (category) {
      case supplies:
        return supplies;
      case otherSupplies:
        return otherSupplies;
      case operations:
      case 'Fuel':
      case 'Salary':
        return operations;
      case maintenance:
        return maintenance;
      case utilities:
      case 'Electricity':
      case 'Water':
        return utilities;
      case miscellaneous:
      case 'Others':
        return miscellaneous;
      default:
        return miscellaneous;
    }
  }

  static double sumForGroup(
    Iterable<({String category, double amount})> expenses,
    String group,
  ) {
    return expenses
        .where((e) => reportGroupFor(e.category) == group)
        .fold(0.0, (sum, e) => sum + e.amount);
  }
}
