import 'package:flutter_test/flutter_test.dart';
import 'package:tankeo/core/utils/money.dart';
import 'package:tankeo/core/utils/spanish_amount_words.dart';
import 'package:tankeo/core/utils/volume_format.dart';
import 'package:tankeo/features/payment/domain/invoice_calculator.dart';

void main() {
  group('InvoiceCalculator', () {
    test('S/ 19.01: 11.250 m³ × S/ 1.69', () {
      final total = InvoiceCalculator.total(volume: 11.25, price: 1.69);
      expect(total, 19.01);
      final a = InvoiceCalculator.fromTotal(total);
      expect(a.opGravada, 16.11);
      expect(a.igv, 2.90);
    });

    test('S/ 50.00 (monto exacto)', () {
      final a = InvoiceCalculator.fromTotal(
        InvoiceCalculator.total(volume: 2.7793, price: 17.99, exactAmount: 50),
      );
      expect(a.total, 50.00);
      expect(a.opGravada, 42.37);
      expect(a.igv, 7.63);
    });

    test('S/ 133.85', () {
      final a = InvoiceCalculator.fromTotal(133.85);
      expect(a.opGravada, 113.43);
      expect(a.igv, 20.42);
      expect(a.opGravada + a.igv, closeTo(a.total, 1e-9));
    });
  });

  group('SpanishAmountWords', () {
    test('enteros', () {
      expect(SpanishAmountWords.integer(1), 'UNO');
      expect(SpanishAmountWords.integer(16), 'DIECISÉIS');
      expect(SpanishAmountWords.integer(21), 'VEINTIUNO');
      expect(SpanishAmountWords.integer(22), 'VEINTIDÓS');
      expect(SpanishAmountWords.integer(100), 'CIEN');
      expect(SpanishAmountWords.integer(101), 'CIENTO UNO');
      expect(SpanishAmountWords.integer(133), 'CIENTO TREINTA Y TRES');
      expect(SpanishAmountWords.integer(1000), 'MIL');
    });

    test('importe del comprobante', () {
      expect(SpanishAmountWords.son(19.01), 'SON: DIECINUEVE CON 01/100 SOLES');
      expect(
        SpanishAmountWords.son(133.85),
        'SON: CIENTO TREINTA Y TRES CON 85/100 SOLES',
      );
    });
  });

  test('formatos', () {
    expect(Money.format(19.01), 'S/ 19.01');
    expect(Money.plain(1.69), '1.69');
    expect(VolumeFormat.d3(11.25), '11.250');
  });
}
