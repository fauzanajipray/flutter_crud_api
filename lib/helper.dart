import 'package:intl/intl.dart';

String formatCurrency(dynamic number) {
  if (number is int) {
    return NumberFormat().format(number).replaceAll(',', '.');
  } else if (number is double) {
    return NumberFormat()
        .format(number)
        .replaceAll(',', 'X')
        .replaceAll('.', ',')
        .replaceAll('X', '.');
  } else {
    return '0';
  }
}
