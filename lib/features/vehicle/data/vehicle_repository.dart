import 'dart:async';

import '../../../core/domain/fuel_type.dart';
import '../domain/vehicle.dart';

/// Origen de los datos del auto. Es la única fuente de verdad de los niveles.
abstract class VehicleRepository {
  Vehicle get vehicle;
  Stream<Vehicle> get changes;
  GnvCertification get certification;
  WeeklySpend get weeklySpend;
  TirePressure get tires;

  /// Fija el nivel de un depósito después de cargar.
  void setLevel(TankKind tank, double pct);
}

class InMemoryVehicleRepository implements VehicleRepository {
  InMemoryVehicleRepository() : _vehicle = Vehicle.mclarenF1();

  Vehicle _vehicle;
  final _controller = StreamController<Vehicle>.broadcast();

  @override
  Vehicle get vehicle => _vehicle;

  @override
  Stream<Vehicle> get changes => _controller.stream;

  @override
  final GnvCertification certification = GnvCertification(
    cylinder: 'GNV-2',
    validUntil: DateTime(2027, 1, 18),
    progress: .82,
    nextReview: 'marzo 2028',
  );

  @override
  final WeeklySpend weeklySpend = const WeeklySpend(
    total: 96.40,
    savedWithGnv: 38.20,
    barHeights: [30, 62, 24, 48, 20, 56, 84],
    todayAmount: 19.0,
  );

  @override
  final TirePressure tires = const TirePressure(
    psi: [28, 33, 33, 34],
    celsius: [31, 31, 30, 30],
  );

  @override
  void setLevel(TankKind tank, double pct) {
    _vehicle = _vehicle.withLevel(tank, pct);
    _controller.add(_vehicle);
  }
}
