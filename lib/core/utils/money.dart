import 'package:intl/intl.dart';

/// Soles peruanos con el formato del prototipo: `S/ 19.01`.
///
/// Se usa el formato numérico con punto decimal y coma de miles (así se
/// escribe en Perú), sin depender de los datos regionales del dispositivo.
abstract final class Money {
  static final NumberFormat _fmt = NumberFormat.currency(
    locale: 'en_US',
    symbol: 'S/ ',
    decimalDigits: 2,
  );
  static final NumberFormat _plain = NumberFormat('#,##0.00', 'en_US');

  /// `S/ 19.01`
  static String format(double value) => _fmt.format(value);

  /// `19.01` (sin símbolo; usado en la tabla del comprobante y el LCD).
  static String plain(double value) => _plain.format(value);

  /// Redondea a 2 decimales como el prototipo (`Math.round(n * 100) / 100`).
  static double round2(double value) => (value * 100).roundToDouble() / 100;
}
