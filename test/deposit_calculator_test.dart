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

    test('new deposit balance combines remaining pundo and excess cash', () {
      expect(
        DepositCalculator.newDepositBalance(
          remainingDepositAfterUse: 0,
          excessPayment: 150,
        ),
        150,
      );
      expect(
        DepositCalculator.newDepositBalance(
          remainingDepositAfterUse: 25,
          excessPayment: 0,
        ),
        25,
      );
    });
  });

  group('Deposit payment scenarios', () {
    void expectScenario({
      required String name,
      required double availableDeposit,
      required double deliveryTotal,
      required double cashReceived,
      required bool applyDeposit,
      required double expectedDepositApplied,
      required double expectedAmountDue,
      required double expectedExcess,
      required double expectedNewDeposit,
      required double expectedOutstanding,
    }) {
      test(name, () {
        final depositApplied = DepositCalculator.depositToApply(
          availableDeposit: availableDeposit,
          totalAmount: deliveryTotal,
          applyDeposit: applyDeposit,
        );
        final amountDue = DepositCalculator.amountDue(
          totalAmount: deliveryTotal,
          depositApplied: depositApplied,
        );
        final cashApplied = DepositCalculator.cashAppliedToDelivery(
          cashPaid: cashReceived,
          amountDue: amountDue,
        );
        final excess = DepositCalculator.excessPayment(
          cashPaid: cashReceived,
          amountDue: amountDue,
        );
        final remainingDeposit = DepositCalculator.remainingDepositAfterUse(
          availableDeposit: availableDeposit,
          depositApplied: depositApplied,
        );
        final newDeposit = DepositCalculator.newDepositBalance(
          remainingDepositAfterUse: remainingDeposit,
          excessPayment: excess,
        );
        final outstanding = DepositCalculator.remainingBalance(
          totalAmount: deliveryTotal,
          depositApplied: depositApplied,
          cashPaid: cashApplied,
        );

        expect(depositApplied, expectedDepositApplied);
        expect(amountDue, expectedAmountDue);
        expect(excess, expectedExcess);
        expect(newDeposit, expectedNewDeposit);
        expect(outstanding, expectedOutstanding);
      });
    }

    expectScenario(
      name: 'scenario 1: no deposit, exact cash',
      availableDeposit: 0,
      deliveryTotal: 175,
      cashReceived: 175,
      applyDeposit: false,
      expectedDepositApplied: 0,
      expectedAmountDue: 175,
      expectedExcess: 0,
      expectedNewDeposit: 0,
      expectedOutstanding: 0,
    );

    expectScenario(
      name: 'scenario 2: no deposit, overpayment',
      availableDeposit: 0,
      deliveryTotal: 175,
      cashReceived: 200,
      applyDeposit: false,
      expectedDepositApplied: 0,
      expectedAmountDue: 175,
      expectedExcess: 25,
      expectedNewDeposit: 25,
      expectedOutstanding: 0,
    );

    expectScenario(
      name: 'scenario 3: deposit covers part, exact cash for amount due',
      availableDeposit: 125,
      deliveryTotal: 175,
      cashReceived: 50,
      applyDeposit: true,
      expectedDepositApplied: 125,
      expectedAmountDue: 50,
      expectedExcess: 0,
      expectedNewDeposit: 0,
      expectedOutstanding: 0,
    );

    expectScenario(
      name: 'scenario 4: deposit covers part, no cash',
      availableDeposit: 125,
      deliveryTotal: 175,
      cashReceived: 0,
      applyDeposit: true,
      expectedDepositApplied: 125,
      expectedAmountDue: 50,
      expectedExcess: 0,
      expectedNewDeposit: 0,
      expectedOutstanding: 50,
    );

    expectScenario(
      name: 'scenario 5: deposit exceeds delivery, no cash',
      availableDeposit: 200,
      deliveryTotal: 175,
      cashReceived: 0,
      applyDeposit: true,
      expectedDepositApplied: 175,
      expectedAmountDue: 0,
      expectedExcess: 0,
      expectedNewDeposit: 25,
      expectedOutstanding: 0,
    );

    expectScenario(
      name: 'primary example: deposit + overpayment becomes new deposit',
      availableDeposit: 125,
      deliveryTotal: 175,
      cashReceived: 200,
      applyDeposit: true,
      expectedDepositApplied: 125,
      expectedAmountDue: 50,
      expectedExcess: 150,
      expectedNewDeposit: 150,
      expectedOutstanding: 0,
    );
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
