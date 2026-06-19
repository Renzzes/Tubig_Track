import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final _formatter = NumberFormat.currency(
    locale: 'en_PH',
    symbol: '₱',
    decimalDigits: 2,
  );

  static final _compactFormatter = NumberFormat.compactCurrency(
    locale: 'en_PH',
    symbol: '₱',
    decimalDigits: 0,
  );

  static String format(double amount) => _formatter.format(amount);

  static String compact(double amount) => _compactFormatter.format(amount);

  static String formatNoSymbol(double amount) {
    final f = NumberFormat('#,##0.00', 'en_PH');
    return f.format(amount);
  }
}
