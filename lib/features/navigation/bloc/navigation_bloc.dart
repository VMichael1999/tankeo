import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/toast/toast_service.dart';
import '../../../core/utils/clock.dart';
import '../../stations/data/map_geo.dart';
import '../../stations/domain/station.dart';
import '../../stations/data/road_route_repository.dart';
import '../data/route_simulator.dart';
import '../domain/route_path.dart';
import '../domain/turn_instruction.dart';

enum ViewMode { auto, forced2D, forced3D }

enum NavEffectKind { exit, continueToFuel }

class NavEffect extends Equatable {
  const NavEffect(this.kind, this.nonce);
  final NavEffectKind kind;
  final int nonce;
  @override
  List<Object?> get props => [kind, nonce];
}

sealed class NavigationState extends Equatable {
  const NavigationState({
    required this.station,
    required this.path,
    this.effect,
  });

  final Station station;
  final RoutePath path;
  final NavEffect? effect;
}

/// Vista general de la ruta (1.5 s, norte arriba).
class NavOverview extends NavigationState {
  const NavOverview({
    required super.station,
    required super.path,
    super.effect,
  });

  @override
  List<Object?> get props => [station, effect];
}

class NavDriving extends NavigationState {
  const NavDriving({
    required super.station,
    required super.path,
    required this.traveled,
    required this.speedKmh,
    required this.etaMinutes,
    required this.arrivalTime,
    required this.instruction,
    required this.nextInstruction,
    required this.viewMode,
    required this.is3D,
    this.followPaused = false,
    super.effect,
  });

  final double traveled;
  final double speedKmh;
  final int etaMinutes;
  final DateTime arrivalTime;
  final TurnInstruction instruction;
  final TurnInstruction? nextInstruction;
  final ViewMode viewMode;
  final bool is3D;

  /// El usuario movió el mapa: la cámara deja de seguir al auto hasta
  /// «Recentrar».
  final bool followPaused;

  LatLng get position => path.positionAt(traveled);
  double get heading => path.headingAt(traveled);
  double get remaining => path.total - traveled;

  NavDriving copyWith({
    ViewMode? viewMode,
    bool? is3D,
    bool? followPaused,
    NavEffect? effect,
  }) => NavDriving(
    station: station,
    path: path,
    traveled: traveled,
    speedKmh: speedKmh,
    etaMinutes: etaMinutes,
    arrivalTime: arrivalTime,
    instruction: instruction,
    nextInstruction: nextInstruction,
    viewMode: viewMode ?? this.viewMode,
    is3D: is3D ?? this.is3D,
    followPaused: followPaused ?? this.followPaused,
    effect: effect ?? this.effect,
  );

  @override
  List<Object?> get props => [
    station,
    traveled,
    speedKmh,
    etaMinutes,
    instruction,
    nextInstruction,
    viewMode,
    is3D,
    followPaused,
    effect,
  ];
}

class NavArrived extends NavigationState {
  const NavArrived({
    required super.station,
    required super.path,
    required this.heading,
    required this.arrivedAt,
    super.effect,
  });

  final double heading;

  /// Hora de llegada (para «Llegada» en la hoja).
  final DateTime arrivedAt;

  LatLng get position => path.points.last;

  @override
  List<Object?> get props => [station, heading, effect];
}

sealed class NavigationEvent extends Equatable {
  const NavigationEvent();
  @override
  List<Object?> get props => [];
}

class NavigationStarted extends NavigationEvent {
  const NavigationStarted(this.station);
  final Station station;
  @override
  List<Object?> get props => [station];
}

class OverviewFinished extends NavigationEvent {
  const OverviewFinished();
}

class PositionTicked extends NavigationEvent {
  const PositionTicked(this.traveled);
  final double traveled;
  @override
  List<Object?> get props => [traveled];
}

class ViewToggled extends NavigationEvent {
  const ViewToggled();
}

/// El usuario arrastró o hizo zoom en el mapa.
class MapMovedByUser extends NavigationEvent {
  const MapMovedByUser();
}

class RecenterPressed extends NavigationEvent {
  const RecenterPressed();
}

class ExitPressed extends NavigationEvent {
  const ExitPressed();
}

class ContinueToFuelPressed extends NavigationEvent {
  const ContinueToFuelPressed();
}

class NavEffectHandled extends NavigationEvent {
  const NavEffectHandled();
}

/// Modo en marcha hacia el grifo: vista general → conducción → llegada.
class NavigationBloc extends Bloc<NavigationEvent, NavigationState?> {
  NavigationBloc({
    required Clock clock,
    required ToastService toast,
    RouteSimulator Function(RoutePath path)? simulatorFor,
    Future<RoadRoute?> Function(Station station)? roadRoute,
    this.overviewDelay = const Duration(milliseconds: 1500),
  }) : _clock = clock,
       _toast = toast,
       _simulatorFor = simulatorFor ?? RouteSimulator.new,
       _roadRoute = roadRoute,
       super(null) {
    on<NavigationStarted>(_onStarted);
    on<OverviewFinished>(_onOverviewDone);
    on<PositionTicked>(_onTick);
    on<ViewToggled>(_onToggle);
    on<RecenterPressed>(_onRecenter);
    on<MapMovedByUser>((e, emit) {
      final s = state;
      if (s is NavDriving && !s.followPaused) {
        emit(s.copyWith(followPaused: true));
      }
    });
    on<ExitPressed>(_onExit);
    on<ContinueToFuelPressed>(_onContinue);
    on<NavEffectHandled>((e, emit) => _clearEffect(emit));
  }

  /// Un metro del recorrido equivale a 1/4.4 unidades del mapa de diseño.
  static const metersPerUnit = 4.4;

  final Clock _clock;
  final ToastService _toast;
  final RouteSimulator Function(RoutePath) _simulatorFor;
  final Future<RoadRoute?> Function(Station)? _roadRoute;
  final Duration overviewDelay;
  Timer? _overview;
  StreamSubscription<double>? _sim;
  bool _notified3d = false;
  int _nonce = 0;

  /// Pasa a 3D cuando falta menos de max(230 unidades, 34 % de la ruta).
  static bool shouldAuto3D(double remainingM, double totalM) {
    final remaining = remainingM / metersPerUnit;
    final total = totalM / metersPerUnit;
    return remaining < (230 > total * .34 ? 230 : total * .34);
  }

  Future<void> _onStarted(
    NavigationStarted e,
    Emitter<NavigationState?> emit,
  ) async {
    _stop();
    _notified3d = false;
    // Ruta real por calles; si no hay, los tramos de ejemplo del grifo.
    final road = await _roadRoute?.call(e.station);
    if (isClosed) return;
    final path = road == null
        ? RoutePath(MapGeo.route(e.station.route))
        : RoutePath(road.points, minutes: road.minutes, steps: road.steps);
    emit(NavOverview(station: e.station, path: path));
    _overview = Timer(overviewDelay, () => add(const OverviewFinished()));
  }

  void _onOverviewDone(OverviewFinished e, Emitter<NavigationState?> emit) {
    final s = state;
    if (s is! NavOverview) return;
    emit(_driving(s.station, s.path, 0, ViewMode.auto));
    _sim = _simulatorFor(s.path).run().listen((d) => add(PositionTicked(d)));
  }

  NavDriving _driving(
    Station st,
    RoutePath path,
    double traveled,
    ViewMode mode, {
    NavEffect? effect,
    bool followPaused = false,
  }) {
    final remaining = path.total - traveled;
    final eta = ((path.minutes ?? st.driveMinutes) * remaining / path.total)
        .ceil()
        .clamp(0, 1 << 20);
    final auto3d = shouldAuto3D(remaining, path.total);
    return NavDriving(
      station: st,
      path: path,
      traveled: traveled,
      speedKmh: RouteSimulator.speedFor(path.corners, traveled).roundToDouble(),
      etaMinutes: eta,
      arrivalTime: _clock.now().add(Duration(minutes: eta)),
      instruction: TurnInstructionBuilder.current(path, traveled),
      nextInstruction: TurnInstructionBuilder.next(path, traveled),
      viewMode: mode,
      is3D: switch (mode) {
        ViewMode.auto => auto3d,
        ViewMode.forced2D => false,
        ViewMode.forced3D => true,
      },
      followPaused: followPaused,
      effect: effect,
    );
  }

  void _onTick(PositionTicked e, Emitter<NavigationState?> emit) {
    final s = state;
    if (s is! NavDriving) return;
    if (e.traveled >= s.path.total - 0.5) {
      _stop();
      emit(
        NavArrived(
          station: s.station,
          path: s.path,
          heading: s.path.headingOfSegment(s.path.segments - 1),
          arrivedAt: _clock.now(),
        ),
      );
      return;
    }
    final next = _driving(
      s.station,
      s.path,
      e.traveled,
      s.viewMode,
      followPaused: s.followPaused,
    );
    if (s.viewMode == ViewMode.auto && next.is3D && !s.is3D && !_notified3d) {
      _notified3d = true;
      _toast.show(AppToast.near3d);
    }
    emit(next);
  }

  void _onToggle(ViewToggled e, Emitter<NavigationState?> emit) {
    final s = state;
    if (s is! NavDriving) return;
    emit(
      s.copyWith(
        viewMode: s.is3D ? ViewMode.forced2D : ViewMode.forced3D,
        is3D: !s.is3D,
      ),
    );
  }

  void _onRecenter(RecenterPressed e, Emitter<NavigationState?> emit) {
    final s = state;
    if (s is! NavDriving) return;
    emit(
      _driving(s.station, s.path, s.traveled, ViewMode.auto, effect: s.effect),
    );
  }

  void _onExit(ExitPressed e, Emitter<NavigationState?> emit) {
    _stop();
    _emitEffect(emit, NavEffectKind.exit);
  }

  void _onContinue(ContinueToFuelPressed e, Emitter<NavigationState?> emit) =>
      _emitEffect(emit, NavEffectKind.continueToFuel);

  void _emitEffect(Emitter<NavigationState?> emit, NavEffectKind k) {
    final s = state;
    final fx = NavEffect(k, ++_nonce);
    switch (s) {
      case NavOverview():
        emit(NavOverview(station: s.station, path: s.path, effect: fx));
      case NavDriving():
        emit(s.copyWith(effect: fx));
      case NavArrived():
        emit(
          NavArrived(
            station: s.station,
            path: s.path,
            heading: s.heading,
            arrivedAt: s.arrivedAt,
            effect: fx,
          ),
        );
      case null:
        break;
    }
  }

  void _clearEffect(Emitter<NavigationState?> emit) {
    final s = state;
    switch (s) {
      case NavOverview():
        emit(NavOverview(station: s.station, path: s.path));
      case NavDriving():
        emit(
          NavDriving(
            station: s.station,
            path: s.path,
            traveled: s.traveled,
            speedKmh: s.speedKmh,
            etaMinutes: s.etaMinutes,
            arrivalTime: s.arrivalTime,
            instruction: s.instruction,
            nextInstruction: s.nextInstruction,
            viewMode: s.viewMode,
            is3D: s.is3D,
            followPaused: s.followPaused,
          ),
        );
      case NavArrived():
        emit(
          NavArrived(
            station: s.station,
            path: s.path,
            heading: s.heading,
            arrivedAt: s.arrivedAt,
          ),
        );
      case null:
        break;
    }
  }

  void _stop() {
    _overview?.cancel();
    _sim?.cancel();
    _sim = null;
  }

  @override
  Future<void> close() {
    _stop();
    return super.close();
  }
}
