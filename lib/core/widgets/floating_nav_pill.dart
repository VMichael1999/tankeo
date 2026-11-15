import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../icons/icons.dart';
import '../theme/app_colors.dart';
import '../theme/tankeo_tokens.dart';

/// Barra de navegación flotante de 270 × 64 con vidrio líquido
/// (`liquid_glass_widgets`). Íconos: Auto, Carga (surtidor), Grifos (mapa)
/// y Ajustes.
class FloatingNavPill extends StatelessWidget {
  const FloatingNavPill({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    required this.labels,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  /// Etiquetas accesibles (Auto, Carga, Grifos, Ajustes).
  final List<String> labels;

  static const _icons = [AppIcon.car, AppIcon.pump, AppIcon.map, AppIcon.hex];

  Widget _icon(int i, {required bool selected}) => AppIconView(
    _icons[i],
    size: 22,
    color: selected ? AppColors.white : AppColors.ink2,
    filled: selected && i != 1,
    strokeWidth: 1.9,
  );

  @override
  Widget build(BuildContext context) {
    final glass = LiquidGlassSettings.ios27Dark.copyWith(
      glassColor: AppColors.navPill.withValues(alpha: .94),
    );
    return Positioned(
      left: 0,
      right: 0,
      bottom: TankeoTokens.navBottom - 20,
      child: GlassTabBar.bottom(
        selectedIndex: selectedIndex,
        onTabSelected: onSelected,
        horizontalPadding:
            (TankeoTokens.designWidth - TankeoTokens.navWidth) / 2,
        verticalPadding: 20,
        barHeight: TankeoTokens.navHeight,
        barBorderRadius: TankeoTokens.navHeight / 2,
        settings: glass,
        selectedIconColor: AppColors.white,
        unselectedIconColor: AppColors.ink2,
        tabs: [
          for (var i = 0; i < _icons.length; i++)
            GlassTab(
              icon: _icon(i, selected: false),
              activeIcon: _icon(i, selected: true),
              semanticLabel: labels[i],
            ),
        ],
      ),
    );
  }
}
