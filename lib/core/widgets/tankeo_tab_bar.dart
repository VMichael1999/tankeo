import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../theme/tankeo_tokens.dart';

/// Barra de pestañas flotante al estilo de iOS 26 (Liquid Glass): vidrio
/// claro con desenfoque y saturación, ícono con nombre debajo y una lente
/// que se desliza con resorte hasta la pestaña activa.
///
/// - Tocar: el ítem se encoge a 0.92 y la lente viaja estirándose un 12 %.
/// - Arrastrar: la lente sigue al dedo (crece un 6 %) y se pega a la pestaña
///   más cercana al soltar.
/// - [compact]: 52 de alto y solo íconos (al hacer scroll hacia abajo).
/// - [charging]: punto naranja que late en Carga mientras hay una sesión.
class TankeoTabBar extends StatefulWidget {
  const TankeoTabBar({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    required this.labels,
    this.charging = false,
    this.chargingLabel,
    this.compact = false,
  }) : assert(labels.length == 4);

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  /// Auto, Carga, Grifos y Ajustes.
  final List<String> labels;
  final bool charging;

  /// Texto accesible del punto de carga («Carga en curso»).
  final String? chargingLabel;
  final bool compact;

  static const width = TankeoTokens.navWidth;
  static const itemW = 76.0;
  static const pad = 6.0;
  static const chargeTab = 1;

  /// Posición izquierda de la lente para la pestaña [i].
  static double lensLeft(int i) => pad + itemW * i;

  /// Pestaña más cercana a una posición de la lente.
  static int nearest(double lensX) =>
      ((lensX - pad) / itemW).round().clamp(0, 3);

  @override
  State<TankeoTabBar> createState() => _TankeoTabBarState();
}

class _TankeoTabBarState extends State<TankeoTabBar>
    with TickerProviderStateMixin {
  late final AnimationController _lens = AnimationController.unbounded(
    vsync: this,
    value: TankeoTabBar.lensLeft(widget.selectedIndex),
  );
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );
  double _from = 0;
  double _to = 0;
  bool _dragging = false;
  int? _pressed;

  static const _spring = SpringDescription(
    mass: 1,
    stiffness: 400,
    damping: 30,
  );

  bool get _reduce => MediaQuery.disableAnimationsOf(context);

  @override
  void initState() {
    super.initState();
    _from = _to = _lens.value;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncPulse();
  }

  @override
  void didUpdateWidget(TankeoTabBar old) {
    super.didUpdateWidget(old);
    if (old.selectedIndex != widget.selectedIndex && !_dragging) {
      _slideTo(widget.selectedIndex);
    }
    if (old.charging != widget.charging) _syncPulse();
  }

  void _syncPulse() {
    if (widget.charging && !_reduce) {
      if (!_pulse.isAnimating) _pulse.repeat(reverse: true);
    } else {
      _pulse
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _lens.dispose();
    _pulse.dispose();
    super.dispose();
  }

  void _slideTo(int i) {
    final target = TankeoTabBar.lensLeft(i);
    _from = _lens.value;
    _to = target;
    if (_reduce) {
      _lens.value = target;
      return;
    }
    _lens.animateWith(SpringSimulation(_spring, _lens.value, target, 0));
  }

  void _select(int i) {
    if (i != widget.selectedIndex) {
      HapticFeedback.selectionClick();
      widget.onSelected(i);
    }
    _slideTo(i);
  }

  void _dragTo(double localX) {
    final x = (localX - TankeoTabBar.itemW / 2).clamp(
      TankeoTabBar.lensLeft(0),
      TankeoTabBar.lensLeft(3),
    );
    _lens.value = x;
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final solid = MediaQuery.highContrastOf(context);
    final h = widget.compact
        ? TankeoTokens.navHeightCompact
        : TankeoTokens.navHeight;
    final lensH = h - 10;
    final glass = (dark ? AppColors.tabGlassDark : AppColors.tabGlass)
        .withValues(alpha: solid ? 1 : .72);
    final dur = _reduce ? Duration.zero : const Duration(milliseconds: 250);

    final bar = AnimatedContainer(
      duration: dur,
      curve: Curves.easeOut,
      width: TankeoTabBar.width,
      height: h,
      // Bordes en primer plano: no restan espacio a las pestañas.
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(h / 2),
        border: Border.all(
          color: AppColors.black.withValues(alpha: .08),
          width: .5,
        ),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(h / 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.scrim.withValues(alpha: .28),
            offset: const Offset(0, 12),
            blurRadius: 28,
            spreadRadius: -10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(h / 2),
        child: BackdropFilter(
          filter: solid
              ? ui.ImageFilter.blur()
              : ui.ImageFilter.compose(
                  outer: ColorFilter.matrix(_saturation(1.8)),
                  inner: ui.ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                ),
          child: Container(
            decoration: BoxDecoration(
              color: glass,
              borderRadius: BorderRadius.circular(h / 2),
            ),
            foregroundDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(h / 2),
              border: Border.all(
                color: AppColors.white.withValues(alpha: dark ? .08 : .7),
                width: .5,
              ),
            ),
            child: Stack(
              children: [
                // Brillo superior de 1 px.
                Positioned(
                  left: h / 2,
                  right: h / 2,
                  top: 0,
                  height: 1,
                  child: ColoredBox(
                    color: AppColors.white.withValues(alpha: dark ? .12 : .9),
                  ),
                ),
                AnimatedBuilder(
                  animation: _lens,
                  builder: (context, _) {
                    final span = (_to - _from).abs();
                    final t = span < 1
                        ? 1.0
                        : ((_lens.value - _from) / (_to - _from)).clamp(
                            0.0,
                            1.0,
                          );
                    final stretch = _dragging
                        ? 1.06
                        : 1 + .12 * math.sin(math.pi * t);
                    return Positioned(
                      left: _lens.value,
                      top: (h - lensH) / 2,
                      width: TankeoTabBar.itemW,
                      height: lensH,
                      child: Transform.scale(
                        scaleX: stretch,
                        scaleY: _dragging ? 1.06 : 1,
                        child: _Lens(dark: dark, height: lensH),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: TankeoTabBar.pad,
                  ),
                  child: Row(
                    children: [
                      for (var i = 0; i < 4; i++) _item(i, dark, h - 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // La barra vive fuera del Scaffold: sin Material los textos salen
    // subrayados.
    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: (d) {
          setState(() => _dragging = true);
          _lens.stop();
          _dragTo(d.localPosition.dx);
        },
        onHorizontalDragUpdate: (d) => _dragTo(d.localPosition.dx),
        onHorizontalDragEnd: (_) {
          setState(() => _dragging = false);
          _select(TankeoTabBar.nearest(_lens.value));
        },
        onHorizontalDragCancel: () {
          setState(() => _dragging = false);
          _slideTo(widget.selectedIndex);
        },
        child: bar,
      ),
    );
  }

  Widget _item(int i, bool dark, double itemH) {
    final on = i == widget.selectedIndex;
    final color = on
        ? (dark ? AppColors.primaryLight : AppColors.primary)
        : (dark ? AppColors.tabInactiveDark : AppColors.tabInactive);
    final dur = _reduce ? Duration.zero : const Duration(milliseconds: 200);
    final showDot = widget.charging && i == TankeoTabBar.chargeTab;
    return Semantics(
      button: true,
      selected: on,
      label: widget.labels[i],
      hint: showDot ? widget.chargingLabel : null,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = i),
        onTapCancel: () => setState(() => _pressed = null),
        onTapUp: (_) => setState(() => _pressed = null),
        onTap: () => _select(i),
        child: AnimatedScale(
          scale: _pressed == i ? .92 : 1,
          duration: _reduce ? Duration.zero : const Duration(milliseconds: 180),
          curve: Curves.easeOutBack,
          child: SizedBox(
            width: TankeoTabBar.itemW,
            height: math.max(itemH, 44),
            child: TweenAnimationBuilder<Color?>(
              tween: ColorTween(end: color),
              duration: dur,
              builder: (context, c, _) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _TabIcon(index: i, color: c ?? color, active: on),
                        if (showDot)
                          Positioned(
                            top: -3,
                            right: -5,
                            child: ScaleTransition(
                              scale: Tween(begin: 1.0, end: 1.25).animate(
                                CurvedAnimation(
                                  parent: _pulse,
                                  curve: Curves.easeInOut,
                                ),
                              ),
                              child: _ChargingDot(dark: dark),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (_reduce)
                    _label(i, on, c ?? color)
                  else
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                      child: _label(i, on, c ?? color),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(int i, bool on, Color color) => widget.compact
      ? const SizedBox(width: TankeoTabBar.itemW)
      : Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(
            widget.labels[i],
            maxLines: 1,
            style: AppText.ui(
              10.5,
              on ? AppText.w7 : AppText.w6,
              color: color,
              height: 1.1,
              letterSpacing: .1,
            ),
          ),
        );

  /// Matriz de saturación (como `saturate()` de CSS).
  static List<double> _saturation(double s) {
    const r = .2126, g = .7152, b = .0722;
    return [
      (1 - s) * r + s, (1 - s) * g, (1 - s) * b, 0, 0, //
      (1 - s) * r, (1 - s) * g + s, (1 - s) * b, 0, 0, //
      (1 - s) * r, (1 - s) * g, (1 - s) * b + s, 0, 0, //
      0, 0, 0, 1, 0,
    ];
  }
}

/// Lente de la pestaña activa: cápsula gris sutil con brillo superior.
class _Lens extends StatelessWidget {
  const _Lens({required this.dark, required this.height});

  final bool dark;
  final double height;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: dark
          ? AppColors.white.withValues(alpha: .10)
          : AppColors.scrim.withValues(alpha: .07),
      borderRadius: BorderRadius.circular(height / 2),
    ),
    child: Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: height / 2),
        child: SizedBox(
          height: 1,
          width: double.infinity,
          child: ColoredBox(
            color: AppColors.white.withValues(alpha: dark ? .2 : .6),
          ),
        ),
      ),
    ),
  );
}

class _ChargingDot extends StatelessWidget {
  const _ChargingDot({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) => Container(
    width: 12,
    height: 12,
    decoration: BoxDecoration(
      color: dark ? AppColors.primaryLight : AppColors.primary,
      shape: BoxShape.circle,
      border: Border.all(
        color: (dark ? AppColors.tabGlassDark : AppColors.tabGlass).withValues(
          alpha: .95,
        ),
        width: 2,
      ),
    ),
  );
}

/// Íconos de las pestañas (24 × 24). Activo: trazo 2.1 y relleno al 18 %.
class _TabIcon extends StatelessWidget {
  const _TabIcon({
    required this.index,
    required this.color,
    required this.active,
  });

  final int index;
  final Color color;
  final bool active;

  static const _paths = [
    // Auto
    '<path d="M5 11l1.6-4.2A2 2 0 0 1 8.5 5.5h7a2 2 0 0 1 1.9 1.3L19 11"/>'
        '<path d="M3.5 17v-4a2 2 0 0 1 2-2h13a2 2 0 0 1 2 2v4z"/>'
        '<path d="M5.5 17v1.5M18.5 17v1.5"/>'
        '<circle cx="7.5" cy="14" r=".7"/><circle cx="16.5" cy="14" r=".7"/>',
    // Carga (surtidor)
    '<path d="M4 20V5a2 2 0 0 1 2-2h7a2 2 0 0 1 2 2v15M3 20h13M15 9h2a2 2 0 0 1 2 2v5a1.5 1.5 0 0 0 3 0V8l-3-3"/>'
        '<path d="M7 7h5v4H7z"/>',
    // Grifos (mapa)
    '<path d="M9 4L3 6.5v13.5l6-2.5 6 2.5 6-2.5V4l-6 2.5z"/>'
        '<path d="M9 4v13.5M15 6.5V20"/>',
    // Ajustes (tuerca)
    '<path d="M12 2.5l8.2 4.75v9.5L12 21.5l-8.2-4.75v-9.5z"/>'
        '<circle cx="12" cy="12" r="3"/>',
  ];

  static const _fills = [
    'M3.5 17v-4a2 2 0 0 1 2-2h13a2 2 0 0 1 2 2v4z',
    'M4 20V5a2 2 0 0 1 2-2h7a2 2 0 0 1 2 2v15z',
    'M9 4L3 6.5v13.5l6-2.5 6 2.5 6-2.5V4l-6 2.5z',
    'M12 2.5l8.2 4.75v9.5L12 21.5l-8.2-4.75v-9.5z',
  ];

  static String _hex(Color c) =>
      '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

  @override
  Widget build(BuildContext context) {
    final hex = _hex(color);
    final fill = active
        ? '<path d="${_fills[index]}" fill="$hex" stroke="none" opacity=".18"/>'
        : '';
    final svg =
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" '
        'stroke="$hex" stroke-width="${active ? 2.1 : 1.8}" '
        'stroke-linecap="round" stroke-linejoin="round">$fill${_paths[index]}</svg>';
    return SvgPicture.string(svg, width: 24, height: 24);
  }
}
