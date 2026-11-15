import 'dart:async';

import 'package:flutter/painting.dart';
import 'package:live_island_kit/live_island_kit.dart';

import '../../../core/domain/fuel_type.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/money.dart';
import '../../../core/utils/volume_format.dart';
import '../bloc/fueling_bloc.dart';

/// Live Activity (iOS) / Live Update (Android) con `live_island_kit`:
/// mientras se despacha, la isla dinámica muestra el ícono del surtidor y el
/// importe («S/ 9.49»); la pantalla de bloqueo, volumen y progreso.
///
/// Observer: escucha al [FuelingBloc]; el bloc no sabe que existe.
class LiveActivityService {
  LiveActivityService();

  StreamSubscription<FuelingState>? _sub;
  LiveActivity? _activity;
  bool _starting = false;
  DateTime _lastUpdate = DateTime.fromMillisecondsSinceEpoch(0);

  void observe(FuelingBloc bloc) {
    _sub?.cancel();
    _sub = bloc.stream.listen(_onState);
  }

  static LiveLayout layoutFor(Color accent) {
    final bar = LiveProgress.bar(
      value: bind('progreso'),
      style: LiveProgressStyle(color: accent, height: 10),
    );
    return LiveLayout(
      theme: LiveTheme(accent: accent),
      compactLeading: const LiveIcon.symbol('fuelpump.fill', accent: true),
      compactTrailing: LiveText.from(
        const LiveText(LiveBind('importe')),
        size: 14,
        weight: 700,
        accent: true,
      ),
      minimal: const LiveIcon.symbol('fuelpump.fill', accent: true),
      expanded: LiveExpanded(
        leading: const LiveBox(
          child: LiveIcon.symbol('fuelpump.fill', accent: true),
          size: 46,
          radius: 14,
          tint: 0.22,
        ),
        center: const LiveColumn([
          LiveText(LiveBind('titulo'), size: 15, weight: 600),
          LiveText(LiveBind('detalle'), size: 13, muted: true),
        ]),
        trailing: LiveText.from(
          const LiveText(LiveBind('importe')),
          size: 22,
          weight: 700,
          accent: true,
        ),
        bottom: bar,
      ),
      lockScreen: const LiveLockScreen.sameAsExpanded(),
      android: LiveAndroid(
        title: bind('titulo'),
        text: const LiveText.format('{importe} · {detalle}'),
      ),
    );
  }

  Map<String, Object> _stateFrom(Dispensing s) {
    final unit = s.config.tank.unit;
    return {
      'titulo': s.config.fuelType.isGnv ? 'GNV' : 'Gasolina',
      'detalle': '${VolumeFormat.d3(s.volume)} $unit',
      'importe': Money.format(s.displayAmount),
      'progreso': s.progress,
    };
  }

  Future<void> _onState(FuelingState state) async {
    try {
      if (state is Dispensing) {
        final accent = state.config.tank == TankKind.gnv
            ? AppColors.gnv
            : AppColors.primary;
        if (_activity == null && !_starting) {
          _starting = true;
          await LiveIsland.requestPermission();
          _activity = await LiveIsland.start(
            customId: 'tankeo-carga',
            layout: layoutFor(accent),
            state: _stateFrom(state),
            relevance: 100,
          );
          _starting = false;
        } else if (_activity != null) {
          // Máximo ~4 actualizaciones por segundo.
          final now = DateTime.now();
          if (now.difference(_lastUpdate) < const Duration(milliseconds: 250))
            return;
          _lastUpdate = now;
          await _activity!.update(_stateFrom(state));
        }
      } else if (_activity != null) {
        final a = _activity!;
        _activity = null;
        await a.end(dismiss: const LiveDismiss.after(Duration(seconds: 5)));
      }
    } catch (_) {
      // La Live Activity es opcional: nunca debe interrumpir la carga.
      _starting = false;
    }
  }

  Future<void> dispose() async => _sub?.cancel();
}
