class DispenserSale {
  final String id;
  final double amount;
  final DateTime date;
  final String? notes;

  const DispenserSale({
    required this.id,
    required this.amount,
    required this.date,
    this.notes,
  });
}
