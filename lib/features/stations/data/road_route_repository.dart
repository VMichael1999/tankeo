import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../domain/station.dart';
import '../../navigation/domain/route_path.dart';
import 'map_geo.dart';

/// Ruta por calles hasta un grifo (Routes API de Google).
class RoadRoute {
  const RoadRoute({
    required this.points,
    required this.distanceM,
    required this.minutes,
    this.steps = const [],
  });

  final List<LatLng> points;

  /// Pasos con maniobra y calle real.
  final List<RouteStep> steps;
  final double distanceM;
  final int minutes;
}

/// Pide a Google la ruta real en auto desde el auto hasta cada grifo y la
/// guarda. Mientras llega (o si falla) no inventa trazos: el mapa no dibuja
/// la ruta o, si la consulta falla, usa los tramos de ejemplo.
class RoadRouteRepository extends ChangeNotifier {
  RoadRouteRepository({this.apiKey, this.bundleId = 'pe.tankeo.tankeo'});

  final String? apiKey;
  final String bundleId;
  final Map<String, RoadRoute> _cache = {};
  final Map<String, Future<RoadRoute?>> _pending = {};
  final Set<String> _failed = {};

  static String _k(Station s) => '${s.name}|${s.position.dx.round()}';

  RoadRoute? cached(Station s) => _cache[_k(s)];

  bool hasFailed(Station s) => _failed.contains(_k(s));

  /// Puntos de la ruta lista para dibujar: la real, o los tramos de ejemplo
  /// si la consulta falló, o vacío mientras se espera.
  List<LatLng> pointsFor(Station s) =>
      cached(s)?.points ??
      (hasFailed(s) ? MapGeo.route(s.route) : const <LatLng>[]);

  Future<RoadRoute?> load(Station s) {
    final hit = _cache[_k(s)];
    if (hit != null) return Future.value(hit);
    return _pending[_k(s)] ??= _fetch(s)
        .whenComplete(() => _pending.remove(_k(s)));
  }

  Future<RoadRoute?> _fetch(Station s) async {
    final key = apiKey;
    if (key == null || key.isEmpty) {
      _failed.add(_k(s));
      notifyListeners();
      return null;
    }
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
    try {
      final dest = MapGeo.fromWorld(s.position);
      final req = await client.postUrl(
        Uri.parse('https://routes.googleapis.com/directions/v2:computeRoutes'),
      );
      req.headers
        ..set('Content-Type', 'application/json')
        ..set('X-Goog-Api-Key', key)
        ..set('X-Ios-Bundle-Identifier', bundleId)
        ..set(
          'X-Goog-FieldMask',
          'routes.distanceMeters,routes.duration,routes.polyline.encodedPolyline,'
              'routes.legs.steps.distanceMeters,routes.legs.steps.navigationInstruction',
        );
      req.write(
        jsonEncode({
          'origin': {
            'location': {
              'latLng': {
                'latitude': MapGeo.car.latitude,
                'longitude': MapGeo.car.longitude,
              },
            },
          },
          'destination': {
            'location': {
              'latLng': {
                'latitude': dest.latitude,
                'longitude': dest.longitude,
              },
            },
          },
          'travelMode': 'DRIVE',
          'languageCode': 'es',
        }),
      );
      final res = await req.close().timeout(const Duration(seconds: 10));
      final body = await res.transform(utf8.decoder).join();
      final route = parse(body);
      if (route == null) {
        _failed.add(_k(s));
      } else {
        _cache[_k(s)] = route;
      }
      notifyListeners();
      return route;
    } on Object {
      _failed.add(_k(s));
      notifyListeners();
      return null;
    } finally {
      client.close(force: true);
    }
  }

  /// Convierte la respuesta de Routes API; `null` si no trae ruta.
  @visibleForTesting
  static RoadRoute? parse(String body) {
    final json = jsonDecode(body) as Map<String, dynamic>;
    final routes = json['routes'] as List<dynamic>?;
    if (routes == null || routes.isEmpty) return null;
    final r = routes.first as Map<String, dynamic>;
    final encoded =
        (r['polyline'] as Map<String, dynamic>?)?['encodedPolyline'];
    if (encoded is! String) return null;
    final seconds = int.tryParse(
      ((r['duration'] as String?) ?? '0s').replaceAll('s', ''),
    );
    final steps = <RouteStep>[
      for (final leg in (r['legs'] as List<dynamic>? ?? const []))
        for (final st
            in ((leg as Map<String, dynamic>)['steps'] as List<dynamic>? ??
                const []))
          RouteStep(
            maneuver:
                ((st as Map<String, dynamic>)['navigationInstruction']
                        as Map<String, dynamic>?)?['maneuver']
                    as String? ??
                'STRAIGHT',
            street: RouteStep.streetFrom(
              ((st['navigationInstruction']
                          as Map<String, dynamic>?)?['instructions']
                      as String?) ??
                  '',
            ),
            distanceM: ((st['distanceMeters'] as num?) ?? 0).toDouble(),
          ),
    ];
    return RoadRoute(
      steps: steps,
      points: decodePolyline(encoded),
      distanceM: ((r['distanceMeters'] as num?) ?? 0).toDouble(),
      minutes: ((seconds ?? 0) / 60).ceil().clamp(1, 1 << 20),
    );
  }

  /// Decodifica el formato «encoded polyline» de Google (precisión 5).
  static List<LatLng> decodePolyline(String s) {
    final out = <LatLng>[];
    var i = 0, lat = 0, lng = 0;
    while (i < s.length) {
      int next() {
        var shift = 0, result = 0, b;
        do {
          b = s.codeUnitAt(i++) - 63;
          result |= (b & 0x1f) << shift;
          shift += 5;
        } while (b >= 0x20);
        return (result & 1) != 0 ? ~(result >> 1) : result >> 1;
      }

      lat += next();
      lng += next();
      out.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return out;
  }
}
