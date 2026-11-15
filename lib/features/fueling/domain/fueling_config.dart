import 'package:equatable/equatable.dart';

import '../../../core/domain/fuel_type.dart';
import 'amount_preset.dart';
import 'fuel_profile.dart';

/// Lo que el usuario elige en la pantalla de carga.
class FuelingConfig extends Equatable {
  const FuelingConfig({
    this.tank = TankKind.gnv,
    this.grade = FuelType.regular,
    this.stationIndex = 0,
    this.gasolinePreset = const AmountPreset.soles(50),
    this.gnvPreset = AmountPreset.full,
    this.pumpOverride,
  });

  final TankKind tank;

  /// Regular o Premium (solo con gasolina).
  final FuelType grade;
  final int stationIndex;
  final AmountPreset gasolinePreset;
  final AmountPreset gnvPreset;

  /// Surtidor reasignado por el usuario («4 · Isla B» → «5 · Isla A»).
  final String? pumpOverride;

  FuelType get fuelType => tank == TankKind.gnv ? FuelType.gnv : grade;
  FuelProfile get profile => FuelProfile.of(tank);
  AmountPreset get preset => tank == TankKind.gnv ? gnvPreset : gasolinePreset;

  FuelingConfig copyWith({
    TankKind? tank,
    FuelType? grade,
    int? stationIndex,
    AmountPreset? preset,
    String? pumpOverride,
  }) {
    final t = tank ?? this.tank;
    return FuelingConfig(
      tank: t,
      grade: grade ?? this.grade,
      stationIndex: stationIndex ?? this.stationIndex,
      gasolinePreset: preset != null && this.tank == TankKind.gasoline
          ? preset
          : gasolinePreset,
      gnvPreset: preset != null && this.tank == TankKind.gnv
          ? preset
          : gnvPreset,
      pumpOverride: stationIndex != null && stationIndex != this.stationIndex
          ? null
          : (pumpOverride ?? this.pumpOverride),
    );
  }

  @override
  List<Object?> get props => [
    tank,
    grade,
    stationIndex,
    gasolinePreset,
    gnvPreset,
    pumpOverride,
  ];
}
