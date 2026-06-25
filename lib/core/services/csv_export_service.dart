import 'dart:io';

import 'package:path/path.dart' as p;

import '../database/app_database.dart';
import 'data_storage_service.dart';

/// Exports all business tables as individual CSV files under TubigTrack/CSV/.
class CsvExportService {
  CsvExportService(this._db, {DataStorageService? storage})
      : _storage = storage ?? DataStorageService.instance;

  final AppDatabase _db;
  final DataStorageService _storage;

  Future<List<String>> exportAllTables() async {
    await _storage.ensureFolderStructure();
    final csvDir = await _storage.csvDirectory();
    final stamp = _storage.timestampForFilename();
    final paths = <String>[];

    Future<String> write(String tableName, String content) async {
      final fileName = 'TubigTrack_${tableName}_$stamp.csv';
      final path = p.join(csvDir.path, fileName);
      await File(path).writeAsString(content);
      paths.add(path);
      return path;
    }

    await write('customers', await _exportCustomers());
    await write('deliveries', await _exportDeliveries());
    await write('payments', await _exportPayments());
    await write('expenses', await _exportExpenses());
    await write('suppliers', await _exportSuppliers());
    await write('inventory_stock', await _exportInventoryStock());
    await write('inventory_audits', await _exportInventoryAudits());
    await write('inventory_adjustments', await _exportInventoryAdjustments());
    await write('bottle_ledger', await _exportBottleLedger());
    await write('savings', await _exportSavings());
    await write('savings_goals', await _exportSavingsGoals());
    await write('transfers', await _exportTransfers());
    await write('deposits', await _exportDeposits());
    await write('supply_purchases', await _exportSupplyPurchases());
    await write('dispenser_sales', await _exportDispenserSales());
    await write('walk_in_sales', await _exportWalkInSales());
    await write('settings', await _exportSettings());

    return paths;
  }

  String _csvEscape(String? value) {
    final v = value ?? '';
    return '"${v.replaceAll('"', '""')}"';
  }

  Future<String> _exportCustomers() async {
    final b = StringBuffer()
      ..writeln('ID,Name,Phone,Address,Notes,Created');
    for (final c in await _db.customersDao.getAll()) {
      b.writeln(
        '${_csvEscape(c.id)},${_csvEscape(c.name)},${_csvEscape(c.phone)},'
        '${_csvEscape(c.address)},${_csvEscape(c.notes)},'
        '${_csvEscape(c.createdAt.toIso8601String())}',
      );
    }
    return b.toString();
  }

  Future<String> _exportDeliveries() async {
    final b = StringBuffer()
      ..writeln(
        'ID,CustomerID,Quantity,PricePerBottle,Total,PaymentStatus,'
        'AmountPaid,DepositApplied,Balance,Date,Time,DeliveryStatus,Notes,ReceiptNumber',
      );
    for (final d in await _db.deliveriesDao.getAll()) {
      b.writeln(
        '${_csvEscape(d.id)},${_csvEscape(d.customerId)},${d.quantity},'
        '${d.pricePerBottle},${d.totalAmount},${_csvEscape(d.paymentStatus)},'
        '${d.amountPaid},${d.depositApplied},${d.remainingBalance},'
        '${_csvEscape(d.deliveryDate.toIso8601String())},'
        '${_csvEscape(d.deliveryTime)},${_csvEscape(d.deliveryStatus)},'
        '${_csvEscape(d.notes)},${_csvEscape(d.receiptNumber)}',
      );
    }
    return b.toString();
  }

  Future<String> _exportPayments() async {
    final b = StringBuffer()
      ..writeln('ID,CustomerID,DeliveryID,Amount,Date,Notes');
    for (final pmt in await _db.paymentsDao.getAll()) {
      b.writeln(
        '${_csvEscape(pmt.id)},${_csvEscape(pmt.customerId)},'
        '${_csvEscape(pmt.deliveryId)},${pmt.amount},'
        '${_csvEscape(pmt.paymentDate.toIso8601String())},'
        '${_csvEscape(pmt.notes)}',
      );
    }
    return b.toString();
  }

  Future<String> _exportExpenses() async {
    final b = StringBuffer()..writeln('ID,Category,Amount,Date,Notes');
    for (final e in await _db.expensesDao.getAll()) {
      b.writeln(
        '${_csvEscape(e.id)},${_csvEscape(e.category)},${e.amount},'
        '${_csvEscape(e.date.toIso8601String())},${_csvEscape(e.notes)}',
      );
    }
    return b.toString();
  }

  Future<String> _exportSuppliers() async {
    final b = StringBuffer()
      ..writeln('ID,Name,ContactPerson,Mobile,Address,Notes,Created');
    for (final s in await _db.suppliersDao.getAll()) {
      b.writeln(
        '${_csvEscape(s.id)},${_csvEscape(s.name)},'
        '${_csvEscape(s.contactPerson)},${_csvEscape(s.mobile)},'
        '${_csvEscape(s.address)},${_csvEscape(s.notes)},'
        '${_csvEscape(s.createdAt.toIso8601String())}',
      );
    }
    return b.toString();
  }

  Future<String> _exportInventoryStock() async {
    final b = StringBuffer()..writeln('ItemType,Quantity');
    for (final s in await _db.inventoryStockDao.getAll()) {
      b.writeln('${_csvEscape(s.itemType)},${s.quantity}');
    }
    return b.toString();
  }

  Future<String> _exportInventoryAudits() async {
    final b = StringBuffer()
      ..writeln(
        'ID,AuditDate,SystemCount,PhysicalCount,Difference,ActionTaken,Notes',
      );
    for (final a in await _db.inventoryAuditsDao.getAll()) {
      b.writeln(
        '${_csvEscape(a.id)},${_csvEscape(a.auditDate.toIso8601String())},'
        '${a.systemCount},${a.physicalCount},${a.difference},'
        '${_csvEscape(a.actionTaken)},${_csvEscape(a.notes)}',
      );
    }
    return b.toString();
  }

  Future<String> _exportInventoryAdjustments() async {
    final b = StringBuffer()
      ..writeln('ID,AdjustmentDate,Quantity,Reason,Notes');
    for (final a in await _db.inventoryAdjustmentsDao.getAll()) {
      b.writeln(
        '${_csvEscape(a.id)},'
        '${_csvEscape(a.adjustmentDate.toIso8601String())},'
        '${a.quantity},${_csvEscape(a.reason)},${_csvEscape(a.notes)}',
      );
    }
    return b.toString();
  }

  Future<String> _exportBottleLedger() async {
    final b = StringBuffer()
      ..writeln('ID,CustomerID,Type,Quantity,Date,Notes');
    for (final t in await _db.bottleTransactionsDao.getAll()) {
      b.writeln(
        '${_csvEscape(t.id)},${_csvEscape(t.customerId)},'
        '${_csvEscape(t.transactionType)},${t.quantity},'
        '${_csvEscape(t.date.toIso8601String())},${_csvEscape(t.notes)}',
      );
    }
    return b.toString();
  }

  Future<String> _exportSavings() async {
    final b = StringBuffer()
      ..writeln('ID,Amount,Date,Notes');
    for (final s in await _db.savingsDao.getAll()) {
      b.writeln(
        '${_csvEscape(s.id)},${s.amount},'
        '${_csvEscape(s.date.toIso8601String())},${_csvEscape(s.notes)}',
      );
    }
    return b.toString();
  }

  Future<String> _exportSavingsGoals() async {
    final b = StringBuffer()
      ..writeln('ID,Name,TargetAmount,TargetDate,Notes,IsActive,CreatedAt');
    for (final g in await _db.savingsGoalsDao.getAll()) {
      b.writeln(
        '${_csvEscape(g.id)},${_csvEscape(g.name)},${g.targetAmount},'
        '${_csvEscape(g.targetDate?.toIso8601String())},'
        '${_csvEscape(g.notes)},${g.isActive},'
        '${_csvEscape(g.createdAt.toIso8601String())}',
      );
    }
    return b.toString();
  }

  Future<String> _exportTransfers() async {
    final b = StringBuffer()
      ..writeln('ID,Amount,TransferType,Date,Notes');
    for (final t in await _db.savingsTransfersDao.getAll()) {
      b.writeln(
        '${_csvEscape(t.id)},${t.amount},${_csvEscape(t.transferType)},'
        '${_csvEscape(t.date.toIso8601String())},${_csvEscape(t.notes)}',
      );
    }
    return b.toString();
  }

  Future<String> _exportDeposits() async {
    final b = StringBuffer()
      ..writeln('ID,CustomerID,Amount,TransactionType,CreatedAt,Notes,DeliveryID');
    for (final d in await _db.customerDepositsDao.getAll()) {
      b.writeln(
        '${_csvEscape(d.id)},${_csvEscape(d.customerId)},${d.amount},'
        '${_csvEscape(d.transactionType)},'
        '${_csvEscape(d.createdAt.toIso8601String())},'
        '${_csvEscape(d.notes)},${_csvEscape(d.deliveryId)}',
      );
    }
    return b.toString();
  }

  Future<String> _exportSupplyPurchases() async {
    final b = StringBuffer()
      ..writeln(
        'ID,PurchaseDate,SupplierName,SupplierID,ItemType,Quantity,'
        'UnitCost,TotalCost,Notes,ExpenseID,BottleTransactionID',
      );
    for (final s in await _db.supplyPurchasesDao.getAll()) {
      b.writeln(
        '${_csvEscape(s.id)},${_csvEscape(s.purchaseDate.toIso8601String())},'
        '${_csvEscape(s.supplierName)},${_csvEscape(s.supplierId)},'
        '${_csvEscape(s.itemType)},${s.quantity},${s.unitCost},${s.totalCost},'
        '${_csvEscape(s.notes)},${_csvEscape(s.expenseId)},'
        '${_csvEscape(s.bottleTransactionId)}',
      );
    }
    return b.toString();
  }

  Future<String> _exportDispenserSales() async {
    final b = StringBuffer()..writeln('ID,Amount,Date,Notes');
    for (final s in await _db.dispenserSalesDao.getAll()) {
      b.writeln(
        '${_csvEscape(s.id)},${s.amount},'
        '${_csvEscape(s.date.toIso8601String())},${_csvEscape(s.notes)}',
      );
    }
    return b.toString();
  }

  Future<String> _exportWalkInSales() async {
    final b = StringBuffer()
      ..writeln(
        'ID,CustomerID,WalkInType,BusinessOwnedQty,CustomerOwnedQty,'
        'ReturnedEmptyQty,PricePerBottle,Total,PaymentMethod,Notes,Date',
      );
    for (final s in await _db.walkInSalesDao.getAll()) {
      b.writeln(
        '${_csvEscape(s.id)},${_csvEscape(s.customerId)},'
        '${_csvEscape(s.walkInType)},${s.businessOwnedQuantity},'
        '${s.customerOwnedQuantity},${s.returnedEmptyQuantity},'
        '${s.pricePerBottle},${s.totalAmount},'
        '${_csvEscape(s.paymentMethod)},${_csvEscape(s.notes)},'
        '${_csvEscape(s.date.toIso8601String())}',
      );
    }
    return b.toString();
  }

  Future<String> _exportSettings() async {
    final b = StringBuffer()..writeln('Key,Value');
    for (final s in await _db.settingsDao.getAll()) {
      b.writeln('${_csvEscape(s.key)},${_csvEscape(s.value)}');
    }
    return b.toString();
  }
}
