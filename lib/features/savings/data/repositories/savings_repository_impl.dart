import 'package:drift/drift.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../walk_in_operations/domain/entities/walk_in_sale.dart';
import '../../domain/entities/savings_entities.dart';
import '../../domain/repositories/savings_repository.dart';

class SavingsRepositoryImpl implements SavingsRepository {
  final AppDatabase _db;

  SavingsRepositoryImpl(this._db);

  @override
  Future<double> getCostPerBottle() async {
    final val = await _db.settingsDao.getValue(AppConstants.settingCostPerBottle);
    return double.tryParse(val ?? '') ?? AppConstants.defaultCostPerBottle;
  }

  @override
  Future<void> setCostPerBottle(double cost) async {
    await _db.settingsDao.setValue(
      AppConstants.settingCostPerBottle,
      cost.toString(),
    );
  }

  int _walkInBottleCount(WalkInSalesTableData row) {
    return WalkInSale(
      id: row.id,
      customerId: row.customerId,
      walkInType: WalkInTypeX.fromStorage(row.walkInType),
      businessOwnedQuantity: row.businessOwnedQuantity,
      customerOwnedQuantity: row.customerOwnedQuantity,
      returnedEmptyQuantity: row.returnedEmptyQuantity,
      pricePerBottle: row.pricePerBottle,
      totalAmount: row.totalAmount,
      paymentMethod: row.paymentMethod,
      notes: row.notes,
      date: row.date,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    ).bottlesSold;
  }

  @override
  Future<SavingsSummary> getSummary() async {
    final costPerBottle = await getCostPerBottle();
    final deliveries = await _db.deliveriesDao.getAll();
    final walkIns = await _db.walkInSalesDao.getAll();
    final expenses = await _db.expensesDao.getAll();
    final dispenserSales = await _db.dispenserSalesDao.getAll();
    final manualAdditions = await _db.savingsDao.getTotalContributions();

    var deliveryProfit = 0.0;
    for (final d in deliveries) {
      if (d.deliveryStatus == 'cancelled') continue;
      deliveryProfit += d.quantity * (d.pricePerBottle - costPerBottle);
    }

    var walkInProfit = 0.0;
    for (final w in walkIns) {
      final qty = _walkInBottleCount(w);
      walkInProfit += qty * (w.pricePerBottle - costPerBottle);
    }

    final dispenserProfit =
        dispenserSales.fold(0.0, (sum, s) => sum + s.amount);

    var totalExpenses = 0.0;
    var maintenanceCosts = 0.0;
    var otherOperational = 0.0;
    for (final e in expenses) {
      totalExpenses += e.amount;
      if (e.category == 'Maintenance') {
        maintenanceCosts += e.amount;
      } else {
        otherOperational += e.amount;
      }
    }

    final currentSavings = deliveryProfit +
        walkInProfit +
        dispenserProfit -
        totalExpenses +
        manualAdditions;

    return SavingsSummary(
      currentSavings: currentSavings,
      deliveryProfit: deliveryProfit,
      walkInProfit: walkInProfit,
      dispenserProfit: dispenserProfit,
      totalExpenses: totalExpenses,
      maintenanceCosts: maintenanceCosts,
      otherOperationalCosts: otherOperational,
      manualAdditions: manualAdditions,
    );
  }

  @override
  Future<List<SavingsLedgerEntry>> getLedgerHistory() async {
    final costPerBottle = await getCostPerBottle();
    final entries = <SavingsLedgerEntry>[];

    for (final d in await _db.deliveriesDao.getAll()) {
      if (d.deliveryStatus == 'cancelled') continue;
      final profit = d.quantity * (d.pricePerBottle - costPerBottle);
      if (profit == 0) continue;
      entries.add(
        SavingsLedgerEntry(
          id: 'delivery_${d.id}',
          type: SavingsLedgerType.deliveryProfit,
          date: d.deliveryDate,
          amount: profit,
          notes: '${d.quantity} bottles @ ${d.pricePerBottle - costPerBottle} profit/btl',
        ),
      );
    }

    for (final w in await _db.walkInSalesDao.getAll()) {
      final qty = _walkInBottleCount(w);
      final profit = qty * (w.pricePerBottle - costPerBottle);
      if (profit == 0) continue;
      entries.add(
        SavingsLedgerEntry(
          id: 'walkin_${w.id}',
          type: SavingsLedgerType.walkInProfit,
          date: w.date,
          amount: profit,
          notes:
              '${WalkInTypeX.fromStorage(w.walkInType).label}: $qty bottles @ ${w.pricePerBottle - costPerBottle} profit/btl',
        ),
      );
    }

    for (final s in await _db.dispenserSalesDao.getAll()) {
      entries.add(
        SavingsLedgerEntry(
          id: 'dispenser_${s.id}',
          type: SavingsLedgerType.dispenserProfit,
          date: s.date,
          amount: s.amount,
          notes: s.notes,
        ),
      );
    }

    for (final e in await _db.expensesDao.getAll()) {
      final type = e.category == 'Maintenance'
          ? SavingsLedgerType.maintenanceDeduction
          : SavingsLedgerType.otherOperational;
      entries.add(
        SavingsLedgerEntry(
          id: 'expense_${e.id}',
          type: type,
          date: e.date,
          amount: e.amount,
          notes: e.notes ?? e.category,
        ),
      );
    }

    for (final c in await _db.savingsDao.getAll()) {
      entries.add(
        SavingsLedgerEntry(
          id: 'manual_${c.id}',
          type: SavingsLedgerType.manualAddition,
          date: c.date,
          amount: c.amount,
          notes: c.notes,
        ),
      );
    }

    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  @override
  Future<void> addContribution(SavingsContribution contribution) async {
    await _db.savingsDao.insertContribution(
      SavingsContributionsTableCompanion.insert(
        id: contribution.id,
        amount: contribution.amount,
        date: Value(contribution.date),
        notes: Value(contribution.notes),
      ),
    );
  }
}
