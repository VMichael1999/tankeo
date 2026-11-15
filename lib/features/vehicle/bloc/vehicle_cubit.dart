import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/vehicle_repository.dart';
import '../domain/vehicle.dart';

/// Controles rápidos de la pantalla de inicio.
enum QuickControl { doors, gnv, lights, fuelCap }

class VehicleState extends Equatable {
  const VehicleState({
    required this.vehicle,
    required this.certification,
    required this.weeklySpend,
    required this.tires,
    required this.controls,
  });

  final Vehicle vehicle;
  final GnvCertification certification;
  final WeeklySpend weeklySpend;
  final TirePressure tires;
  final Map<QuickControl, bool> controls;

  bool isOn(QuickControl c) => controls[c] ?? false;

  VehicleState copyWith({
    Vehicle? vehicle,
    Map<QuickControl, bool>? controls,
  }) => VehicleState(
    vehicle: vehicle ?? this.vehicle,
    certification: certification,
    weeklySpend: weeklySpend,
    tires: tires,
    controls: controls ?? this.controls,
  );

  @override
  List<Object?> get props => [
    vehicle,
    certification,
    weeklySpend,
    tires,
    controls,
  ];
}

/// Estado del auto: niveles, certificación, llantas, gasto y controles rápidos.
/// Escucha al [VehicleRepository], no a otros BLoCs.
class VehicleCubit extends Cubit<VehicleState> {
  VehicleCubit(this._repo)
    : super(
        VehicleState(
          vehicle: _repo.vehicle,
          certification: _repo.certification,
          weeklySpend: _repo.weeklySpend,
          tires: _repo.tires,
          controls: const {
            QuickControl.doors: true,
            QuickControl.gnv: true,
            QuickControl.lights: false,
            QuickControl.fuelCap: false,
          },
        ),
      ) {
    _sub = _repo.changes.listen((v) => emit(state.copyWith(vehicle: v)));
  }

  final VehicleRepository _repo;
  late final StreamSubscription<Vehicle> _sub;

  void toggle(QuickControl control) {
    emit(
      state.copyWith(
        controls: {...state.controls, control: !state.isOn(control)},
      ),
    );
  }

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}
