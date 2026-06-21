import 'package:flutter/material.dart';

enum BottleVarianceLevel { none, low, high }

/// Green = 0, Orange = 1–2, Red = 3+.
class BottleVarianceUtils {
  BottleVarianceUtils._();

  static BottleVarianceLevel levelFor(int variance) {
    final abs = variance.abs();
    if (abs == 0) return BottleVarianceLevel.none;
    if (abs <= 2) return BottleVarianceLevel.low;
    return BottleVarianceLevel.high;
  }

  static Color colorFor(int variance) {
    return switch (levelFor(variance)) {
      BottleVarianceLevel.none => Colors.green,
      BottleVarianceLevel.low => Colors.orange,
      BottleVarianceLevel.high => Colors.red,
    };
  }

  static String listLabel(int variance) {
    if (variance == 0) return '';
    if (variance < 0) return '⚠ Missing ${variance.abs()} Bottles';
    return '⚠ Excess ${variance.abs()} Bottles';
  }
}
