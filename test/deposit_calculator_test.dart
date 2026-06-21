import 'package:flutter_test/flutter_test.dart';
import 'package:tubig_track/core/utils/deposit_calculator.dart';
import 'package:tubig_track/core/utils/payment_status_utils.dart';

void main() {
  group('DepositCalculator', () {
    test('applies full deposit when delivery exceeds balance', () {
      expect(
        DepositCalculator.depositToApply(
          availableDeposit: 25,
          totalAmount: 175,
          applyDeposit: true,
        ),
        25,
      );
      expect(
        DepositCalculator.amountDue(totalAmount: 175, depositApplied: 25),
        150,
      );
    });

    test('uses entire deposit when deposit exceeds delivery total', () {
      expect(
        DepositCalculator.depositToApply(
          availableDeposit: 200,
          totalAmount: 175,
          applyDeposit: true,
        ),
        175,
      );
      expect(
        DepositCalculator.amountDue(totalAmount: 175, depositApplied: 175),
        0,
      );
    });

    test('creates excess deposit from overpayment', () {
      expect(
        DepositCalculator.excessPayment(cashPaid: 200, amountDue: 175),
        25,
      );
    });

    test('partial deposit leaves remaining balance', () {
      expect(
        DepositCalculator.remainingBalance(
          totalAmount: 175,
          depositApplied: 100,
          cashPaid: 0,
        ),
        75,
      );
    });
  });

  group('PaymentStatusUtils with deposits', () {
    test('marks delivery paid when deposit and cash cover total', () {
      expect(
        PaymentStatusUtils.computeStatus(
          totalAmount: 175,
          amountPaid: 150,
          depositApplied: 25,
        ),
        'paid',
      );
      expect(
        PaymentStatusUtils.computeRemainingBalance(
          totalAmount: 175,
          amountPaid: 100,
          depositApplied: 25,
        ),
        50,
      );
    });

    test('marks delivery paid when fully covered by deposit', () {
      expect(
        PaymentStatusUtils.computeStatus(
          totalAmount: 175,
          amountPaid: 0,
          depositApplied: 175,
        ),
        'paid',
      );
    });
  });
}
