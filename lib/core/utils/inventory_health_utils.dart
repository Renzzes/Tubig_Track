import 'inventory_calculator.dart';

enum InventoryHealth { healthy, warning, critical }

class InventoryHealthUtils {
  InventoryHealthUtils._();

  static InventoryHealth compute(InventoryConsistencyReport report) {
    var score = 0;

    if (!report.isCustomerBalanceConsistent) {
      final delta = report.customerBalanceDelta.abs();
      if (delta >= 3) {
        score += 2;
      } else if (delta >= 1) {
        score += 1;
      }
    }

    if (!report.isAuditBalanced) {
      final sum = report.filledBottlesAvailable +
          report.emptyBottlesReadyForRefill +
          report.globalWithCustomers +
          report.damagedBottles +
          report.missingBottles;
      final gap = (report.totalBottlesOwned - sum).abs();
      if (gap >= 3) {
        score += 2;
      } else if (gap >= 1) {
        score += 1;
      }
    }

    if (report.missingBottles >= 3) {
      score += 2;
    } else if (report.missingBottles >= 1) {
      score += 1;
    }

    if (score >= 2) return InventoryHealth.critical;
    if (score >= 1) return InventoryHealth.warning;
    return InventoryHealth.healthy;
  }

  static String label(InventoryHealth health) => switch (health) {
        InventoryHealth.healthy => 'Healthy',
        InventoryHealth.warning => 'Warning',
        InventoryHealth.critical => 'Critical',
      };

  static bool isInventoryOverflow(InventoryConsistencyReport report) {
    final sum = report.filledBottlesAvailable +
        report.emptyBottlesReadyForRefill +
        report.globalWithCustomers +
        report.damagedBottles +
        report.missingBottles;
    return sum > report.totalBottlesOwned;
  }
}
