import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tankeo/features/navigation/domain/route_path.dart';
import 'package:tankeo/features/navigation/domain/turn_instruction.dart';
import 'package:tankeo/features/stations/data/road_route_repository.dart';

void main() {
  test('lee la calle del texto de Google', () {
    expect(
      RouteStep.streetFrom(
        'Dirígete hacia el nordeste en Av. Santo Toribio hacia Ca. Santo Toribio 0173',
      ),
      'Av. Santo Toribio',
    );
    expect(
      RouteStep.streetFrom('Continúa por Ca. las Palmeras'),
      'Ca. las Palmeras',
    );
    expect(
      RouteStep.streetFrom(
        'Gira a la derecha hacia Av. Jorge Basadre Grohmann',
      ),
      'Av. Jorge Basadre Grohmann',
    );
    expect(
      RouteStep.streetFrom(
        'Gira a la izquierda hacia Av. Arequipa\nPartes de esta carretera están cerradas',
      ),
      'Av. Arequipa',
    );
    expect(RouteStep.streetFrom('Llegaste'), isNull);
  });

  test('las maniobras de Google se vuelven giros', () {
    expect(TurnInstructionBuilder.typeOf('TURN_SLIGHT_LEFT'), TurnType.left);
    expect(TurnInstructionBuilder.typeOf('TURN_RIGHT'), TurnType.right);
    expect(TurnInstructionBuilder.typeOf('NAME_CHANGE'), TurnType.straight);
  });

  test('las instrucciones salen de los pasos reales', () {
    const a = LatLng(-12.0975, -77.0385);
    final b = LatLng(a.latitude + 300 / 111320, a.longitude);
    final path = RoutePath(
      [a, b],
      steps: const [
        RouteStep(
          maneuver: 'DEPART',
          street: 'Av. Santo Toribio',
          distanceM: 100,
        ),
        RouteStep(
          maneuver: 'TURN_RIGHT',
          street: 'Av. Arequipa',
          distanceM: 100,
        ),
        RouteStep(
          maneuver: 'TURN_LEFT',
          street: 'Ca. Los Pinos',
          distanceM: 100,
        ),
      ],
    );
    final i = TurnInstructionBuilder.current(path, 40);
    expect(i.type, TurnType.right);
    expect(i.street, 'Av. Arequipa');
    expect(i.distanceM, closeTo(60, 3));
    expect(TurnInstructionBuilder.road(path, 40), 'Av. Santo Toribio');
    final n = TurnInstructionBuilder.next(path, 40)!;
    expect(n.type, TurnType.left);
    expect(n.street, 'Ca. Los Pinos');
    // Último tramo: el destino, sin siguiente maniobra.
    expect(
      TurnInstructionBuilder.current(path, 250).type,
      TurnType.destination,
    );
    expect(TurnInstructionBuilder.next(path, 250), isNull);
    expect(TurnInstructionBuilder.road(path, 250), 'Ca. Los Pinos');
  });

  test('la respuesta de Routes API trae los pasos', () {
    final r = RoadRouteRepository.parse(
      '{"routes":[{"distanceMeters":300,"duration":"120s",'
      r'"polyline":{"encodedPolyline":"_p~iF~ps|U_ulLnnqC"},'
      '"legs":[{"steps":[{"distanceMeters":195,"navigationInstruction":'
      '{"maneuver":"DEPART","instructions":"Dirígete al norte en Av. Santo Toribio"}},'
      '{"distanceMeters":105,"navigationInstruction":'
      '{"maneuver":"TURN_LEFT","instructions":"Gira a la izquierda hacia Av. Arequipa"}}]}]}]}',
    )!;
    expect(r.steps.length, 2);
    expect(r.steps[1].maneuver, 'TURN_LEFT');
    expect(r.steps[1].street, 'Av. Arequipa');
  });
}
