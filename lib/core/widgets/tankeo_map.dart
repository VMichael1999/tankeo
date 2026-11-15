import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../features/stations/data/map_geo.dart';
import '../../features/stations/data/road_route_repository.dart';
import '../../features/stations/domain/station.dart';
import '../domain/fuel_type.dart';
import '../theme/app_colors.dart';
import '../utils/money.dart';
import 'drop_shadow_image.dart';
import 'map_style.dart';
import 'station_illustration.dart';

/// Controla la cámara del [TankeoMap] desde fuera (zoom, reencuadre).
class TankeoMapController {
  _TankeoMapState? _state;

  /// Encuadra el auto, la ruta y el grifo; la ruta se dibuja en 900 ms.
  void focus(Station station, {bool animate = true}) =>
      _state?._focus(station, animate);

  void zoomBy(double delta) => _state?._zoomBy(delta);
}

/// Mapa de Google con el estilo claro de Tankeo: pines con el precio del
/// combustible filtrado, ruta naranja con borde blanco y el auto.
class TankeoMap extends StatefulWidget {
  const TankeoMap({
    super.key,
    required this.controller,
    required this.stations,
    required this.selectedIndex,
    required this.filter,
    required this.cheapestIndex,
    required this.onPinTap,
    required this.routes,
    this.padding = EdgeInsets.zero,
    this.visible,
  });

  final TankeoMapController controller;
  final List<Station> stations;
  final int selectedIndex;
  final FuelType filter;
  final int cheapestIndex;
  final ValueChanged<int> onPinTap;

  /// Rutas reales por calles (Google).
  final RoadRouteRepository routes;

  /// Zona del mapa tapada por la interfaz (para encuadrar sin que se esconda).
  final EdgeInsets padding;

  /// Grifos que cumplen los filtros; los demás bajan al 22 % de opacidad.
  final Set<int>? visible;

  @override
  State<TankeoMap> createState() => _TankeoMapState();
}

class _TankeoMapState extends State<TankeoMap>
    with SingleTickerProviderStateMixin {
  GoogleMapController? _map;
  final Map<String, BitmapDescriptor> _pins = {};
  BitmapDescriptor? _car;
  late final AnimationController _route = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  int _routeFor = 0;
  Station? _pending;

  @override
  void initState() {
    super.initState();
    widget.controller._state = this;
    _routeFor = widget.selectedIndex;
    _route.value = 1;
    _route.addListener(() => setState(() {}));
    _loadCar();
    _buildPins();
    widget.routes.addListener(_onRoutes);
    for (final st in widget.stations) {
      widget.routes.load(st);
    }
  }

  /// Llegó (o falló) una ruta: si es la del grifo en pantalla, reencuadra y
  /// la dibuja de nuevo.
  void _onRoutes() {
    if (!mounted) return;
    final st = widget.stations[_routeFor.clamp(0, widget.stations.length - 1)];
    final ready = widget.routes.pointsFor(st).isNotEmpty;
    if (ready && _drawnFor != st.name) {
      _drawnFor = st.name;
      _focus(st, true);
    } else {
      setState(() {});
    }
  }

  String? _drawnFor;

  @override
  void didUpdateWidget(TankeoMap old) {
    super.didUpdateWidget(old);
    widget.controller._state = this;
    if (old.filter != widget.filter ||
        old.selectedIndex != widget.selectedIndex ||
        old.cheapestIndex != widget.cheapestIndex) {
      _buildPins();
    }
  }

  @override
  void dispose() {
    widget.routes.removeListener(_onRoutes);
    _route.dispose();
    super.dispose();
  }

  Future<void> _loadCar() async {
    final data = await rootBundle.load(AppImages.carSide);
    final d = BitmapDescriptor.bytes(
      data.buffer.asUint8List(),
      width: 84,
      height: 37,
    );
    if (mounted) setState(() => _car = d);
  }

  Future<BitmapDescriptor> _pinBitmap(
    String label,
    bool best,
    bool free,
    bool selected,
  ) async {
    final key = '$label|$best|$free|$selected';
    final cached = _pins[key];
    if (cached != null) return cached;
    const scale = 3.0;
    final k = selected ? 1.18 : 1.0;
    const w = PumpPin.width, h = PumpPin.height;
    final rec = ui.PictureRecorder();
    final canvas = Canvas(rec);
    canvas.scale(scale * k);
    PumpPinPainter(label, best, free).paint(canvas, const Size(w, h));
    final img = await rec.endRecording().toImage(
      (w * k * scale).ceil(),
      (h * k * scale).ceil(),
    );
    final bytes = (await img.toByteData(format: ui.ImageByteFormat.png))!.buffer
        .asUint8List();
    final d = BitmapDescriptor.bytes(bytes, width: w * k, height: h * k);
    _pins[key] = d;
    return d;
  }

  Future<void> _buildPins() async {
    for (var i = 0; i < widget.stations.length; i++) {
      final st = widget.stations[i];
      await _pinBitmap(
        Money.format(st.priceOf(widget.filter)),
        widget.cheapestIndex == i,
        st.hasFreePumps,
        i == widget.selectedIndex,
      );
    }
    if (mounted) setState(() {});
  }

  List<LatLng> _routeOf(Station s) => widget.routes.pointsFor(s);

  LatLngBounds _boundsFor(Station s) => MapGeo.boundsOf([
    MapGeo.car,
    MapGeo.fromWorld(s.position),
    ..._routeOf(s),
  ]);

  Future<void> _focus(Station s, bool animate) async {
    _routeFor = widget.stations.indexOf(s);
    if (widget.routes.pointsFor(s).isNotEmpty) _drawnFor = s.name;
    final m = _map;
    if (m == null) {
      _pending = s;
      return;
    }
    final update = CameraUpdate.newLatLngBounds(_boundsFor(s), 56);
    if (animate && !MediaQuery.disableAnimationsOf(context)) {
      await m.animateCamera(update);
      _route.forward(from: 0);
    } else {
      await m.moveCamera(update);
      _route.value = 1;
    }
  }

  void _zoomBy(double delta) => _map?.animateCamera(CameraUpdate.zoomBy(delta));

  /// Parte de la ruta dibujada según el avance (0..1).
  List<LatLng> _partial(List<LatLng> pts, double t) {
    if (t >= 1 || pts.length < 2) return pts;
    final seg = <double>[];
    var total = 0.0;
    for (var i = 1; i < pts.length; i++) {
      final d = math.sqrt(
        math.pow(pts[i].latitude - pts[i - 1].latitude, 2) +
            math.pow(pts[i].longitude - pts[i - 1].longitude, 2),
      );
      seg.add(d);
      total += d;
    }
    var left = total * Curves.easeInOutCubic.transform(t);
    final out = <LatLng>[pts.first];
    for (var i = 0; i < seg.length; i++) {
      if (left >= seg[i]) {
        out.add(pts[i + 1]);
        left -= seg[i];
      } else {
        final f = left / seg[i];
        out.add(
          LatLng(
            pts[i].latitude + (pts[i + 1].latitude - pts[i].latitude) * f,
            pts[i].longitude + (pts[i + 1].longitude - pts[i].longitude) * f,
          ),
        );
        break;
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final routeStation =
        widget.stations[_routeFor.clamp(0, widget.stations.length - 1)];
    final pts = _partial(_routeOf(routeStation), _route.value);
    final markers = <Marker>{
      for (var i = 0; i < widget.stations.length; i++)
        if (_pins[_key(i)] != null)
          Marker(
            markerId: MarkerId('st$i'),
            position: MapGeo.fromWorld(widget.stations[i].position),
            icon: _pins[_key(i)]!,
            anchor: const Offset(.5, 67 / 71),
            alpha: (widget.visible?.contains(i) ?? true) ? 1 : .22,
            zIndexInt: i == widget.selectedIndex ? 3 : 2,
            onTap: () => widget.onPinTap(i),
          ),
      if (_car != null)
        Marker(
          markerId: const MarkerId('car'),
          position: MapGeo.car,
          icon: _car!,
          anchor: const Offset(.5, .6),
          zIndexInt: 1,
          consumeTapEvents: true,
        ),
    };
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: MapGeo.car, zoom: 14.5),
      style: kLightMapStyle,
      padding: widget.padding,
      markers: markers,
      polylines: {
        Polyline(
          polylineId: const PolylineId('route-casing'),
          points: pts,
          color: AppColors.white,
          width: 8,
          zIndex: 1,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          jointType: JointType.round,
        ),
        Polyline(
          polylineId: const PolylineId('route'),
          points: pts,
          color: AppColors.primary,
          width: 5,
          zIndex: 2,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          jointType: JointType.round,
        ),
      },
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
      compassEnabled: false,
      mapToolbarEnabled: false,
      rotateGesturesEnabled: false,
      tiltGesturesEnabled: false,
      buildingsEnabled: false,
      onMapCreated: (c) {
        _map = c;
        final p = _pending;
        _pending = null;
        _focus(p ?? widget.stations[widget.selectedIndex], false);
      },
    );
  }

  String _key(int i) {
    final st = widget.stations[i];
    return '${Money.format(st.priceOf(widget.filter))}|${widget.cheapestIndex == i}|${st.hasFreePumps}|${i == widget.selectedIndex}';
  }
}
