import 'dart:math' as math;

import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Paso de la ruta real (Google): la maniobra ocurre al inicio del paso.
class RouteStep {
  const RouteStep({
    required this.maneuver,
    required this.street,
    required this.distanceM,
  });

  /// Maniobra de Google (`TURN_LEFT`, `NAME_CHANGE`, `DEPART`…).
  final String maneuver;

  /// Calle a la que entra el auto en este paso, si se pudo leer.
  final String? street;
  final double distanceM;

  /// Saca la calle del texto de Google: «Gira a la derecha hacia Av. X»,
  /// «Continúa por Ca. Y», «Dirígete al norte en Av. Z hacia …».
  static String? streetFrom(String instructions) {
    var t = instructions.split('\n').first.trim();
    String? after(String key) {
      final i = t.indexOf(key);
      return i < 0 ? null : t.substring(i + key.length).trim();
    }

    String? s;
    if (t.startsWith('Dirígete') && t.contains(' en ')) {
      s = after(' en ');
      final h = s?.indexOf(' hacia ') ?? -1;
      if (s != null && h > 0) s = s.substring(0, h);
    } else {
      s = after('hacia ') ?? after('por ') ?? after(' en ');
    }
    t = (s ?? '').trim();
    return t.isEmpty ? null : t;
  }
}

/// Ruta como polilínea con distancias en metros: posición y rumbo por
/// distancia recorrida, y esquinas.
class RoutePath {
  RoutePath(this.points, {this.minutes, this.steps = const []})
    : assert(points.length >= 2) {
    _cum.add(0);
    for (var i = 1; i < points.length; i++) {
      _cum.add(_cum.last + meters(points[i - 1], points[i]));
    }
  }

  final List<LatLng> points;

  /// Minutos en auto según Google (o `null` si se usa el dato del grifo).
  final int? minutes;

  /// Pasos reales de Google (vacío si la ruta es de ejemplo).
  final List<RouteStep> steps;

  /// Metros (en la escala de la polilínea) donde empieza cada paso.
  late final List<double> stepStarts = () {
    final sum = steps.fold<double>(0, (a, s) => a + s.distanceM);
    final k = sum == 0 ? 1.0 : total / sum;
    final out = <double>[];
    var acc = 0.0;
    for (final s in steps) {
      out.add(acc * k);
      acc += s.distanceM;
    }
    return out;
  }();
  final List<double> _cum = [];

  double get total => _cum.last;

  /// Metros acumulados al inicio de cada vértice.
  List<double> get cumulative => List.unmodifiable(_cum);

  /// Distancias donde la ruta dobla (vértices intermedios).
  List<double> get corners => _cum.sublist(1, _cum.length - 1);

  int get segments => points.length - 1;

  static const _mPerDegLat = 111320.0;

  static double _east(LatLng a, LatLng b) =>
      (b.longitude - a.longitude) *
      _mPerDegLat *
      math.cos(a.latitude * math.pi / 180);

  static double _north(LatLng a, LatLng b) =>
      (b.latitude - a.latitude) * _mPerDegLat;

  static double meters(LatLng a, LatLng b) =>
      math.sqrt(math.pow(_east(a, b), 2) + math.pow(_north(a, b), 2));

  /// Tramo en el que cae la distancia [d].
  int segmentAt(double d) {
    for (var i = 1; i < _cum.length; i++) {
      if (d < _cum[i]) return i - 1;
    }
    return segments - 1;
  }

  LatLng positionAt(double d) {
    final x = d.clamp(0, total).toDouble();
    final i = segmentAt(x);
    final len = _cum[i + 1] - _cum[i];
    final f = len == 0 ? 0.0 : (x - _cum[i]) / len;
    final a = points[i], b = points[i + 1];
    return LatLng(
      a.latitude + (b.latitude - a.latitude) * f,
      a.longitude + (b.longitude - a.longitude) * f,
    );
  }

  /// Rumbo del tramo en grados (0 = norte, sentido horario).
  double headingOfSegment(int i) {
    final a = points[i], b = points[i + 1];
    final deg = math.atan2(_east(a, b), _north(a, b)) * 180 / math.pi;
    return (deg + 360) % 360;
  }

  double headingAt(double d) => headingOfSegment(segmentAt(d));

  /// Giro entre el tramo [i] y el siguiente, en grados con signo:
  /// positivo = derecha, negativo = izquierda (coordenadas con y hacia abajo).
  double turnAngle(int i) {
    final a = points[i], b = points[i + 1], c = points[i + 2];
    final e1 = _east(a, b), s1 = -_north(a, b);
    final e2 = _east(b, c), s2 = -_north(b, c);
    final cross = e1 * s2 - s1 * e2;
    final dot = e1 * e2 + s1 * s2;
    return math.atan2(cross, dot) * 180 / math.pi;
  }
}
