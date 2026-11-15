import 'package:equatable/equatable.dart';

import '../../../core/domain/fuel_type.dart';
import '../../../core/utils/money.dart';

/// Resultado de una carga ya colgada la manguera.
class FuelingResult extends Equatable {
  const FuelingResult({
    required this.fuel,
    required this.stationIndex,
    required this.levelBefore,
    required this.levelAfter,
    required this.volume,
    required this.price,
    required this.total,
    required this.minutes,
    required this.kmAdded,
    required this.createdAt,
  });

  /// Ejemplo para entrar directo al resumen: GNV, 11.250 m³ desde 25 %.
  factory FuelingResult.sample({DateTime? at}) => FuelingResult.fromSession(
    fuel: FuelType.gnv,
    stationIndex: 0,
    levelBefore: 25,
    volume: 11.25,
    price: 1.69,
    createdAt: at ?? DateTime.now(),
  );

  /// Construye el resultado desde los datos de la sesión de carga.
  /// Si [exactAmount] viene, el total es ese monto (carga por monto exacto).
  factory FuelingResult.fromSession({
    required FuelType fuel,
    required int stationIndex,
    required double levelBefore,
    required double volume,
    required double price,
    required DateTime createdAt,
    double? exactAmount,
  }) {
    final tank = fuel.tank!;
    final after = (levelBefore + volume / tank.capacity * 100).clamp(0, 100);
    final flow = tank == TankKind.gnv ? 3.0 : 4.0;
    return FuelingResult(
      fuel: fuel,
      stationIndex: stationIndex,
      levelBefore: levelBefore,
      levelAfter: after.toDouble(),
      volume: volume,
      price: price,
      total: exactAmount ?? Money.round2(volume * price),
      minutes: (volume / flow).round().clamp(1, 1 << 20),
      kmAdded: (volume * tank.kmPerUnit).round(),
      createdAt: createdAt,
    );
  }

  final FuelType fuel;
  final int stationIndex;
  final double levelBefore;
  final double levelAfter;
  final double volume;
  final double price;
  final double total;
  final int minutes;
  final int kmAdded;
  final DateTime createdAt;

  TankKind get tank => fuel.tank!;
  double get levelAdded => levelAfter - levelBefore;

  @override
  List<Object?> get props => [
    fuel,
    stationIndex,
    levelBefore,
    levelAfter,
    volume,
    price,
    total,
    minutes,
    kmAdded,
    createdAt,
  ];
}
