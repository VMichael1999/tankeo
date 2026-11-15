import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import '../../../core/domain/fuel_type.dart';
import '../domain/station.dart';
import 'map_geo.dart';
import 'station_repository.dart';

/// Grifos reales cerca del auto (Google Places, «Nearby Search»).
///
/// De Google salen el nombre, la dirección, la ubicación, la calificación y
/// el número de reseñas. Google no publica precios ni surtidores libres, así
/// que esos datos de ejemplo se generan de forma estable a partir del
/// identificador del lugar. Si la consulta falla, se usan los grifos de
/// ejemplo.
class PlacesStationRepository implements StationRepository {
  PlacesStationRepository({this.apiKey, StationRepository? fallback})
    : _fallback = fallback ?? const InMemoryStationRepository() {
    _stations = _fallback.getStations();
  }

  final String? apiKey;
  final StationRepository _fallback;
  late List<Station> _stations;
  bool loadedFromGoogle = false;

  @override
  List<Station> getStations() => _stations;

  /// Busca las gasolineras reales; deja los grifos de ejemplo si falla.
  Future<void> refresh({
    Duration timeout = const Duration(seconds: 6),
    int count = 6,
  }) async {
    final key = apiKey;
    if (key == null || key.isEmpty) return;
    final client = HttpClient()..connectionTimeout = timeout;
    try {
      final uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/place/nearbysearch/json',
        {
          'location': '${MapGeo.car.latitude},${MapGeo.car.longitude}',
          'radius': '3000',
          'type': 'gas_station',
          'language': 'es',
          'key': key,
        },
      );
      final req = await client.getUrl(uri);
      req.headers.set('X-Ios-Bundle-Identifier', 'pe.tankeo.tankeo');
      final res = await req.close().timeout(timeout);
      final body = await res.transform(utf8.decoder).join();
      final parsed = parse(body, count: count);
      if (parsed.length >= 3) {
        _stations = parsed;
        loadedFromGoogle = true;
      }
    } on Object {
      // Sin red o sin permiso: se quedan los grifos de ejemplo.
    } finally {
      client.close(force: true);
    }
  }

  /// Convierte la respuesta de Nearby Search en grifos, del más cercano al
  /// más lejano.
  static List<Station> parse(String body, {int count = 6}) {
    final json = jsonDecode(body) as Map<String, dynamic>;
    final results = (json['results'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>()
        .where((p) {
          final types = (p['types'] as List<dynamic>? ?? const [])
              .cast<String>();
          return types.contains('gas_station') &&
              !types.contains('car_wash') &&
              p['business_status'] != 'CLOSED_PERMANENTLY';
        })
        .toList();
    final out = <Station>[];
    for (final p in results) {
      if (out.length >= count) break;
      out.add(_station(p));
    }
    // Un grifo lleno para poder probar la cola.
    if (out.length >= 3) {
      final last = out.removeLast();
      out.add(last.withPumps(free: 0));
    }
    return out;
  }

  static Station _station(Map<String, dynamic> p) {
    final id = (p['place_id'] as String?) ?? (p['name'] as String);
    final h = _hash(id);
    final loc =
        (p['geometry'] as Map<String, dynamic>)['location']
            as Map<String, dynamic>;
    final lat = (loc['lat'] as num).toDouble();
    final lng = (loc['lng'] as num).toDouble();
    final world = MapGeo.toWorld(lat, lng);
    final km = _km(MapGeo.car.latitude, MapGeo.car.longitude, lat, lng) * 1.35;
    final vicinity = (p['vicinity'] as String?) ?? '';
    final parts = vicinity.split(',').map((e) => e.trim()).toList();
    final street = parts.first;
    final district = parts.length > 1 ? '${parts.last}, Lima' : 'Lima';
    final name = p['name'] as String;
    double price(double base, int span) =>
        ((base + (h % span) / 100) * 100).round() / 100;
    final gnv = price(1.55, 22);
    final regular = price(17.6, 220);
    return Station(
      name: name,
      company: name.toUpperCase(),
      ruc: '20${(100000000 + h % 899999999)}',
      address: street,
      district: district,
      prices: {
        FuelType.gnv: gnv,
        FuelType.regular: regular,
        FuelType.premium: price(regular + 3.4, 40),
        FuelType.diesel: price(regular + 4.4, 40),
      },
      freePumps: 1 + h % 5,
      totalPumps: 6 + h % 4,
      assignedPump: '${1 + h % 8} · Isla ${'ABCD'[h % 4]}',
      rating: ((p['rating'] as num?) ?? 4.0).toDouble(),
      reviewCount: (p['user_ratings_total'] as num?)?.toInt() ?? 0,
      driveMinutes: math.max(2, (km / 22 * 60).round()),
      distanceKm: (km * 10).round() / 10,
      position: world,
      route: [MapGeo.carWorld, Offset(MapGeo.carWorld.dx, world.dy), world],
      services: {
        StationService.store,
        if (h % 2 == 0) StationService.air,
        if (h % 3 == 0) StationService.wash,
        if (h % 4 != 1) StationService.atm,
      },
    );
  }

  static int _hash(String s) {
    var h = 17;
    for (final c in s.codeUnits) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    return h;
  }

  static double _km(double la1, double lo1, double la2, double lo2) {
    const r = 6371.0;
    double rad(double d) => d * math.pi / 180;
    final dLa = rad(la2 - la1), dLo = rad(lo2 - lo1);
    final a =
        math.pow(math.sin(dLa / 2), 2) +
        math.cos(rad(la1)) *
            math.cos(rad(la2)) *
            math.pow(math.sin(dLo / 2), 2);
    return 2 * r * math.asin(math.sqrt(a));
  }
}
