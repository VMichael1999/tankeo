import 'package:flutter_test/flutter_test.dart';

import 'dart:ui' show Offset;

import 'package:tankeo/features/stations/data/map_geo.dart';
import 'package:tankeo/features/stations/data/places_station_repository.dart';

const _body = '''
{"status":"OK","results":[
 {"name":"PRIMAX Avenida Arequipa GNV","vicinity":"Avenida Arequipa 3325, San Isidro","rating":4.1,"user_ratings_total":595,"place_id":"a","types":["gas_station","point_of_interest"],"geometry":{"location":{"lat":-12.0990,"lng":-77.0360}}},
 {"name":"Repsol","vicinity":"Avenida Paseo Parodi 220, San Isidro","rating":4.1,"user_ratings_total":1037,"place_id":"b","types":["gas_station"],"geometry":{"location":{"lat":-12.0940,"lng":-77.0310}}},
 {"name":"Petroperú","vicinity":"Avenida Arenales 1700, Lince","rating":4.2,"user_ratings_total":227,"place_id":"c","types":["gas_station"],"geometry":{"location":{"lat":-12.0850,"lng":-77.0330}}},
 {"name":"Car Wash","vicinity":"x","place_id":"d","types":["gas_station","car_wash"],"geometry":{"location":{"lat":-12.09,"lng":-77.03}}},
 {"name":"Cerrado","vicinity":"x","place_id":"e","business_status":"CLOSED_PERMANENTLY","types":["gas_station"],"geometry":{"location":{"lat":-12.09,"lng":-77.03}}}
]}''';

void main() {
  test('Places: toma gasolineras reales con sus datos y deja una llena', () {
    final s = PlacesStationRepository.parse(_body);
    expect(s.length, 3);
    expect(s.first.name, 'PRIMAX Avenida Arequipa GNV');
    expect(s.first.address, 'Avenida Arequipa 3325');
    expect(s.first.district, 'San Isidro, Lima');
    expect(s.first.rating, 4.1);
    expect(s.first.reviewCount, 595);
    expect(s.last.freePumps, 0);
    expect(s.first.distanceKm, greaterThan(0));
    // Los precios de ejemplo son estables entre llamadas.
    expect(PlacesStationRepository.parse(_body).first.prices, s.first.prices);
  });

  test('MapGeo.toWorld es el inverso de fromWorld', () {
    final p = MapGeo.fromWorld(const Offset(430, 450));
    final w = MapGeo.toWorld(p.latitude, p.longitude);
    expect(w.dx, closeTo(430, .01));
    expect(w.dy, closeTo(450, .01));
  });
}
