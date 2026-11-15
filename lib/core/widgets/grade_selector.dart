import 'package:flutter/material.dart';

import '../domain/fuel_type.dart';
import '../l10n/fuel_l10n.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../utils/money.dart';

/// Regular / Premium con su precio; solo se muestra con gasolina.
class GradeSelector extends StatelessWidget {
  const GradeSelector({
    super.key,
    required this.selected,
    required this.regularPrice,
    required this.premiumPrice,
    required this.enabled,
    required this.onChanged,
  });

  final FuelType selected;
  final double regularPrice;
  final double premiumPrice;
  final bool enabled;
  final ValueChanged<FuelType> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget item(FuelType f, double price) {
      final on = selected == f;
      return Expanded(
        child: Semantics(
          button: true,
          selected: on,
          enabled: enabled,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: enabled ? () => onChanged(f) : null,
            child: Opacity(
              opacity: enabled ? 1 : .6,
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: on ? AppColors.primaryTint : AppColors.white,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: on ? AppColors.primary : AppColors.lineSoft,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(f.label(context), style: AppText.ui(13.5, AppText.w6)),
                    const SizedBox(width: 6),
                    Text(
                      Money.format(price),
                      style: AppText.ui(12, AppText.w5, color: AppColors.ink2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        item(FuelType.regular, regularPrice),
        const SizedBox(width: 8),
        item(FuelType.premium, premiumPrice),
      ],
    );
  }
}
