import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'app_card.dart';
import 'drop_shadow_image.dart';

/// Presión de las cuatro llantas sobre el auto visto desde arriba.
class TirePressureCard extends StatelessWidget {
  const TirePressureCard({
    super.key,
    required this.psi,
    required this.celsius,
    required this.lowThreshold,
  });

  final List<int> psi;
  final List<int> celsius;
  final int lowThreshold;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final anyLow = psi.any((p) => p < lowThreshold);
    return AppCard(
      margin: const EdgeInsets.only(top: 12),
      child: SizedBox(
        height: 330,
        child: Stack(
          children: [
            Positioned(
              left: 20,
              right: 20,
              top: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l.tiresTitle, style: AppText.ui(17, AppText.w8)),
                  if (anyLow)
                    Text(
                      l.tiresLowFrontLeft,
                      style: AppText.ui(
                        13,
                        AppText.w6,
                        color: AppColors.primary,
                      ),
                    ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 56,
              child: Center(
                child: SizedBox(
                  width: 144,
                  height: 268,
                  child: Semantics(
                    image: true,
                    label: l.tiresCarSemantic,
                    child: DropShadowImage(
                      asset: AppImages.carTopVertical,
                      shadowColor: AppColors.inkField.withValues(alpha: .18),
                      offsetY: 10,
                      blur: 12,
                    ),
                  ),
                ),
              ),
            ),
            _tire(0, left: 40, top: 84),
            _tire(1, right: 40, top: 84),
            _tire(2, left: 40, top: 236),
            _tire(3, right: 40, top: 236),
          ],
        ),
      ),
    );
  }

  Widget _tire(int i, {double? left, double? right, required double top}) {
    final low = psi[i] < lowThreshold;
    return Positioned(
      left: left,
      right: right,
      top: top,
      child: Builder(
        builder: (context) {
          final l = context.l10n;
          final c = low ? AppColors.primary : AppColors.ink;
          final sub = low ? AppColors.primary : AppColors.ink2;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  text: '${psi[i]}',
                  style: AppText.ui(22, AppText.w8, color: c),
                  children: [
                    const WidgetSpan(child: SizedBox(width: 2)),
                    TextSpan(
                      text: l.psi,
                      style: AppText.ui(12, AppText.w5, color: AppColors.ink2),
                    ),
                  ],
                ),
              ),
              Text(
                low ? l.tireLowTemp(celsius[i]) : l.tireTemp(celsius[i]),
                style: AppText.ui(12, AppText.w5, color: sub),
              ),
            ],
          );
        },
      ),
    );
  }
}
