import 'package:equatable/equatable.dart';

import 'route_path.dart';

enum TurnType { left, right, straight, destination }

class TurnInstruction extends Equatable {
  const TurnInstruction({
    required this.type,
    required this.distanceM,
    required this.streetIndex,
    this.street,
  });

  final TurnType type;
  final double distanceM;

  /// Índice de la calle (la UI lo traduce al nombre).
  final int streetIndex;

  /// Nombre real de la calle (pasos de Google); si falta, la UI usa
  /// [streetIndex] con nombres de ejemplo.
  final String? street;

  @override
  List<Object?> get props => [type, distanceM, streetIndex, street];
}

/// Arma la instrucción actual y la siguiente a partir del producto cruz de
/// dos tramos seguidos.
abstract final class TurnInstructionBuilder {
  static const straightThreshold = 15.0;

  static TurnType typeFor(double angle) => angle.abs() < straightThreshold
      ? TurnType.straight
      : (angle > 0 ? TurnType.right : TurnType.left);

  /// Maniobra de Google → tipo de giro.
  static TurnType typeOf(String maneuver) {
    final m = maneuver.toUpperCase();
    if (m.contains('LEFT')) return TurnType.left;
    if (m.contains('RIGHT')) return TurnType.right;
    return TurnType.straight;
  }

  /// Índice del próximo paso real que empieza después de [traveled].
  static int _nextStep(RoutePath path, double traveled) {
    final starts = path.stepStarts;
    for (var i = 1; i < starts.length; i++) {
      if (starts[i] > traveled) return i;
    }
    return starts.length;
  }

  static TurnInstruction _fromStep(RoutePath path, int i, double traveled) {
    if (i >= path.steps.length) {
      return TurnInstruction(
        type: TurnType.destination,
        distanceM: (path.total - traveled).clamp(0, double.infinity),
        streetIndex: 0,
      );
    }
    final st = path.steps[i];
    return TurnInstruction(
      type: typeOf(st.maneuver),
      distanceM: (path.stepStarts[i] - traveled).clamp(0, double.infinity),
      streetIndex: i,
      street: st.street,
    );
  }

  /// Calle por la que va el auto (pasos reales); `null` sin pasos.
  static String? road(RoutePath path, double traveled) {
    if (path.steps.isEmpty) return null;
    final i = (_nextStep(path, traveled) - 1).clamp(0, path.steps.length - 1);
    return path.steps[i].street;
  }

  /// Instrucción para la próxima esquina (o el destino) desde [traveled].
  static TurnInstruction current(RoutePath path, double traveled) {
    if (path.steps.isNotEmpty) {
      return _fromStep(path, _nextStep(path, traveled), traveled);
    }
    final seg = path.segmentAt(traveled);
    final end = path.cumulative[seg + 1];
    if (seg >= path.segments - 1) {
      return TurnInstruction(
        type: TurnType.destination,
        distanceM: (path.total - traveled).clamp(0, double.infinity),
        streetIndex: seg,
      );
    }
    return TurnInstruction(
      type: typeFor(path.turnAngle(seg)),
      distanceM: end - traveled,
      streetIndex: seg + 1,
    );
  }

  /// La instrucción que sigue a [current]; `null` si ya es el destino.
  static TurnInstruction? next(RoutePath path, double traveled) {
    if (path.steps.isNotEmpty) {
      final i = _nextStep(path, traveled);
      if (i >= path.steps.length) return null;
      final n = _fromStep(path, i + 1, path.stepStarts[i]);
      return n.type == TurnType.destination
          ? TurnInstruction(
              type: TurnType.destination,
              distanceM: path.total - path.stepStarts[i],
              streetIndex: 0,
            )
          : n;
    }
    final seg = path.segmentAt(traveled);
    if (seg >= path.segments - 1) return null;
    final s2 = seg + 1;
    final len = path.cumulative[s2 + 1] - path.cumulative[s2];
    if (s2 >= path.segments - 1) {
      return TurnInstruction(
        type: TurnType.destination,
        distanceM: len,
        streetIndex: s2,
      );
    }
    return TurnInstruction(
      type: typeFor(path.turnAngle(s2)),
      distanceM: len,
      streetIndex: s2 + 1,
    );
  }

  /// 10 m por debajo de 1 km; 0.1 km desde ahí.
  static ({bool km, num value}) roundDistance(double m) {
    if (m < 1000)
      return (km: false, value: ((m / 10).round() * 10).clamp(0, 999));
    return (km: true, value: (m / 100).round() / 10);
  }
}
