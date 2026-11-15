import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../theme/tankeo_tokens.dart';

/// Barra de pestañas flotante con `liquid_glass_widgets` (`GlassTabBar`):
/// vidrio claro de iOS 27, ícono con nombre debajo, lente del paquete que
/// se arrastra entre pestañas, color de la app en la activa y punto naranja
/// en Carga mientras hay una sesión.
class TankeoTabBar extends StatelessWidget {
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

  /// Solo íconos y 52 de alto (al hacer scroll hacia abajo).
  final bool compact;

  static const width = TankeoTokens.navWidth;
  static const chargeTab = 1;

  /// Margen vertical que el paquete deja alrededor de la barra.
  static const verticalPadding = 20.0;

  /// Margen lateral para que la barra mida [width] en una pantalla de
  /// ancho [screenWidth].
  static double horizontalPaddingFor(double screenWidth) =>
      ((screenWidth - width) / 2).clamp(8.0, double.infinity);

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final active = dark ? AppColors.primaryLight : AppColors.primary;
    final idle = dark ? AppColors.tabInactiveDark : AppColors.tabInactive;
    final solid = MediaQuery.highContrastOf(context);
    final base = dark
        ? LiquidGlassSettings.ios27Dark
        : LiquidGlassSettings.ios27Light;
    final settings = solid
        ? base.copyWith(
            glassColor: dark ? AppColors.tabGlassDark : AppColors.tabGlass,
          )
        : base;
    final h = compact ? TankeoTokens.navHeightCompact : TankeoTokens.navHeight;

    Widget icon(int i, {required bool on}) => _TabIcon(
      index: i,
      color: on ? active : idle,
      active: on,
      charging: charging && i == chargeTab,
      dark: dark,
    );

    // Vive fuera del Scaffold: sin Material los nombres salen subrayados.
    return Material(
      type: MaterialType.transparency,
      child: Semantics(
        hint: charging ? chargingLabel : null,
        child: GlassTabBar.bottom(
          selectedIndex: selectedIndex,
          onTabSelected: onSelected,
          horizontalPadding: horizontalPaddingFor(
            MediaQuery.sizeOf(context).width,
          ),
          verticalPadding: verticalPadding,
          barHeight: h,
          barBorderRadius: h / 2,
          settings: settings,
          indicatorSettings: LiquidGlassSettings.ios27Indicator,
          indicatorColor: (dark ? AppColors.white : AppColors.scrim).withValues(
            alpha: dark ? .10 : .07,
          ),
          selectedIconColor: active,
          unselectedIconColor: idle,
          selectedLabelColor: active,
          unselectedLabelColor: idle,
          iconSize: 24,
          iconLabelSpacing: 3,
          labelFontSize: 10.5,
          selectedLabelStyle: AppText.ui(10.5, AppText.w7, color: active),
          unselectedLabelStyle: AppText.ui(10.5, AppText.w6, color: idle),
          tabs: [
            for (var i = 0; i < 4; i++)
              GlassTab(
                icon: icon(i, on: false),
                activeIcon: icon(i, on: true),
                label: compact ? null : labels[i],
                semanticLabel: labels[i],
              ),
          ],
        ),
      ),
    );
  }
}

/// Íconos de las pestañas (24 × 24). Activo: trazo 2.1 y relleno al 18 %.
class _TabIcon extends StatelessWidget {
  const _TabIcon({
    required this.index,
    required this.color,
    required this.active,
    required this.charging,
    required this.dark,
  });

  final int index;
  final Color color;
  final bool active;
  final bool charging;
  final bool dark;

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
    return SizedBox(
      width: 24,
      height: 24,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SvgPicture.string(svg, width: 24, height: 24),
          if (charging)
            Positioned(top: -3, right: -5, child: ChargingDot(dark: dark)),
        ],
      ),
    );
  }
}

/// Punto naranja de 8 con aro de 2 que late (1 → 1.25, 1.4 s).
class ChargingDot extends StatefulWidget {
  const ChargingDot({super.key, this.dark = false});

  final bool dark;

  @override
  State<ChargingDot> createState() => _ChargingDotState();
}

class _ChargingDotState extends State<ChargingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
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
  Widget build(BuildContext context) => ScaleTransition(
    scale: Tween(
      begin: 1.0,
      end: 1.25,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut)),
    child: Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: widget.dark ? AppColors.primaryLight : AppColors.primary,
        shape: BoxShape.circle,
        border: Border.all(
          color: (widget.dark ? AppColors.tabGlassDark : AppColors.tabGlass)
              .withValues(alpha: .95),
          width: 2,
        ),
      ),
    ),
  );
}
