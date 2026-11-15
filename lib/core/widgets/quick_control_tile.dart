import 'package:flutter/material.dart';

import '../icons/icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Control rápido del auto (Puertas, GNV, Luces, Tapa): activo en naranja.
class QuickControlTile extends StatelessWidget {
  const QuickControlTile({
    super.key,
    required this.icon,
    required this.title,
    required this.status,
    required this.on,
    required this.onTap,
  });

  final AppIcon icon;
  final String title;
  final String status;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      toggled: on,
      label: '$title, $status',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 104,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: on ? AppColors.primary : AppColors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: on
                        ? AppColors.white.withValues(alpha: .18)
                        : AppColors.warmTile,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: AppIconView(
                      icon,
                      size: 18,
                      color: on ? AppColors.white : AppColors.primary,
                    ),
                  ),
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
                    Text(
                      title,
                      style: AppText.ui(
                        14,
                        AppText.w7,
                        color: on ? AppColors.white : AppColors.ink,
                      ),
                    ),
                    Text(
                      status,
                      style: AppText.ui(
                        11.5,
                        AppText.w4,
                        color: on
                            ? AppColors.white.withValues(alpha: .75)
                            : AppColors.ink2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
