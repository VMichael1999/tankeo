import 'package:flutter/material.dart';

import '../../../core/icons/icons.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/slide_to_confirm.dart';

/// Datos ya formateados que muestran el banner y la hoja de llegada.
class ArrivalInfo {
  const ArrivalInfo({
    required this.stationName,
    required this.address,
    required this.island,
    required this.pump,
    required this.rightSide,
    required this.distance,
    required this.minutes,
    required this.arrivalTime,
    required this.fuelLabel,
    required this.price,
    required this.pumpFree,
  });

  final String stationName;
  final String address;
  final String island;
  final int pump;

  /// ¿El surtidor queda a la derecha del auto?
  final bool rightSide;
  final String distance;
  final int minutes;
  final String arrivalTime;
  final String fuelLabel;
  final String price;
  final bool pumpFree;
}

/// Banner oscuro de llegada: check con pulso, isla y surtidor, y un mini mapa
/// con los surtidores vecinos. Reemplaza al banner de maniobra.
class ArrivalBanner extends StatefulWidget {
  const ArrivalBanner({super.key, required this.info});

  final ArrivalInfo info;

  @override
  State<ArrivalBanner> createState() => _ArrivalBannerState();
}

class _ArrivalBannerState extends State<ArrivalBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _pulse.stop();
    } else if (!_pulse.isAnimating) {
      _pulse.repeat();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final i = widget.info;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 17),
      decoration: BoxDecoration(
        color: AppColors.pinPill,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: .55),
            offset: const Offset(0, 18),
            blurRadius: 30,
            spreadRadius: -16,
          ),
        ],
      ),
      child: Row(
        children: [
          _CheckBadge(pulse: _pulse),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.arrivalBannerEyebrow,
                  style: AppText.ui(
                    12.5,
                    AppText.w6,
                    color: AppColors.arrivalMint.withValues(alpha: .85),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l.arrivalBannerTitle(i.island),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.ui(
                    21,
                    AppText.w8,
                    color: AppColors.white,
                    height: 1.15,
                    letterSpacing: -.42,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  l.arrivalBannerSubtitle(
                    '${i.pump}',
                    i.rightSide ? l.arrivalSideRight : l.arrivalSideLeft,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.ui(
                    13,
                    AppText.w5,
                    color: AppColors.white.withValues(alpha: .6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _PumpMiniMap(island: i.island, pump: i.pump),
        ],
      ),
    );
  }
}

/// Check en cuadro verde tenue con un anillo exterior que pulsa.
class _CheckBadge extends StatelessWidget {
  const _CheckBadge({required this.pulse});

  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -5,
            top: -5,
            right: -5,
            bottom: -5,
            child: AnimatedBuilder(
              animation: pulse,
              builder: (context, child) => Opacity(
                opacity: 1 - pulse.value,
                child: Transform.scale(
                  scale: 1 + .08 * pulse.value,
                  child: child,
                ),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.arrivalMint.withValues(alpha: .18),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.successLight.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.arrivalMint.withValues(alpha: .22),
              ),
            ),
            child: const Center(
              child: AppIconView(
                AppIcon.check,
                size: 26,
                color: AppColors.arrivalMint,
                strokeWidth: 2.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Los surtidores vecinos al asignado; el asignado resalta en naranja tenue.
class _PumpMiniMap extends StatelessWidget {
  const _PumpMiniMap({required this.island, required this.pump});

  final String island;
  final int pump;

  static const _letters = 'ABCDEFGH';

  @override
  Widget build(BuildContext context) {
    final first = pump <= 1 ? 1 : pump - 1;
    final idx = _letters.indexOf(island).clamp(0, _letters.length - 2);
    final next = _letters[idx + 1];
    return ExcludeSemantics(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var n = first; n < first + 3; n++) ...[
            if (n != first) const SizedBox(width: 4),
            _PumpCell(
              letter: n > pump ? next : island,
              number: n,
              on: n == pump,
            ),
          ],
        ],
      ),
    );
  }
}

class _PumpCell extends StatelessWidget {
  const _PumpCell({
    required this.letter,
    required this.number,
    required this.on,
  });

  final String letter;
  final int number;
  final bool on;

  @override
  Widget build(BuildContext context) {
    final color = on
        ? AppColors.arrivalPumpText
        : AppColors.white.withValues(alpha: .45);
    return Container(
      width: 30,
      height: on ? 54 : 44,
      decoration: BoxDecoration(
        color: on
            ? AppColors.primary.withValues(alpha: .16)
            : AppColors.white.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(9),
        border: on
            ? Border.all(
                color: AppColors.primary.withValues(alpha: .55),
                width: 1.5,
              )
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(letter, style: AppText.ui(11, AppText.w7, color: color)),
          Text(
            '$number',
            style: AppText.ui(16, AppText.w8, color: color, height: 1.1),
          ),
        ],
      ),
    );
  }
}

/// Hoja inferior de llegada: grifo, datos del viaje, surtidor asignado,
/// botón deslizable y salida.
class ArrivalSheet extends StatefulWidget {
  const ArrivalSheet({
    super.key,
    required this.info,
    required this.onContinue,
    required this.onExit,
  });

  final ArrivalInfo info;
  final VoidCallback onContinue;
  final VoidCallback onExit;

  @override
  State<ArrivalSheet> createState() => _ArrivalSheetState();
}

class _ArrivalSheetState extends State<ArrivalSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _in = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450 + 60 * 4 + 250),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _in.value = 1;
    } else if (_in.value == 0 && !_in.isAnimating) {
      _in.forward();
    }
  }

  @override
  void dispose() {
    _in.dispose();
    super.dispose();
  }

  double get _total => _in.duration!.inMilliseconds.toDouble();

  /// Entrada escalonada de cada bloque: 60 ms de desfase, 8 px y fundido.
  Widget _stagger(int i, Widget child) {
    final start = (120 + 60 * i) / _total;
    final end = ((120 + 60 * i + 250) / _total).clamp(0.0, 1.0);
    final a = CurvedAnimation(
      parent: _in,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
    return AnimatedBuilder(
      animation: a,
      builder: (context, c) => Opacity(
        opacity: a.value,
        child: Transform.translate(
          offset: Offset(0, 8 * (1 - a.value)),
          child: c,
        ),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final i = widget.info;
    final slide = CurvedAnimation(
      parent: _in,
      curve: Interval(0, 450 / _total, curve: Curves.easeOutBack),
    );
    return AnimatedBuilder(
      animation: slide,
      builder: (context, child) => FractionalTranslation(
        translation: Offset(0, 1 - slide.value),
        child: child,
      ),
      child: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          10,
          20,
          30 + MediaQuery.paddingOf(context).bottom * .4,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: AppColors.scrim.withValues(alpha: .3),
              offset: const Offset(0, -12),
              blurRadius: 30,
              spreadRadius: -14,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: AppColors.arrivalGrab,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            _stagger(0, _StationHeader(info: i)),
            const SizedBox(height: 16),
            _stagger(1, _TripStats(info: i)),
            const SizedBox(height: 14),
            _stagger(2, _PumpCard(info: i)),
            const SizedBox(height: 16),
            _stagger(
              3,
              SlideToConfirm(
                label: l.arrivalSlide,
                onConfirmed: widget.onContinue,
              ),
            ),
            const SizedBox(height: 4),
            _stagger(
              4,
              TextButton(
                onPressed: widget.onExit,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.ink2,
                  textStyle: AppText.ui(14, AppText.w6),
                ),
                child: Text(l.arrivalExit),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StationHeader extends StatelessWidget {
  const _StationHeader({required this.info});

  final ArrivalInfo info;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.loginSheet,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Center(
            child: AppIconView(
              AppIcon.pump,
              size: 24,
              color: AppColors.ink,
              strokeWidth: 1.8,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                info.stationName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.ui(
                  17.5,
                  AppText.w8,
                  height: 1.2,
                  letterSpacing: -.18,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                info.address,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.ui(13, AppText.w5, color: AppColors.ink2),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Container(
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.arrivalChipBg,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.arrivalChipDot,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                l.arrivalChip,
                style: AppText.ui(
                  12.5,
                  AppText.w7,
                  color: AppColors.arrivalChipText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TripStats extends StatelessWidget {
  const _TripStats({required this.info});

  final ArrivalInfo info;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    Widget cell(String value, String label) => Expanded(
      child: Column(
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.ui(17, AppText.w8),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppText.ui(12, AppText.w5, color: AppColors.ink2)),
        ],
      ),
    );
    const divider = SizedBox(
      height: 36,
      child: VerticalDivider(
        width: 1,
        thickness: 1,
        color: AppColors.arrivalDivider,
      ),
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.loginSheet,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          cell(info.distance, l.arrivalStatDistance),
          divider,
          cell(l.minutes(info.minutes), l.arrivalStatTime),
          divider,
          cell(info.arrivalTime, l.arrivalStatArrival),
        ],
      ),
    );
  }
}

class _PumpCard extends StatelessWidget {
  const _PumpCard({required this.info});

  final ArrivalInfo info;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.arrivalCardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.arrivalPumpBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l.arrivalPumpShort,
                  style: AppText.ui(
                    9.5,
                    AppText.w7,
                    color: AppColors.gasFillC.withValues(alpha: .85),
                    letterSpacing: .57,
                  ),
                ),
                Text(
                  '${info.pump}',
                  style: AppText.ui(
                    24,
                    AppText.w8,
                    color: AppColors.gasFillC,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.arrivalPumpTitle(info.island, l.arrivalFuelsBoth),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.ui(15.5, AppText.w7),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: info.pumpFree
                            ? AppColors.success
                            : AppColors.warning,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        info.pumpFree ? l.arrivalPumpFree : l.arrivalPumpBusy,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.ui(
                          13,
                          AppText.w5,
                          color: AppColors.ink2,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                info.fuelLabel,
                style: AppText.ui(11, AppText.w6, color: AppColors.ink2),
              ),
              Text(info.price, style: AppText.ui(18, AppText.w8)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Halo verde que pulsa sobre el grifo de destino.
class DestinationHalo extends StatefulWidget {
  const DestinationHalo({super.key});

  static const size = 110.0;

  @override
  State<DestinationHalo> createState() => _DestinationHaloState();
}

class _DestinationHaloState extends State<DestinationHalo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, child) => Transform.scale(
          scale: .95 + .1 * Curves.easeInOut.transform(_c.value),
          child: child,
        ),
        child: Container(
          width: DestinationHalo.size,
          height: DestinationHalo.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.success.withValues(alpha: .14),
                AppColors.success.withValues(alpha: 0),
              ],
              stops: const [0, .7],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.success.withValues(alpha: .35),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
