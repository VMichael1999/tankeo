/// Importe en letras para el comprobante: `SON: DIECINUEVE CON 01/100 SOLES`.
abstract final class SpanishAmountWords {
  static const _units = [
    '',
    'UNO',
    'DOS',
    'TRES',
    'CUATRO',
    'CINCO',
    'SEIS',
    'SIETE',
    'OCHO',
    'NUEVE',
    'DIEZ',
    'ONCE',
    'DOCE',
    'TRECE',
    'CATORCE',
    'QUINCE',
    'DIECISÉIS',
    'DIECISIETE',
    'DIECIOCHO',
    'DIECINUEVE',
    'VEINTE',
    'VEINTIUNO',
    'VEINTIDÓS',
    'VEINTITRÉS',
    'VEINTICUATRO',
    'VEINTICINCO',
    'VEINTISÉIS',
    'VEINTISIETE',
    'VEINTIOCHO',
    'VEINTINUEVE',
  ];
  static const _tens = [
    '',
    '',
    '',
    'TREINTA',
    'CUARENTA',
    'CINCUENTA',
    'SESENTA',
    'SETENTA',
    'OCHENTA',
    'NOVENTA',
  ];
  static const _hundreds = [
    '',
    'CIENTO',
    'DOSCIENTOS',
    'TRESCIENTOS',
    'CUATROCIENTOS',
    'QUINIENTOS',
    'SEISCIENTOS',
    'SETECIENTOS',
    'OCHOCIENTOS',
    'NOVECIENTOS',
  ];

  /// Entero de 0 a 9 999 en letras.
  static String integer(int n) {
    if (n == 0) return 'CERO';
    if (n == 100) return 'CIEN';
    if (n >= 1000) {
      final thousands = n ~/ 1000;
      final rest = n % 1000;
      final head = thousands == 1 ? 'MIL' : '${integer(thousands)} MIL';
      return rest == 0 ? head : '$head ${integer(rest)}';
    }
    final c = n ~/ 100;
    final r = n % 100;
    var s = _hundreds[c];
    if (r != 0) {
      final tail = r < 30
          ? _units[r]
          : '${_tens[r ~/ 10]}${r % 10 != 0 ? ' Y ${_units[r % 10]}' : ''}';
      s += s.isEmpty ? tail : ' $tail';
    }
    return s;
  }

  /// `SON: DIECINUEVE CON 01/100 SOLES`
  static String son(double total) {
    final whole = (total + 1e-9).floor();
    final cents = ((total - whole) * 100).round();
    return 'SON: ${integer(whole)} CON ${cents.toString().padLeft(2, '0')}/100 SOLES';
  }
}
