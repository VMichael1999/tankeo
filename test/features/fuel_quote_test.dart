import 'package:flutter_test/flutter_test.dart';
import 'package:tankeo/core/domain/fuel_type.dart';
import 'package:tankeo/features/fueling/domain/amount_preset.dart';
import 'package:tankeo/features/fueling/domain/fuel_quote.dart';

void main() {
  FuelQuote gnv(AmountPreset p) =>
      FuelQuote(tank: TankKind.gnv, level: 25, price: 1.69, preset: p);

  test('volumen libre y objetivo con «Lleno»', () {
    final q = gnv(AmountPreset.full);
    expect(q.freeVolume, closeTo(11.25, 1e-9));
    expect(q.targetVolume, closeTo(11.25, 1e-9));
    expect(q.fullAmount, 19.01);
    expect(q.targetAmount, 19.01);
    expect(q.targetLevel, 100);
    expect(q.isExactAmount, isFalse);
  });

  test('volumen objetivo con monto', () {
    final q = gnv(const AmountPreset.soles(10));
    expect(q.targetVolume, closeTo(10 / 1.69, 1e-9));
    expect(q.targetAmount, 10);
    expect(q.isExactAmount, isTrue);
  });

  test('un monto mayor a lo que cabe se deshabilita', () {
    final q = gnv(AmountPreset.full);
    expect(q.fits(const AmountPreset.soles(15)), isTrue);
    expect(q.fits(const AmountPreset.soles(20)), isFalse);
    expect(q.fits(AmountPreset.full), isTrue);
  });

  test('un monto que no cabe se limita al volumen libre', () {
    final q = gnv(const AmountPreset.soles(30));
    expect(q.targetVolume, closeTo(11.25, 1e-9));
    expect(q.targetAmount, 19.01);
  });

  test('gasolina: 38 % de 12 gal', () {
    const q = FuelQuote(
      tank: TankKind.gasoline,
      level: 38,
      price: 21.49,
      preset: AmountPreset.soles(50),
    );
    expect(q.freeVolume, closeTo(7.44, 1e-9));
    expect(q.targetVolume, closeTo(50 / 21.49, 1e-9));
  });
}
