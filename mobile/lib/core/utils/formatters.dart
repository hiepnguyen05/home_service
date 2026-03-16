import 'package:intl/intl.dart';

class AppFormatters {
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  static String formatCompactCurrency(double amount) {
    if (amount >= 1000) {
      double kAmount = amount / 1000;
      // Check if it's a whole number
      if (kAmount == kAmount.toInt()) {
        return '${kAmount.toInt()}k';
      }
      return '${kAmount.toStringAsFixed(1)}k';
    }
    return amount.toInt().toString();
  }
}