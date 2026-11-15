import 'package:flutter_test/flutter_test.dart';
import 'package:tankeo/features/stations/data/road_route_repository.dart';

void main() {
  test('decodifica el polyline de Google (ejemplo oficial)', () {
    final pts = RoadRouteRepository.decodePolyline(
      '_p~iF~ps|U_ulLnnqC_mqNvxq`@',
    );
    expect(pts.length, 3);
    expect(pts[0].latitude, closeTo(38.5, 1e-5));
    expect(pts[0].longitude, closeTo(-120.2, 1e-5));
    expect(pts[2].latitude, closeTo(43.252, 1e-5));
    expect(pts[2].longitude, closeTo(-126.453, 1e-5));
  });

  test('interpreta la respuesta de Routes API', () {
    final r = RoadRouteRepository.parse(
      '{"routes":[{"distanceMeters":1946,"duration":"501s",'
      r'"polyline":{"encodedPolyline":"_p~iF~ps|U_ulLnnqC"}}]}',
    );
    expect(r!.distanceM, 1946);
    expect(r.minutes, 9);
    expect(r.points.length, 2);
    expect(RoadRouteRepository.parse('{}'), isNull);
  });
}
