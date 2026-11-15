import 'package:equatable/equatable.dart';

import '../../../core/domain/fuel_type.dart';

/// Auto dual (gasolina + GNV) del usuario. Los niveles van de 0 a 100.
class Vehicle extends Equatable {
  const Vehicle({
    required this.name,
    required this.year,
    required this.odometerKm,
    required this.gasolineLevel,
    required this.gnvLevel,
    this.compatibleFuels = const {
      FuelType.regular,
      FuelType.premium,
      FuelType.gnv,
    },
  });

  factory Vehicle.mclarenF1() => Vehicle(
    name: 'McLaren F1',
    year: 1993,
    odometerKm: 41280,
    gasolineLevel: TankKind.gasoline.initialLevel,
    gnvLevel: TankKind.gnv.initialLevel,
  );

  final String name;
  final int year;
  final int odometerKm;
  final double gasolineLevel;
  final double gnvLevel;
  final Set<FuelType> compatibleFuels;

  double level(TankKind tank) =>
      tank == TankKind.gnv ? gnvLevel : gasolineLevel;

  /// Volumen contenido en [tank] (gal o m³) al nivel [pct] (por defecto, el actual).
  double volume(TankKind tank, {double? pct}) =>
      tank.capacity * (pct ?? level(tank)) / 100;

  /// Autonomía en km: `capacidad × nivel × rendimiento`.
  int range(TankKind tank, {double? pct}) =>
      (volume(tank, pct: pct) * tank.kmPerUnit).round();

  int get totalRange =>
      range(TankKind.gasoline, pct: gasolineLevel.roundToDouble()) +
      range(TankKind.gnv, pct: gnvLevel.roundToDouble());

  Vehicle withLevel(TankKind tank, double pct) => Vehicle(
    name: name,
    year: year,
    odometerKm: odometerKm,
    gasolineLevel: tank == TankKind.gasoline ? pct : gasolineLevel,
    gnvLevel: tank == TankKind.gnv ? pct : gnvLevel,
    compatibleFuels: compatibleFuels,
  );

  bool accepts(FuelType fuel) => compatibleFuels.contains(fuel);

  @override
  List<Object?> get props => [
    name,
    year,
    odometerKm,
    gasolineLevel,
    gnvLevel,
    compatibleFuels,
  ];
}

/// Certificación del cilindro de GNV (chip Infogas).
class GnvCertification extends Equatable {
  const GnvCertification({
    required this.cylinder,
    required this.validUntil,
    required this.progress,
    required this.nextReview,
  });

  final String cylinder;
  final DateTime validUntil;

  /// Avance de la barra, de 0 a 1.
  final double progress;
  final String nextReview;

  int daysLeft(DateTime now) {
    final a = DateTime(now.year, now.month, now.day);
    final b = DateTime(validUntil.year, validUntil.month, validUntil.day);
    return b.difference(a).inDays;
  }

  bool isValid(DateTime now) => daysLeft(now) >= 0;

  @override
  List<Object?> get props => [cylinder, validUntil, progress, nextReview];
}

/// Gasto de la semana para las barras de D a S.
class WeeklySpend extends Equatable {
  const WeeklySpend({
    required this.total,
    required this.savedWithGnv,
    required this.barHeights,
    required this.todayAmount,
    this.todayIndex = 6,
  });

  final double total;
  final double savedWithGnv;

  /// Alturas de las barras (D, L, M, M, J, V, S), en píxeles de diseño.
  final List<double> barHeights;
  final double todayAmount;

  /// Barra resaltada («hoy»); en el prototipo es la última (sábado).
  final int todayIndex;

  @override
  List<Object?> get props => [
    total,
    savedWithGnv,
    barHeights,
    todayAmount,
    todayIndex,
  ];
}

/// Presión de las cuatro llantas (delantera izq., der., trasera izq., der.).
class TirePressure extends Equatable {
  const TirePressure({required this.psi, required this.celsius});

  final List<int> psi;
  final List<int> celsius;

  static const lowThreshold = 30;

  bool isLow(int i) => psi[i] < lowThreshold;

  @override
  List<Object?> get props => [psi, celsius];
}
