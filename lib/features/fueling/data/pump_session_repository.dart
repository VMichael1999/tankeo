import 'dart:math' as math;

import 'fault_simulator.dart';

/// El surtidor no respondió al conectar.
class PumpOfflineException implements Exception {
  const PumpOfflineException();
}

/// Surtidor simulado. Emite el volumen despachado como un [Stream].
abstract class PumpSessionRepository {
  /// Abre la comunicación con el surtidor; falla con [PumpOfflineException].
  Future<void> connect();

  /// Despacha hasta [target] en [duration]. El último valor emitido es
  /// exactamente [target] salvo que se llame a [cancel].
  Stream<double> dispense({required double target, required Duration duration});

  /// Detiene el despacho en curso (botón «Detener»).
  void cancel();
}

class SimulatedPumpSessionRepository implements PumpSessionRepository {
  SimulatedPumpSessionRepository({
    this.tick = const Duration(milliseconds: 16),
    this.faults,
  });

  final Duration tick;
  final FaultSimulator? faults;

  @override
  Future<void> connect() async {
    if (faults?.consumePumpOffline() ?? false)
      throw const PumpOfflineException();
  }

  bool _cancelled = false;

  @override
  Stream<double> dispense({
    required double target,
    required Duration duration,
  }) async* {
    _cancelled = false;
    final watch = Stopwatch()..start();
    while (!_cancelled) {
      final k = math.min(
        1.0,
        watch.elapsedMicroseconds / duration.inMicroseconds,
      );
      // Arranque suave de la bomba en el primer 8 %.
      final eased = k < .08 ? k * k / .16 : k;
      yield target * eased;
      if (k >= 1) return;
      await Future<void>.delayed(tick);
    }
  }

  @override
  void cancel() => _cancelled = true;
}
