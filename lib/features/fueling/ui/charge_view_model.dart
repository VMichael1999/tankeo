import '../../../core/domain/fuel_type.dart';
import '../../stations/domain/station.dart';
import '../../vehicle/domain/vehicle.dart';
import '../bloc/fueling_bloc.dart';
import '../domain/fuel_quote.dart';

/// Datos derivados que pintan la pantalla de carga y la hoja del surtidor.
class ChargeViewModel {
  ChargeViewModel({
    required this.state,
    required this.station,
    required this.vehicle,
  });

  final FuelingState state;
  final Station station;
  final Vehicle vehicle;

  /// Surtidor asignado (o el que el usuario eligió tras una falla).
  String get pump => state.config.pumpOverride ?? station.assignedPump;
  String get pumpNumber => pump.split(' ').first;

  TankKind get tank => state.config.tank;
  bool get isGnv => tank == TankKind.gnv;
  FuelType get fuel => state.config.fuelType;

  /// Cotización de la sesión; antes de empezar, la de la configuración.
  FuelQuote get quote =>
      state.quote ??
      FuelQuote.forConfig(
        config: state.config,
        vehicle: vehicle,
        station: station,
      );

  /// Nivel del depósito, en vivo mientras se despacha.
  double get level => state.liveLevel(vehicle.level(tank));
  double get targetLevel => state.isIdleLike ? quote.targetLevel : level;

  /// Volumen contenido al nivel actual.
  double get levelVolume => tank.capacity * level / 100;

  /// Autonomía al nivel actual (km).
  int get rangeKm => (tank.capacity * level / 100 * tank.kmPerUnit).round();

  double get amount => state.displayAmount;
  double get price => quote.price;
  double get volume => state.volume;

  /// Tiempo simulado: GNV 3 m³/min, gasolina 4 gal/min.
  Duration get elapsed => Duration(
    seconds: (volume / state.config.profile.flowPerMinute * 60).floor(),
  );

  bool get plugged =>
      state is Connecting || state is Dispensing || state is Completed;
  bool get fullDone => state is Completed || state is HangingUp;

  double get remaining =>
      (quote.targetAmount - amount).clamp(0, double.infinity);
}
