import 'package:flutter/material.dart';

import '../icons/icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../theme/app_text.dart';

/// Círculo blanco de 46 con un ícono y una insignia opcional.
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.semanticLabel,
    this.badge,
    this.badgeColor = AppColors.danger,
    this.shadow = true,
    this.background = AppColors.white,
    this.iconColor = AppColors.ink,
    this.filled = false,
    this.size = 46,
  });

  final AppIcon icon;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final String? badge;
  final Color badgeColor;
  final bool shadow;
  final Color background;
  final Color iconColor;
  final bool filled;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: background,
                  shape: BoxShape.circle,
                  boxShadow: shadow ? AppShadows.floating : null,
                ),
                child: SizedBox(
                  width: size,
                  height: size,
                  child: Center(
                    child: AppIconView(
                      icon,
                      size: 20,
                      color: iconColor,
                      filled: filled,
                    ),
                  ),
                ),
              ),
              if (badge != null)
                Positioned(
                  top: -3,
                  right: -3,
                  child: Container(
                    width: 19,
                    height: 19,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badge!,
                      style: AppText.ui(
                        10.5,
                        AppText.w7,
                        color: AppColors.white,
                        height: 19 / 10.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Píldora blanca de 46 con flecha y título 15/600 («← Grifos cercanos»).
class PillBackButton extends StatelessWidget {
  const PillBackButton({
    super.key,
    required this.title,
    required this.onPressed,
  });

  final String title;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: title,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: Container(
          height: 46,
          padding: const EdgeInsets.only(left: 14, right: 18),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(23),
            boxShadow: AppShadows.floating,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppIconView(AppIcon.back, size: 19, color: AppColors.ink),
              const SizedBox(width: 10),
              Text(title, style: AppText.ui(15, AppText.w6)),
            ],
          ),
        ),
      ),
    );
  }
}
