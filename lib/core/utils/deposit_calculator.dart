/// Pure deposit/payment math for delivery forms and reconciliation.
class DepositCalculator {
  DepositCalculator._();

  static double depositToApply({
    required double availableDeposit,
    required double totalAmount,
    required bool applyDeposit,
  }) {
    if (!applyDeposit || availableDeposit <= 0) return 0;
    return availableDeposit < totalAmount ? availableDeposit : totalAmount;
  }

  static double amountDue({
    required double totalAmount,
    required double depositApplied,
  }) =>
      (totalAmount - depositApplied).clamp(0.0, double.infinity);

  static double excessPayment({
    required double cashPaid,
    required double amountDue,
  }) {
    final excess = cashPaid - amountDue;
    return excess > 0.001 ? excess : 0;
  }

  static double cashAppliedToDelivery({
    required double cashPaid,
    required double amountDue,
  }) =>
      cashPaid < amountDue ? cashPaid : amountDue;

  static double remainingBalance({
    required double totalAmount,
    required double depositApplied,
    required double cashPaid,
  }) =>
      (totalAmount - depositApplied - cashPaid).clamp(0.0, double.infinity);

  static double remainingDepositAfterUse({
    required double availableDeposit,
    required double depositApplied,
  }) =>
      (availableDeposit - depositApplied).clamp(0.0, double.infinity);
}
