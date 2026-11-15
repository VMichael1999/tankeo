import 'package:flutter/material.dart';

import '../domain/fuel_type.dart';
import '../icons/icons.dart';
import '../l10n/l10n.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../theme/tankeo_tokens.dart';

/// Segmento Gasolina (naranja) / GNV (teal). Se bloquea fuera de `Idle`.
class FuelSegment extends StatelessWidget {
  const FuelSegment({
    super.key,
    required this.selected,
    required this.enabled,
    required this.onChanged,
  });

  final TankKind selected;
  final bool enabled;
  final ValueChanged<TankKind> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = context.l10n;
    Widget item(TankKind k, String label, AppIcon icon, Color color) {
      final on = selected == k;
      return Expanded(
        child: Semantics(
          button: true,
          selected: on,
          enabled: enabled,
          label: label,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: enabled ? () => onChanged(k) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: on ? color : AppColors.white.withValues(alpha: 0),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Opacity(
                opacity: enabled ? 1 : .45,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppIconView(
                      icon,
                      size: 17,
                      color: on ? AppColors.white : t.ink2,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: AppText.ui(
                        14.5,
                        AppText.w6,
                        color: on ? AppColors.white : t.ink2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      height: TankeoTokens.hSegment,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(TankeoTokens.rButton),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          item(TankKind.gasoline, l.fuelGasoline, AppIcon.pump, t.primary),
          item(TankKind.gnv, l.fuelGnv, AppIcon.cylinder, t.gnv),
        ],
      ),
    );
  }
}
