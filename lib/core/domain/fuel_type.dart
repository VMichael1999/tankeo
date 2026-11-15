import 'package:flutter/painting.dart';

import '../theme/tankeo_tokens.dart';

/// Depósito del auto: gasolina (gal) o cilindro de GNV (m³).
enum TankKind {
  gasoline(capacity: 12, kmPerUnit: 42, unit: 'gal', initialLevel: 38),
  gnv(capacity: 15, kmPerUnit: 13, unit: 'm³', initialLevel: 25);

  const TankKind({
    required this.capacity,
    required this.kmPerUnit,
    required this.unit,
    required this.initialLevel,
  });

  /// Capacidad en galones o metros cúbicos.
  final double capacity;

  /// Rendimiento: km por galón o por m³.
  final double kmPerUnit;
  final String unit;
  final double initialLevel;
}

/// Combustible que vende un grifo. Cada valor conoce su unidad y su color.
enum FuelType {
  gnv(unit: 'm³'),
  regular(unit: 'gal'),
  premium(unit: 'gal'),
  diesel(unit: 'gal');

  const FuelType({required this.unit});

  final String unit;

  bool get isGnv => this == gnv;

  /// Depósito que usa este combustible; el diésel no cabe en el McLaren F1.
  TankKind? get tank => switch (this) {
    gnv => TankKind.gnv,
    regular || premium => TankKind.gasoline,
    diesel => null,
  };

  Color color(TankeoTokens t) => switch (this) {
    gnv => t.gnv,
    regular => t.primary,
    premium => t.premium,
    diesel => t.diesel,
  };
}
