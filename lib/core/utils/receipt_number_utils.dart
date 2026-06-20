/// Generates delivery receipt numbers: TT-YYYY-NNNNNN
class ReceiptNumberUtils {
  ReceiptNumberUtils._();

  static String format(int year, int sequence) {
    return 'TT-$year-${sequence.toString().padLeft(6, '0')}';
  }

  static String settingsKeyForYear(int year) => 'receipt_seq_$year';
}
