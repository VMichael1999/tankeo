import 'dart:math' as math;
import 'dart:ui';

import '../domain/station.dart';

/// Posición del auto en el mapa del mundo.
const kCarPosition = Offset(300, 710);

/// Cámara del mapa: traslación + escala.
class MapCamera {
  const MapCamera({required this.tx, required this.ty, required this.zoom});

  final double tx;
  final double ty;
  final double zoom;

  static MapCamera lerp(MapCamera a, MapCamera b, double t) => MapCamera(
    tx: a.tx + (b.tx - a.tx) * t,
    ty: a.ty + (b.ty - a.ty) * t,
    zoom: a.zoom + (b.zoom - a.zoom) * t,
  );
}

/// Parámetros de encuadre de un mapa.
class MapFraming {
  const MapFraming({
    required this.width,
    required this.height,
    required this.centerX,
    required this.centerY,
    required this.maxZoom,
    this.minZoom = .62,
    this.includeRoute = false,
  });

  final double width;
  final double height;
  final double centerX;
  final double centerY;
  final double maxZoom;
  final double minZoom;
  final bool includeRoute;

  /// Mapa principal de «Grifos cercanos».
  static const main = MapFraming(
    width: 400,
    height: 380,
    centerX: 220,
    centerY: 420,
    maxZoom: 1.35,
  );

  /// Mapa fijo del detalle del grifo.
  static const detail = MapFraming(
    width: 400,
    height: 150,
    centerX: 220,
    centerY: 178,
    maxZoom: 1.1,
    minZoom: .36,
    includeRoute: true,
  );
}

/// Calcula la ruta de un grifo y el encuadre del mapa para verla completa.
class RouteService {
  const RouteService();

  List<Offset> routeFor(Station station) => station.route;

  MapCamera frame(Station station, MapFraming f) {
    final pts = <Offset>[kCarPosition, station.position];
    if (f.includeRoute) pts.addAll(station.route);
    final minX = pts.map((p) => p.dx).reduce(math.min);
    final maxX = pts.map((p) => p.dx).reduce(math.max);
    final minY = pts.map((p) => p.dy).reduce(math.min) - 60;
    final maxY = pts.map((p) => p.dy).reduce(math.max) + 20;
    final z = math.max(
      f.minZoom,
      math.min(
        f.maxZoom,
        math.min(
          f.width / math.max(1, maxX - minX + 120),
          f.height / math.max(1, maxY - minY + 60),
        ),
      ),
    );
    return MapCamera(
      tx: f.centerX - (minX + maxX) / 2 * z,
      ty: f.centerY - (minY + maxY) / 2 * z,
      zoom: z,
    );
  }
}
