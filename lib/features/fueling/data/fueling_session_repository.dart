import 'dart:async';

import '../../../core/domain/fuel_type.dart';
import '../domain/fueling_result.dart';

enum SessionStatus { idle, active, awaitingPayment }

/// Señales que coordinan los BLoCs sin conocerse entre sí.
sealed class SessionSignal {
  const SessionSignal();
}

/// El mapa o el detalle eligieron un combustible (y a veces un grifo).
class FuelSelected extends SessionSignal {
  const FuelSelected(this.fuel, {this.stationIndex});

  final FuelType fuel;
  final int? stationIndex;
}

/// El pago terminó: la sesión vuelve a estar libre.
class SessionSettled extends SessionSignal {
  const SessionSettled();
}

/// Estado compartido de la sesión de carga: quién está cargando dónde y cuál
/// es el último resultado pendiente de pago.
class FuelingSessionRepository {
  FuelingSessionRepository({FuelingResult? seed}) : _lastResult = seed;

  final _signals = StreamController<SessionSignal>.broadcast();

  SessionStatus _status = SessionStatus.idle;
  int? _activeStation;
  FuelingResult? _lastResult;

  Stream<SessionSignal> get signals => _signals.stream;
  SessionStatus get status => _status;

  /// Grifo donde hay una carga en curso (o `null`).
  int? get activeStation => _activeStation;

  /// Último resultado de carga (el de ejemplo si todavía no hay ninguno).
  FuelingResult? get lastResult => _lastResult;

  void selectFuel(FuelType fuel, {int? stationIndex}) =>
      _signals.add(FuelSelected(fuel, stationIndex: stationIndex));

  void markActive(int stationIndex) {
    _status = SessionStatus.active;
    _activeStation = stationIndex;
  }

  void markAwaitingPayment(FuelingResult result) {
    _status = SessionStatus.awaitingPayment;
    _activeStation = result.stationIndex;
    _lastResult = result;
  }

  void markIdle() {
    _status = SessionStatus.idle;
    _activeStation = null;
  }

  /// Llamado cuando el pago se confirmó.
  void settle() {
    markIdle();
    _signals.add(const SessionSettled());
  }

  Future<void> dispose() => _signals.close();
}
