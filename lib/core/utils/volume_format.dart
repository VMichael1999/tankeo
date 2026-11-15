import 'package:intl/intl.dart';

/// Volúmenes con 3 decimales (`11.250`), o los decimales indicados, y
/// enteros con coma de miles (`41,280`).
abstract final class VolumeFormat {
  static String format(double value, {int digits = 3}) =>
      value.toStringAsFixed(digits);

  static String d1(double v) => format(v, digits: 1);
  static String d2(double v) => format(v, digits: 2);
  static String d3(double v) => format(v, digits: 3);

  /// `41,280`
  static String grouped(int value) =>
      NumberFormat('#,##0', 'en_US').format(value);
}
