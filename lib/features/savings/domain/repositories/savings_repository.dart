import '../entities/savings_entities.dart';

abstract class SavingsRepository {
  Future<SavingsSummary> getSummary();
  Future<List<SavingsLedgerEntry>> getLedgerHistory();
  Future<void> addContribution(SavingsContribution contribution);
  Future<double> getCostPerBottle();
  Future<void> setCostPerBottle(double cost);
}
