import 'dart:async';

import '../domain/route_path.dart';

/// Simula el recorrido: ~46 km/h, que bajan al 42 % en los 50 m antes y
/// después de cada esquina. El tiempo se comprime para durar 13–19 s.
class RouteSimulator {
  RouteSimulator(
    this.path, {
    this.duration,
    this.tick = const Duration(milliseconds: 50),
  }) {
    _build();
  }

  final RoutePath path;
  final Duration? duration;
  final Duration tick;

  static const cruiseKmh = 46.0;
  static const slowFactor = .42;
  static const slowRadiusM = 50.0;

  final List<double> _timeAt = [0]; // peso de tiempo acumulado por metro

  /// Velocidad en km/h a [d] metros del inicio, dadas las [corners].
  static double speedFor(List<double> corners, double d) {
    final near = corners.any((c) => (c - d).abs() <= slowRadiusM);
    return cruiseKmh * (near ? slowFactor : 1);
  }

  double speedAt(double d) => speedFor(path.corners, d);

  void _build() {
    final n = path.total.ceil();
    for (var m = 0; m < n; m++) {
      _timeAt.add(_timeAt.last + 1 / speedAt(m + .5));
    }
  }

  /// Duración total simulada: entre 13 y 19 s según el largo de la ruta.
  Duration get totalDuration =>
      duration ??
      Duration(
        milliseconds: (13000 + (path.total / 4000).clamp(0, 1) * 6000).round(),
      );

  /// Distancia recorrida cuando pasó la fracción [f] (0..1) del tiempo.
  double distanceAt(double f) {
    final target = _timeAt.last * f.clamp(0, 1);
    var lo = 0, hi = _timeAt.length - 1;
    while (lo < hi) {
      final mid = (lo + hi) ~/ 2;
      if (_timeAt[mid] < target) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    return lo.toDouble().clamp(0, path.total);
  }

  /// Emite la distancia recorrida hasta llegar al destino.
  Stream<double> run() async* {
    final watch = Stopwatch()..start();
    final total = totalDuration.inMilliseconds;
    while (true) {
      final f = watch.elapsedMilliseconds / total;
      yield f >= 1 ? path.total : distanceAt(f);
      if (f >= 1) return;
      await Future<void>.delayed(tick);
    }
  }
}
