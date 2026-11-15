import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../core/icons/icons.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../domain/turn_instruction.dart';

AppIcon maneuverIcon(TurnType t) => switch (t) {
  TurnType.right => AppIcon.turnRight,
  TurnType.left => AppIcon.turnLeft,
  TurnType.straight => AppIcon.straight,
  TurnType.destination => AppIcon.flag,
};

/// Lo que muestra el banner de maniobra, con los textos ya armados.
class NavBannerData {
  const NavBannerData({
    required this.overview,
    required this.type,
    required this.distanceM,
    required this.road,
    required this.turnText,
    this.nextType,
    this.nextLabel,
    this.nextStreet,
  });

  /// Vista general de la ruta (etiqueta con punto naranja tenue).
  final bool overview;
  final TurnType type;
  final double distanceM;

  /// Vía actual (o «Vista general de la ruta»).
  final String road;

  /// «A la izquierda en Av. Javier Prado».
  final String turnText;
  final TurnType? nextType;

  /// «Luego a la derecha en».
  final String? nextLabel;
  final String? nextStreet;

  bool get isTurn => type == TurnType.left || type == TurnType.right;
}

/// Distancia redondeada: 10 m por debajo de 1 km y 0.1 km desde ahí.
String formatNavDistance(BuildContext context, double meters) {
  final l = context.l10n;
  final r = TurnInstructionBuilder.roundDistance(meters);
  return r.km
      ? l.navKm((r.value as double).toStringAsFixed(1))
      : l.navMeters(r.value.toInt());
}

/// Banner oscuro de maniobra: ícono, distancia grande, calle y la franja
/// «Luego…» con la siguiente maniobra.
class NavBanner extends StatelessWidget {
  const NavBanner({super.key, required this.data});

  final NavBannerData data;

  static const turnNowMeters = 50.0;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final d = data;
    final turnNow = d.isTurn && !d.overview && d.distanceM < turnNowMeters;
    final reduce = MediaQuery.disableAnimationsOf(context);
    final dur = reduce ? Duration.zero : const Duration(milliseconds: 300);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.pinPill,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: .5),
            offset: const Offset(0, 18),
            blurRadius: 30,
            spreadRadius: -16,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: .08),
                    ),
                  ),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: dur,
                      child: AppIconView(
                        maneuverIcon(d.type),
                        key: ValueKey(d.type),
                        size: 30,
                        color: AppColors.white,
                        strokeWidth: 2.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: dur,
                    layoutBuilder: (current, previous) => Stack(
                      alignment: Alignment.centerLeft,
                      children: [...previous, ?current],
                    ),
                    transitionBuilder: (child, a) => FadeTransition(
                      opacity: a,
                      child: SlideTransition(
                        position: Tween(
                          begin: const Offset(0, .12),
                          end: Offset.zero,
                        ).animate(a),
                        child: child,
                      ),
                    ),
                    child: Column(
                      key: ValueKey('${d.type}|${d.turnText}|${d.overview}'),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (d.overview) ...[
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppColors.arrivalPumpText,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Flexible(
                              child: Text(
                                d.overview ? l.navOverviewTag : d.road,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppText.ui(
                                  12,
                                  AppText.w6,
                                  color: AppColors.white.withValues(alpha: .55),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        if (turnNow)
                          Text(
                            l.navTurnNow,
                            style: AppText.ui(
                              26,
                              AppText.w8,
                              color: AppColors.white,
                              height: 1.1,
                              letterSpacing: -.52,
                            ),
                          )
                        else
                          TweenAnimationBuilder<double>(
                            tween: Tween(end: d.distanceM),
                            duration: reduce
                                ? Duration.zero
                                : const Duration(milliseconds: 280),
                            builder: (context, m, _) => Text.rich(
                              TextSpan(
                                text: formatNavDistance(context, m),
                                style: AppText.ui(
                                  26,
                                  AppText.w8,
                                  color: AppColors.white,
                                  height: 1.1,
                                  letterSpacing: -.52,
                                ),
                                children: [
                                  if (d.isTurn)
                                    TextSpan(
                                      text: '  ${l.navDistanceThen}',
                                      style: AppText.ui(
                                        15,
                                        AppText.w7,
                                        color: AppColors.white.withValues(
                                          alpha: .55,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 2),
                        Text(
                          d.turnText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.ui(
                            14,
                            AppText.w5,
                            color: AppColors.white.withValues(alpha: .72),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: dur,
            curve: Curves.easeOut,
            child: d.nextType == null
                ? const SizedBox(width: double.infinity)
                : Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: .05),
                      border: Border(
                        top: BorderSide(
                          color: AppColors.white.withValues(alpha: .06),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        AppIconView(
                          maneuverIcon(d.nextType!),
                          size: 16,
                          color: AppColors.white.withValues(alpha: .7),
                          strokeWidth: 2.2,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              text: d.nextStreet == null
                                  ? d.nextLabel
                                  : '${d.nextLabel} ',
                              style: AppText.ui(
                                13,
                                AppText.w5,
                                color: AppColors.white.withValues(alpha: .6),
                              ),
                              children: [
                                TextSpan(
                                  text: d.nextStreet,
                                  style: AppText.ui(
                                    13,
                                    AppText.w6,
                                    color: AppColors.white,
                                  ),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Botón de vidrio de 46 × 46 para los controles del mapa.
class MapGlassButton extends StatelessWidget {
  const MapGlassButton({
    super.key,
    required this.onTap,
    required this.semanticLabel,
    this.label,
    this.icon,
  });

  final VoidCallback onTap;
  final String semanticLabel;
  final String? label;
  final AppIcon? icon;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: AppColors.scrim.withValues(alpha: .45),
                offset: const Offset(0, 8),
                blurRadius: 16,
                spreadRadius: -10,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: .92),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: AppColors.ink.withValues(alpha: .06),
                  ),
                ),
                child: icon != null
                    ? AppIconView(icon!, size: 20, color: AppColors.ink)
                    : Text(label ?? '', style: AppText.ui(13, AppText.w8)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Velocímetro blanco con la señal de velocidad máxima a su derecha.
class SpeedCluster extends StatelessWidget {
  const SpeedCluster({super.key, required this.speed, this.limit});

  final int speed;
  final int? limit;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SpeedBadge(speed: speed, over: limit != null && speed > limit!),
        if (limit != null) ...[
          const SizedBox(width: 6),
          SpeedLimitSign(limit: limit!),
        ],
      ],
    );
  }
}

class SpeedBadge extends StatelessWidget {
  const SpeedBadge({super.key, required this.speed, this.over = false});

  final int speed;
  final bool over;

  @override
  Widget build(BuildContext context) => Container(
    width: 64,
    height: 64,
    decoration: BoxDecoration(
      color: AppColors.white,
      shape: BoxShape.circle,
      border: Border.all(color: AppColors.ink.withValues(alpha: .08)),
      boxShadow: [
        BoxShadow(
          color: AppColors.scrim.withValues(alpha: .35),
          offset: const Offset(0, 10),
          blurRadius: 18,
          spreadRadius: -8,
        ),
      ],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$speed',
          style: AppText.ui(
            21,
            AppText.w8,
            height: 1,
            color: over ? AppColors.danger : AppColors.ink,
          ),
        ),
        Text(
          context.l10n.navSpeedUnit,
          style: AppText.ui(10, AppText.w6, color: AppColors.ink2, height: 1.3),
        ),
      ],
    ),
  );
}

class SpeedLimitSign extends StatelessWidget {
  const SpeedLimitSign({super.key, required this.limit});

  final int limit;

  @override
  Widget build(BuildContext context) => Semantics(
    label: context.l10n.navSpeedLimit(limit),
    excludeSemantics: true,
    child: Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.speedLimitRing, width: 4),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: .3),
            offset: const Offset(0, 6),
            blurRadius: 12,
            spreadRadius: -6,
          ),
        ],
      ),
      child: Text('$limit', style: AppText.ui(14, AppText.w8, height: 1)),
    ),
  );
}

/// Datos de la hoja inferior durante la marcha.
class NavCardData {
  const NavCardData({
    required this.minutes,
    required this.distance,
    required this.progress,
    required this.stationName,
    required this.pumpLine,
    required this.fuelLabel,
    required this.price,
    this.arrival,
  });

  final int minutes;
  final String distance;

  /// «4:45 p. m.»; `null` en la vista general.
  final String? arrival;

  /// Avance de la ruta, de 0 a 1.
  final double progress;
  final String stationName;
  final String pumpLine;
  final String fuelLabel;
  final String price;
}

/// Hoja inferior: ETA, salir, progreso de la ruta y el grifo de destino.
class NavBottomCard extends StatelessWidget {
  const NavBottomCard({
    super.key,
    required this.data,
    required this.onExit,
    required this.onDestination,
  });

  final NavCardData data;
  final VoidCallback onExit;
  final VoidCallback onDestination;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final d = data;
    final reduce = MediaQuery.disableAnimationsOf(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
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
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.arrivalGrab,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.minutes(d.minutes),
                      style: AppText.ui(
                        30,
                        AppText.w8,
                        height: 1.05,
                        letterSpacing: -.9,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          d.distance,
                          style: AppText.ui(
                            14,
                            AppText.w5,
                            color: AppColors.ink2,
                          ),
                        ),
                        if (d.arrival != null) ...[
                          Container(
                            width: 3,
                            height: 3,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: const BoxDecoration(
                              color: AppColors.ink3,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              l.navArrival(d.arrival!),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.ui(
                                14,
                                AppText.w5,
                                color: AppColors.ink2,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Semantics(
                button: true,
                label: l.navExit,
                excludeSemantics: true,
                child: GestureDetector(
                  onTap: onExit,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.grayChip,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: AppIconView(
                        AppIcon.close,
                        size: 20,
                        color: AppColors.ink2,
                        strokeWidth: 2.4,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          TweenAnimationBuilder<double>(
            tween: Tween(end: d.progress.clamp(0, 1)),
            duration: reduce
                ? Duration.zero
                : const Duration(milliseconds: 250),
            builder: (context, p, _) => SizedBox(
              height: 20,
              width: double.infinity,
              child: CustomPaint(painter: _ProgressPainter(p)),
            ),
          ),
          const SizedBox(height: 15),
          Semantics(
            button: true,
            label: l.navDestinationOpen,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onDestination,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: AppColors.loginSheet,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: AppIconView(
                          AppIcon.pump,
                          size: 20,
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
                            d.stationName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.ui(15, AppText.w7),
                          ),
                          Text(
                            d.pumpLine,
                            style: AppText.ui(
                              12.5,
                              AppText.w5,
                              color: AppColors.ink2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          d.fuelLabel,
                          style: AppText.ui(
                            11,
                            AppText.w6,
                            color: AppColors.ink2,
                          ),
                        ),
                        Text(d.price, style: AppText.ui(16, AppText.w8)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pista de 6 con la parte recorrida en naranja y el punto del auto.
class _ProgressPainter extends CustomPainter {
  _ProgressPainter(this.p);

  final double p;

  @override
  void paint(Canvas canvas, Size size) {
    const h = 6.0;
    final cy = size.height / 2;
    final track = RRect.fromLTRBR(
      0,
      cy - h / 2,
      size.width,
      cy + h / 2,
      const Radius.circular(3),
    );
    canvas.drawRRect(track, Paint()..color = AppColors.barTrack);
    final x = size.width * p;
    if (x > 0) {
      canvas.drawRRect(
        RRect.fromLTRBR(0, cy - h / 2, x, cy + h / 2, const Radius.circular(3)),
        Paint()..color = AppColors.primary,
      );
    }
    final c = Offset(x.clamp(7, size.width - 7), cy);
    canvas
      ..drawCircle(c, 10, Paint()..color = AppColors.primary)
      ..drawCircle(c, 7, Paint()..color = AppColors.white);
  }

  @override
  bool shouldRepaint(_ProgressPainter old) => old.p != p;
}

/// «¿Salir de la navegación?» con «Seguir» y «Salir»; [onExit] solo si sale.
Future<void> confirmNavExit(BuildContext context, VoidCallback onExit) async {
  final l = context.l10n;
  final ok = await showConfirmDialog(
    context,
    icon: AppIcon.exit,
    tint: AppColors.ink,
    tintBg: AppColors.grayChip,
    title: l.navExitTitle,
    body: l.navExitBody,
    cancelLabel: l.navExitKeep,
    confirmLabel: l.navExitConfirm,
  );
  if (ok) onExit();
}
