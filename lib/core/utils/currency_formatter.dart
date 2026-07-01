import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(double amount) {
    // Format: 150 دج
    return '${amount.toStringAsFixed(0)} دج';
  }
}
