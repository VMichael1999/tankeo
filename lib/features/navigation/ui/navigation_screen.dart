import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import '../../../core/icons/icons.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/account_widgets.dart';
import '../../../core/widgets/fuel_price_list.dart';
import '../../../core/widgets/car_3d.dart';
import '../../../core/widgets/drop_shadow_image.dart';
import '../../../core/widgets/map_style.dart';
import '../../stations/bloc/stations_bloc.dart';
import '../../stations/data/map_geo.dart';
import '../../../core/domain/fuel_type.dart';
import '../../../core/l10n/fuel_l10n.dart';
import '../../../core/utils/money.dart';
import '../bloc/navigation_bloc.dart';
import 'arrival_widgets.dart';
import 'nav_widgets.dart';
import '../domain/turn_instruction.dart';

/// Navegación hacia el grifo: vista general, conducción 2D/3D y llegada.
class NavigationScreen extends StatelessWidget {
  const NavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<NavigationBloc, NavigationState?>(
      listenWhen: (a, b) => b?.effect != null && a?.effect != b?.effect,
      listener: (context, s) {
        final kind = s!.effect!.kind;
        context.read<NavigationBloc>().add(const NavEffectHandled());
        switch (kind) {
          case NavEffectKind.exit:
            goBack(context, '/details');
          case NavEffectKind.continueToFuel:
            context.read<StationsBloc>().add(
              GoToFuel(context.read<StationsBloc>().state.selectedIndex),
            );
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: const Scaffold(
          backgroundColor: AppColors.mapBase,
          body: _NavBody(),
        ),
      ),
    );
  }
}

class _NavBody extends StatefulWidget {
  const _NavBody();

  @override
  State<_NavBody> createState() => _NavBodyState();
}

class _NavBodyState extends State<_NavBody> {
  GoogleMapController? _map;
  BitmapDescriptor? _car;
  BitmapDescriptor? _dest;

  // Cámara suavizada: 1 − e^(−dt·k).
  double _bearing = 0;
  double _zoom = 16;
  double _tilt = 0;
  LatLng _target = MapGeo.car;
  bool _overviewDone = false;

  // Auto 3D superpuesto: posición en pantalla del auto y giro en curvas.
  final _yaw = ValueNotifier<double>(0);
  bool _modelReady = false;
  Offset? _carPos;
  Offset? _destPos;
  Offset? _downAt;
  bool _syncing = false;
  bool _settled = true; // falso mientras la cámara anima la llegada
  static const _carBox = Size(104, 130);
  static const _dt = .05;

  @override
  void initState() {
    super.initState();
    _loadIcons();
  }

  Future<void> _loadIcons() async {
    final data = await rootBundle.load(AppImages.carTopVertical);
    final dest = await _destBitmap();
    if (!mounted) return;
    setState(() {
      _car = BitmapDescriptor.bytes(data.buffer.asUint8List(), width: 30);
      _dest = dest;
    });
  }

  /// Poste del destino con el círculo naranja del surtidor.
  Future<BitmapDescriptor> _destBitmap() async {
    const s = 3.0;
    final rec = ui.PictureRecorder();
    final c = Canvas(rec)..scale(s);
    final pole = Paint()..color = AppColors.pumpPole;
    c.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(19, 28, 4, 22),
        const Radius.circular(2),
      ),
      pole,
    );
    c.drawCircle(const Offset(21, 20), 19, Paint()..color = AppColors.white);
    c.drawCircle(const Offset(21, 20), 15, Paint()..color = AppColors.primary);
    final body = Paint()..color = AppColors.white;
    c.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(15, 12, 9, 15),
        const Radius.circular(2),
      ),
      body,
    );
    c.drawRect(
      const Rect.fromLTWH(17, 14, 5, 4),
      Paint()..color = AppColors.primary,
    );
    final img = await rec.endRecording().toImage(
      (42 * s).ceil(),
      (52 * s).ceil(),
    );
    final bytes = (await img.toByteData(format: ui.ImageByteFormat.png))!.buffer
        .asUint8List();
    return BitmapDescriptor.bytes(bytes, width: 42, height: 52);
  }

  double _shortest(double from, double to) {
    var d = (to - from) % 360;
    if (d > 180) d -= 360;
    if (d < -180) d += 360;
    return d;
  }

  double _k(double k) => 1 - math.exp(-_dt * k);

  void _drive(NavDriving s) {
    final m = _map;
    if (m == null) return;
    final targetZoom = s.is3D ? 17.8 : 17.3;
    final targetTilt = s.is3D ? 52.0 : 0.0;
    _bearing =
        (_bearing + _shortest(_bearing, s.heading) * _k(3.4) + 360) % 360;
    _zoom += (targetZoom - _zoom) * _k(3.4);
    _tilt += (targetTilt - _tilt) * _k(3.4);
    // El auto queda en la parte baja: la cámara mira un poco por delante.
    final mPerPx =
        156543.03 *
        math.cos(s.position.latitude * math.pi / 180) /
        math.pow(2, _zoom);
    final ahead = (s.is3D ? 172 : 122) * mPerPx;
    final rad = _bearing * math.pi / 180;
    final goal = LatLng(
      s.position.latitude + ahead * math.cos(rad) / 111320,
      s.position.longitude +
          ahead *
              math.sin(rad) /
              (111320 * math.cos(s.position.latitude * math.pi / 180)),
    );
    _target = LatLng(
      _target.latitude + (goal.latitude - _target.latitude) * _k(9),
      _target.longitude + (goal.longitude - _target.longitude) * _k(9),
    );
    // En el visor, yaw positivo gira a la izquierda: se invierte.
    _yaw.value = -_shortest(_bearing, s.heading).clamp(-35.0, 35.0);
    if (s.followPaused) {
      _syncCarPos(s.position);
      return;
    }
    m.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _target,
          zoom: _zoom,
          bearing: _bearing,
          tilt: _tilt,
        ),
      ),
    );
    _syncCarPos(s.position);
  }

  Future<Offset?> _screenOf(LatLng p) async {
    final m = _map;
    if (m == null) return null;
    final c = await m.getScreenCoordinate(p);
    if (!mounted) return null;
    final dpr = Platform.isAndroid
        ? MediaQuery.devicePixelRatioOf(context)
        : 1.0;
    return Offset(c.x / dpr, c.y / dpr);
  }

  /// Alto aproximado del banner de maniobra (para ubicar los controles).
  static const _bannerH = 128.0;

  String _road(BuildContext context, NavigationState s) {
    final traveled = s is NavDriving ? s.traveled : 0.0;
    if (s.path.steps.isNotEmpty) {
      return TurnInstructionBuilder.road(s.path, traveled) ?? '';
    }
    return _street(context, s.path.segmentAt(traveled));
  }

  /// Velocidad máxima de la vía actual (50 en avenidas, 40 en calles).
  int? _speedLimit(BuildContext context, NavigationState s) {
    final road = _road(context, s);
    if (road.isEmpty) return null;
    return road.startsWith('Av.') ? 50 : 40;
  }

  NavBannerData _bannerData(BuildContext context, NavigationState s) {
    final l = context.l10n;
    final traveled = s is NavDriving ? s.traveled : 0.0;
    final i = s is NavDriving
        ? s.instruction
        : TurnInstructionBuilder.current(s.path, traveled);
    final n = s is NavDriving
        ? s.nextInstruction
        : TurnInstructionBuilder.next(s.path, traveled);
    // Con pasos reales nunca se inventa una calle: si Google no la da, el
    // texto va sin nombre.
    final real = s.path.steps.isNotEmpty;
    String? streetOf(TurnInstruction t) =>
        t.street ?? (real ? null : _street(context, t.streetIndex));
    final street = streetOf(i);
    final nextStreet = n == null
        ? null
        : n.type == TurnType.destination
        ? s.station.name
        : streetOf(n);
    return NavBannerData(
      overview: s is NavOverview,
      type: i.type,
      distanceM: i.distanceM,
      road: _road(context, s),
      turnText: switch (i.type) {
        TurnType.left =>
          street == null ? l.navLeftPlain : l.navTurnLeftOn(street),
        TurnType.right =>
          street == null ? l.navRightPlain : l.navTurnRightOn(street),
        TurnType.straight =>
          street == null ? l.navStraightPlain : l.navStraight(street),
        TurnType.destination => l.navDestination(s.station.name),
      },
      nextType: n?.type,
      nextLabel: switch (n?.type) {
        TurnType.left =>
          nextStreet == null ? l.navNextLeftPlain : l.navNextLeft,
        TurnType.right =>
          nextStreet == null ? l.navNextRightPlain : l.navNextRight,
        TurnType.straight =>
          nextStreet == null ? l.navNextStraightPlain : l.navNextStraight,
        TurnType.destination => l.navNextDestination,
        null => null,
      },
      nextStreet: nextStreet,
    );
  }

  FuelType _fuel(BuildContext context) {
    final f = context.read<StationsBloc>().state.filter;
    return f == FuelType.diesel ? FuelType.regular : f;
  }

  NavCardData _cardData(BuildContext context, NavigationState s) {
    final l = context.l10n;
    final st = s.station;
    final fuel = _fuel(context);
    return NavCardData(
      minutes: s is NavDriving
          ? s.etaMinutes
          : (s.path.minutes ?? st.driveMinutes),
      distance: formatNavDistance(
        context,
        s is NavDriving ? s.remaining : s.path.total,
      ),
      arrival: s is NavDriving
          ? DateFormat('h:mm a', 'es').format(s.arrivalTime)
          : null,
      progress: s is NavDriving && s.path.total > 0
          ? s.traveled / s.path.total
          : 0,
      stationName: st.name,
      pumpLine:
          '${l.navPumpChip(st.assignedPumpNumber)} · ${l.navIsleChip(st.assignedPump.split('Isla ').last)}',
      fuelLabel: fuel.label(context),
      price: Money.format(st.priceOf(fuel)),
    );
  }

  /// Detalle del grifo en una hoja, sin salir de la navegación.
  void _openStation(BuildContext context, NavigationState s) {
    final st = s.station;
    final fuel = _fuel(context);
    showAppSheet<void>(
      context,
      builder: (c) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(st.name, style: AppText.ui(22, AppText.w8)),
          const SizedBox(height: 2),
          Text(
            '${st.address} · ${st.district}',
            style: AppText.ui(13.5, AppText.w5, color: AppColors.ink2),
          ),
          const SizedBox(height: 16),
          FuelPriceList(
            prices: st.prices,
            selected: fuel,
            cheapestFuels: const {},
          ),
        ],
      ),
    );
  }

  /// Datos del banner y la hoja de llegada.
  ArrivalInfo _arrivalInfo(BuildContext context, NavArrived s) {
    final st = s.station;
    final filter = context.read<StationsBloc>().state.filter;
    final fuel = filter == FuelType.diesel ? FuelType.regular : filter;
    return ArrivalInfo(
      stationName: st.name,
      address: st.address,
      island: st.assignedPump.split('Isla ').last,
      pump: int.tryParse(st.assignedPumpNumber) ?? 1,
      rightSide: _pumpOnRight(s),
      distance: formatNavDistance(context, s.path.total),
      minutes: s.path.minutes ?? st.driveMinutes,
      arrivalTime: DateFormat('h:mm a', 'es').format(s.arrivedAt),
      fuelLabel: fuel.label(context),
      price: Money.format(st.priceOf(fuel)),
      pumpFree: st.hasFreePumps,
    );
  }

  /// El grifo queda a la derecha si está a la derecha del último tramo
  /// (producto cruz con y hacia abajo).
  bool _pumpOnRight(NavArrived s) {
    final pts = s.path.points;
    if (pts.length < 2) return true;
    final a = pts[pts.length - 2], b = pts.last;
    final g = MapGeo.fromWorld(s.station.position);
    final cos = math.cos(b.latitude * math.pi / 180);
    final e1 = (b.longitude - a.longitude) * cos,
        s1 = -(b.latitude - a.latitude);
    final e2 = (g.longitude - b.longitude) * cos,
        s2 = -(g.latitude - b.latitude);
    final cross = e1 * s2 - s1 * e2;
    return cross.abs() < 1e-12 || cross > 0;
  }

  /// Dónde cae el auto en la pantalla con la cámara actual.
  Future<void> _syncCarPos(LatLng p) async {
    final m = _map;
    if (m == null || _syncing) return;
    _syncing = true;
    try {
      final c = await m.getScreenCoordinate(p);
      if (!mounted) return;
      final dpr = Platform.isAndroid
          ? MediaQuery.devicePixelRatioOf(context)
          : 1.0;
      setState(() => _carPos = Offset(c.x / dpr, c.y / dpr));
    } finally {
      _syncing = false;
    }
  }

  void _onState(NavigationState? s) {
    final m = _map;
    if (m == null || s == null) return;
    switch (s) {
      case NavOverview():
        m.animateCamera(
          CameraUpdate.newLatLngBounds(MapGeo.boundsOf(s.path.points), 90),
        );
      case NavDriving():
        if (!_overviewDone) {
          _overviewDone = true;
          _target = s.position;
          _bearing = s.heading;
        }
        _drive(s);
      case NavArrived():
        _yaw.value = 0;
        m
            .animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: s.position,
                  zoom: 18.2,
                  bearing: s.heading,
                  tilt: 52,
                ),
              ),
            )
            .then((_) async {
              await Future<void>.delayed(const Duration(milliseconds: 900));
              await _syncCarPos(s.position);
              final d = await _screenOf(s.path.points.last);
              if (mounted) {
                setState(() {
                  _destPos = d;
                  _settled = true;
                });
              }
            });
        if (_settled) setState(() => _settled = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NavigationBloc, NavigationState?>(
      listener: (context, s) => _onState(s),
      builder: (context, s) {
        if (s == null) return const SizedBox.shrink();
        final driving = s is NavDriving;
        final arrived = s is NavArrived;
        final show3D =
            _modelReady &&
            _carPos != null &&
            ((driving && s.is3D) || (arrived && _settled));
        final pos = switch (s) {
          NavDriving() => s.position,
          NavArrived() => s.position,
          NavOverview() => s.path.points.first,
        };
        final heading = switch (s) {
          NavDriving() => s.heading,
          NavArrived() => s.heading,
          NavOverview() => s.path.headingOfSegment(0),
        };
        final done = switch (s) {
          NavDriving() =>
            s.path.points.take(s.path.segmentAt(s.traveled) + 1).toList()
              ..add(s.position),
          NavArrived() => s.path.points,
          NavOverview() => <LatLng>[],
        };
        final rest = switch (s) {
          NavDriving() => [
            s.position,
            ...s.path.points.skip(s.path.segmentAt(s.traveled) + 1),
          ],
          NavArrived() => <LatLng>[],
          NavOverview() => s.path.points,
        };
        return Stack(
          children: [
            Positioned.fill(
              child: Listener(
                onPointerDown: (e) => _downAt = e.position,
                onPointerMove: (e) {
                  final d = _downAt;
                  if (driving &&
                      d != null &&
                      (e.position - d).distance > 12 &&
                      !s.followPaused) {
                    _downAt = null;
                    context.read<NavigationBloc>().add(const MapMovedByUser());
                  }
                },
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: MapGeo.car,
                    zoom: 15.5,
                  ),
                  style: kLightMapStyle,
                  buildingsEnabled: driving && s.is3D || arrived,
                  zoomControlsEnabled: false,
                  zoomGesturesEnabled: driving,
                  scrollGesturesEnabled: driving,
                  rotateGesturesEnabled: false,
                  tiltGesturesEnabled: false,
                  myLocationButtonEnabled: false,
                  compassEnabled: false,
                  mapToolbarEnabled: false,
                  markers: {
                    if (_car != null)
                      Marker(
                        markerId: const MarkerId('car'),
                        position: pos,
                        icon: _car!,
                        rotation: heading,
                        flat: true,
                        alpha: show3D ? 0 : 1,
                        anchor: const Offset(.5, .5),
                        zIndexInt: 3,
                      ),
                    if (_dest != null)
                      Marker(
                        markerId: const MarkerId('dest'),
                        position: s.path.points.last,
                        icon: _dest!,
                        anchor: const Offset(.5, 1),
                        zIndexInt: 2,
                      ),
                  },
                  polylines: {
                    if (done.length > 1)
                      Polyline(
                        polylineId: const PolylineId('done'),
                        points: done,
                        color: AppColors.routeDone,
                        width: 6,
                        zIndex: 1,
                        jointType: JointType.round,
                      ),
                    if (rest.length > 1) ...[
                      Polyline(
                        polylineId: const PolylineId('casing'),
                        points: rest,
                        color: AppColors.white,
                        width: 12,
                        zIndex: 2,
                        jointType: JointType.round,
                        startCap: Cap.roundCap,
                        endCap: Cap.roundCap,
                      ),
                      Polyline(
                        polylineId: const PolylineId('rest'),
                        points: rest,
                        color: AppColors.primary,
                        width: 7,
                        zIndex: 3,
                        jointType: JointType.round,
                        startCap: Cap.roundCap,
                        endCap: Cap.roundCap,
                      ),
                    ],
                  },
                  onMapCreated: (c) {
                    _map = c;
                    _onState(s);
                  },
                ),
              ),
            ),
            Positioned(
              left: (_carPos ?? const Offset(200, 300)).dx - _carBox.width / 2,
              top: (_carPos ?? const Offset(200, 300)).dy - _carBox.height / 2,
              width: _carBox.width,
              height: _carBox.height,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: show3D ? 1 : 0,
                  duration: const Duration(milliseconds: 350),
                  child: Car3D(
                    yaw: _yaw,
                    onReady: () {
                      if (mounted) setState(() => _modelReady = true);
                    },
                  ),
                ),
              ),
            ),
            if (arrived && _destPos != null)
              Positioned(
                left: _destPos!.dx - DestinationHalo.size / 2,
                top: _destPos!.dy - DestinationHalo.size / 2,
                child: const DestinationHalo(),
              ),
            Positioned(
              left: 14,
              right: 14,
              top: MediaQuery.paddingOf(context).top + 6,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, a) => FadeTransition(
                  opacity: a,
                  child: SlideTransition(
                    position: Tween(
                      begin: const Offset(0, -.12),
                      end: Offset.zero,
                    ).animate(a),
                    child: child,
                  ),
                ),
                child: arrived
                    ? ArrivalBanner(
                        key: const ValueKey('arrived'),
                        info: _arrivalInfo(context, s),
                      )
                    : NavBanner(
                        key: const ValueKey('nav'),
                        data: _bannerData(context, s),
                      ),
              ),
            ),
            if (driving)
              Positioned(
                right: 16,
                top: MediaQuery.paddingOf(context).top + 6 + _bannerH + 24,
                child: Column(
                  children: [
                    MapGlassButton(
                      label: s.is3D ? l2d(context) : l3d(context),
                      semanticLabel: s.is3D ? l2d(context) : l3d(context),
                      onTap: () => context.read<NavigationBloc>().add(
                        const ViewToggled(),
                      ),
                    ),
                    if (s.followPaused) ...[
                      const SizedBox(height: 10),
                      MapGlassButton(
                        icon: AppIcon.target,
                        semanticLabel: context.l10n.navRecenter,
                        onTap: () => context.read<NavigationBloc>().add(
                          const RecenterPressed(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 24),
                    child: SpeedCluster(
                      speed: driving ? s.speedKmh.round() : 0,
                      limit: arrived ? null : _speedLimit(context, s),
                    ),
                  ),
                  if (arrived)
                    ArrivalSheet(
                      info: _arrivalInfo(context, s),
                      onContinue: () => context.read<NavigationBloc>().add(
                        const ContinueToFuelPressed(),
                      ),
                      onExit: () => context.read<NavigationBloc>().add(
                        const ExitPressed(),
                      ),
                    )
                  else
                    NavBottomCard(
                      data: _cardData(context, s),
                      onExit: () => confirmNavExit(
                        context,
                        () => context.read<NavigationBloc>().add(
                          const ExitPressed(),
                        ),
                      ),
                      onDestination: () => _openStation(context, s),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String l2d(BuildContext c) => c.l10n.navView2d;
  String l3d(BuildContext c) => c.l10n.navView3d;
}

String _street(BuildContext context, int index) {
  final l = context.l10n;
  final names = [
    l.streetCanaval,
    l.streetJavierPrado,
    l.streetPetitThouars,
    l.streetArequipa,
    l.streetAmericaSur,
  ];
  return names[index % names.length];
}
