/// Shared payment status calculation used across the app.
class PaymentStatusUtils {
  PaymentStatusUtils._();

  static String computeStatus({
    required double totalAmount,
    required double amountPaid,
  }) {
    final remaining = (totalAmount - amountPaid).clamp(0.0, double.infinity);
    if (remaining <= 0) return 'paid';
    if (amountPaid <= 0) return 'unpaid';
    return 'partial';
  }

  static double computeRemainingBalance({
    required double totalAmount,
    required double amountPaid,
  }) {
    return (totalAmount - amountPaid).clamp(0.0, double.infinity);
  }
}
