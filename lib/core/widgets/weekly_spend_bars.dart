import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../utils/money.dart';
import 'app_card.dart';

/// Gasto de la semana: barras de D a S; la de hoy va en naranja con su valor.
class WeeklySpendBars extends StatelessWidget {
  const WeeklySpendBars({
    super.key,
    required this.total,
    required this.saved,
    required this.barHeights,
    required this.todayIndex,
    required this.todayAmount,
  });

  final double total;
  final double saved;
  final List<double> barHeights;
  final int todayIndex;
  final double todayAmount;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final days = l.weekdayInitials.split(',');
    return AppCard(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.spendTitle,
                    style: AppText.ui(13, AppText.w4, color: AppColors.ink2),
                  ),
                  const SizedBox(height: 4),
                  Text(Money.format(total), style: AppText.ui(28, AppText.w8)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    l.spendSaved(Money.format(saved)),
                    textAlign: TextAlign.right,
                    style: AppText.ui(13.5, AppText.w8, color: AppColors.gnv),
                  ),
                  Text(
                    l.spendWithGnv,
                    style: AppText.ui(13.5, AppText.w5, color: AppColors.ink2),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < barHeights.length; i++)
                    SizedBox(
                      width: 24,
                      height: 120,
                      // La columna de hoy mide más de 120: se desborda hacia arriba.
                      child: OverflowBox(
                        alignment: Alignment.bottomCenter,
                        maxWidth: double.infinity,
                        minHeight: 0,
                        maxHeight: double.infinity,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 14,
                              child: i == todayIndex
                                  ? Text(
                                      todayAmount.toStringAsFixed(1),
                                      softWrap: false,
                                      style: AppText.ui(
                                        11.5,
                                        AppText.w7,
                                        height: 1.2,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: 24,
                              height: barHeights[i],
                              decoration: BoxDecoration(
                                color: i == todayIndex
                                    ? AppColors.primary
                                    : AppColors.primaryTrack,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              days[i],
                              style: AppText.ui(
                                11.5,
                                i == todayIndex ? AppText.w7 : AppText.w4,
                                color: i == todayIndex
                                    ? AppColors.ink
                                    : AppColors.ink3,
                              ),
                            ),
                          ],
                        ),
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
