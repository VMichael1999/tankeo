import 'dart:ui';

import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Convierte las coordenadas del mapa de diseño (900 × 1400, auto en 300,710)
/// a latitud y longitud reales de Lima (San Isidro / Miraflores).
abstract final class MapGeo {
  static const carWorld = Offset(300, 710);
  static const car = LatLng(-12.0975, -77.0385);

  /// Grados por unidad del mapa de diseño (~4.4 m).
  static const _deg = 0.00004;

  static LatLng fromWorld(Offset p) => LatLng(
    car.latitude - (p.dy - carWorld.dy) * _deg,
    car.longitude + (p.dx - carWorld.dx) * _deg,
  );

  /// Inverso de [fromWorld].
  static Offset toWorld(double lat, double lng) => Offset(
    carWorld.dx + (lng - car.longitude) / _deg,
    carWorld.dy - (lat - car.latitude) / _deg,
  );

  static List<LatLng> route(List<Offset> pts) => pts.map(fromWorld).toList();

  static LatLngBounds boundsOf(Iterable<LatLng> pts) {
    var s = 90.0, n = -90.0, w = 180.0, e = -180.0;
    for (final p in pts) {
      if (p.latitude < s) s = p.latitude;
      if (p.latitude > n) n = p.latitude;
      if (p.longitude < w) w = p.longitude;
      if (p.longitude > e) e = p.longitude;
    }
    return LatLngBounds(southwest: LatLng(s, w), northeast: LatLng(n, e));
  }
}
