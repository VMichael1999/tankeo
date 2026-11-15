import '../../../core/domain/fuel_type.dart';
import 'amount_preset.dart';

/// Estrategia por tipo de depósito: unidad, montos y pasos de conexión.
abstract class FuelProfile {
  const FuelProfile();

  factory FuelProfile.of(TankKind tank) =>
      tank == TankKind.gnv ? const GnvProfile() : const GasolineProfile();

  TankKind get tank;
  List<AmountPreset> get presets;

  /// ¿Pide la lista de seguridad y validar el chip Infogas?
  bool get requiresSafetyCheck;

  /// Caudal simulado del surtidor (gal/min o m³/min).
  double get flowPerMinute;

  String get unit => tank.unit;
}

class GasolineProfile extends FuelProfile {
  const GasolineProfile();

  @override
  TankKind get tank => TankKind.gasoline;

  @override
  List<AmountPreset> get presets => const [
    AmountPreset.soles(20),
    AmountPreset.soles(50),
    AmountPreset.soles(100),
    AmountPreset.full,
  ];

  @override
  bool get requiresSafetyCheck => false;

  @override
  double get flowPerMinute => 4;
}

class GnvProfile extends FuelProfile {
  const GnvProfile();

  @override
  TankKind get tank => TankKind.gnv;

  @override
  List<AmountPreset> get presets => const [
    AmountPreset.soles(5),
    AmountPreset.soles(10),
    AmountPreset.soles(15),
    AmountPreset.full,
  ];

  @override
  bool get requiresSafetyCheck => true;

  @override
  double get flowPerMinute => 3;
}
