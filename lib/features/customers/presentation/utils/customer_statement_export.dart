import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/services/customer_statement_pdf_builder.dart';
import '../../../../core/services/pdf_export_actions.dart';
import '../../data/repositories/customer_statement_repository.dart';

class CustomerStatementExport {
  CustomerStatementExport._();

  static Future<void> exportPdf(
    BuildContext context,
    WidgetRef ref,
    String customerId,
  ) async {
    try {
      final db = ref.read(databaseProvider);
      final repo = CustomerStatementRepository(db);
      final data = await repo.buildForCustomer(customerId);
      if (data == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Customer not found')),
          );
        }
        return;
      }
      final pdf = await CustomerStatementPdfBuilder.build(data);
      final bytes = await pdf.save();
      if (!context.mounted) return;
      final safeName = data.customerName.replaceAll(RegExp(r'[^\w\s-]'), '');
      await PdfExportActions.showOptions(
        context,
        bytes: bytes,
        fileName: 'statement_$safeName.pdf',
        shareText: 'Account Statement — ${data.customerName}',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating statement: $e')),
        );
      }
    }
  }
}
