/// Marcas de tarjeta que reconoce el formulario.
enum CardBrand { visa, mastercard, amex, other }

/// Reglas puras de la tarjeta: marca por BIN, Luhn, fecha y formato.
abstract final class CardValidator {
  static String digits(String s) => s.replaceAll(RegExp(r'\D'), '');

  static CardBrand brand(String number) {
    final d = digits(number);
    if (d.startsWith('4')) return CardBrand.visa;
    if (d.startsWith('34') || d.startsWith('37')) return CardBrand.amex;
    final two = d.length >= 2 ? int.tryParse(d.substring(0, 2)) : null;
    if (two != null && ((two >= 51 && two <= 55))) return CardBrand.mastercard;
    final four = d.length >= 4 ? int.tryParse(d.substring(0, 4)) : null;
    if (four != null && four >= 2221 && four <= 2720) {
      return CardBrand.mastercard;
    }
    return CardBrand.other;
  }

  static bool luhn(String number) {
    final d = digits(number);
    if (d.length < 13 || d.length > 19) return false;
    var sum = 0;
    var alt = false;
    for (var i = d.length - 1; i >= 0; i--) {
      var n = int.parse(d[i]);
      if (alt) {
        n *= 2;
        if (n > 9) n -= 9;
      }
      sum += n;
      alt = !alt;
    }
    return sum % 10 == 0;
  }

  /// `MM/AA` válido y posterior al mes actual.
  static bool expiryValid(String text, DateTime now) {
    final m = RegExp(r'^(\d{2})/(\d{2})$').firstMatch(text);
    if (m == null) return false;
    final month = int.parse(m.group(1)!);
    final year = 2000 + int.parse(m.group(2)!);
    if (month < 1 || month > 12) return false;
    return DateTime(year, month + 1).isAfter(DateTime(now.year, now.month));
  }

  static bool cvvValid(String cvv) => RegExp(r'^\d{3,4}$').hasMatch(cvv);

  static bool holderValid(String name) =>
      name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length >= 2;

  /// `4111 1111 1111 1111` (Amex: 4-6-5).
  static String format(String number) {
    final d = digits(number);
    final amex = brand(d) == CardBrand.amex;
    final groups = amex ? [4, 6, 5] : [4, 4, 4, 4, 3];
    final out = <String>[];
    var i = 0;
    for (final g in groups) {
      if (i >= d.length) break;
      out.add(d.substring(i, (i + g).clamp(0, d.length)));
      i += g;
    }
    return out.join(' ');
  }
}
