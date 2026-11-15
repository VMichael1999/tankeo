import 'dart:math' as math;

import '../../../core/domain/fuel_type.dart';
import '../../../core/utils/money.dart';
import '../../stations/domain/station.dart';
import '../../vehicle/domain/vehicle.dart';
import 'amount_preset.dart';
import 'fueling_config.dart';

/// Cálculos de una carga antes de empezar (las fórmulas del prototipo).
class FuelQuote {
  const FuelQuote({
    required this.tank,
    required this.level,
    required this.price,
    required this.preset,
  });

  /// Cotización para la configuración elegida, el auto y el grifo.
  factory FuelQuote.forConfig({
    required FuelingConfig config,
    required Vehicle vehicle,
    required Station station,
  }) => FuelQuote(
    tank: config.tank,
    level: vehicle.level(config.tank),
    price: station.priceOf(config.fuelType),
    preset: config.preset,
  );

  final TankKind tank;

  /// Nivel actual del depósito, de 0 a 100.
  final double level;
  final double price;
  final AmountPreset preset;

  /// Volumen libre: `capacidad × (100 − nivel) / 100`.
  double get freeVolume => tank.capacity * (100 - level) / 100;

  /// Importe para llenar el depósito.
  double get fullAmount => Money.round2(freeVolume * price);

  /// Lleno: el volumen libre. Monto: `min(libre, monto / precio)`.
  double get targetVolume =>
      preset.isFull ? freeVolume : math.min(freeVolume, preset.amount! / price);

  /// Importe objetivo: el monto elegido, o el de llenar si el monto no cabe.
  double get targetAmount => preset.isFull || preset.amount! >= fullAmount
      ? fullAmount
      : preset.amount!;

  /// Nivel final del depósito al completar el objetivo.
  double get targetLevel =>
      math.min(100, level + targetVolume / tank.capacity * 100);

  /// ¿Se carga un monto exacto (no «Lleno» ni más de lo que cabe)?
  bool get isExactAmount => !preset.isFull && preset.amount! < fullAmount;

  /// Un monto mayor a lo que cabe se deshabilita.
  bool fits(AmountPreset p) => p.isFull || p.amount! <= fullAmount;

  FuelQuote withPreset(AmountPreset p) =>
      FuelQuote(tank: tank, level: level, price: price, preset: p);
}
