import '../../features/customers/domain/entities/customer.dart';

enum CustomerStatus {
  newCustomer,
  active,
  unpaid,
  depositAvailable,
  inactive,
}

class CustomerStatusInfo {
  final CustomerStatus status;
  final String label;
  final int colorValue;

  const CustomerStatusInfo({
    required this.status,
    required this.label,
    required this.colorValue,
  });
}

/// Resolves customer status with priority: Unpaid → Deposit Available → Active → Inactive → New.
class CustomerStatusUtils {
  CustomerStatusUtils._();

  static const int _colorUnpaid = 0xFFE53935;
  static const int _colorDeposit = 0xFF1976D2;
  static const int _colorActive = 0xFF43A047;
  static const int _colorInactive = 0xFF757575;
  static const int _colorNew = 0xFF9E9E9E;

  static CustomerStatus resolve(CustomerStats stats) {
    if (stats.unpaidBalance > 0) return CustomerStatus.unpaid;
    if (stats.depositBalance > 0) return CustomerStatus.depositAvailable;

    final hasActivity = stats.totalDeliveries > 0 ||
        stats.bottlesHeld > 0 ||
        stats.hasInitialBalance;

    if (hasActivity) {
      if (stats.lastActivityDate != null &&
          DateTime.now().difference(stats.lastActivityDate!).inDays >= 60) {
        return CustomerStatus.inactive;
      }
      return CustomerStatus.active;
    }

    return CustomerStatus.newCustomer;
  }

  static CustomerStatusInfo infoFor(CustomerStats stats) {
    final status = resolve(stats);
    return CustomerStatusInfo(
      status: status,
      label: labelFor(status),
      colorValue: colorFor(status),
    );
  }

  static String labelFor(CustomerStatus status) => switch (status) {
        CustomerStatus.unpaid => 'Unpaid',
        CustomerStatus.depositAvailable => 'Deposit Available',
        CustomerStatus.active => 'Active',
        CustomerStatus.inactive => 'Inactive',
        CustomerStatus.newCustomer => 'New',
      };

  static int colorFor(CustomerStatus status) => switch (status) {
        CustomerStatus.unpaid => _colorUnpaid,
        CustomerStatus.depositAvailable => _colorDeposit,
        CustomerStatus.active => _colorActive,
        CustomerStatus.inactive => _colorInactive,
        CustomerStatus.newCustomer => _colorNew,
      };
}
