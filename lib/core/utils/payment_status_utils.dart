/// Shared payment status calculation used across the app.
class PaymentStatusUtils {
  PaymentStatusUtils._();

  static String computeStatus({
    required double totalAmount,
    required double amountPaid,
    double depositApplied = 0,
  }) {
    final remaining = computeRemainingBalance(
      totalAmount: totalAmount,
      amountPaid: amountPaid,
      depositApplied: depositApplied,
    );
    if (remaining <= 0) return 'paid';
    if (amountPaid <= 0 && depositApplied <= 0) return 'unpaid';
    return 'partial';
  }

  static double computeRemainingBalance({
    required double totalAmount,
    required double amountPaid,
    double depositApplied = 0,
  }) {
    return (totalAmount - amountPaid - depositApplied)
        .clamp(0.0, double.infinity);
  }
}
