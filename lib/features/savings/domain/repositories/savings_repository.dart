import '../entities/savings_entities.dart';

abstract class SavingsRepository {
  Future<SavingsSummary> getSummary();
  Future<List<SavingsLedgerEntry>> getLedgerHistory();
  Future<List<SavingsTransfer>> getTransferHistory();
  Future<void> addContribution(SavingsContribution contribution);
  Future<void> recordTransfer(SavingsTransfer transfer);
  Future<double> getCostPerBottle();
  Future<void> setCostPerBottle(double cost);
}

class SavingsTransferException implements Exception {
  final String message;
  const SavingsTransferException(this.message);

  @override
  String toString() => message;
}
