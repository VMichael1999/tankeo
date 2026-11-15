import 'package:flutter/material.dart';

import '../domain/fuel_type.dart';
import '../l10n/fuel_l10n.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../theme/app_text.dart';
import '../theme/tankeo_tokens.dart';

/// Píldoras de filtro por combustible; la activa va en `ink` con texto blanco.
class FuelFilterChips extends StatelessWidget {
  const FuelFilterChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final FuelType selected;
  final ValueChanged<FuelType> onSelected;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return SizedBox(
      height: TankeoTokens.hChip + 14,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
        itemCount: FuelType.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final f = FuelType.values[i];
          final on = f == selected;
          return Semantics(
            button: true,
            selected: on,
            label: f.label(context),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onSelected(f),
              child: Container(
                height: TankeoTokens.hChip,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: on ? t.ink : AppColors.white,
                  borderRadius: BorderRadius.circular(TankeoTokens.rChip),
                  boxShadow: AppShadows.chip,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: f.color(t),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      f.label(context),
                      style: AppText.ui(
                        13.5,
                        AppText.w6,
                        color: on ? AppColors.white : t.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
