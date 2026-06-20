class SavingsGoal {
  final String id;
  final String name;
  final double targetAmount;
  final DateTime? targetDate;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;

  const SavingsGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.targetDate,
    this.notes,
    this.isActive = true,
    required this.createdAt,
  });

  double progressPercent(double currentSavings) {
    if (targetAmount <= 0) return 0;
    return (currentSavings / targetAmount * 100).clamp(0, 100);
  }
}

enum SavingsTrend { increasing, stable, decreasing }

class SavingsInsights {
  final double averageMonthlySavings;
  final double highestMonthlySavings;
  final double lowestMonthlySavings;
  final SavingsTrend trend;

  const SavingsInsights({
    required this.averageMonthlySavings,
    required this.highestMonthlySavings,
    required this.lowestMonthlySavings,
    required this.trend,
  });
}
