import 'package:flutter/material.dart';

import '../domain/fuel_type.dart';
import '../l10n/fuel_l10n.dart';
import '../l10n/l10n.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../theme/tankeo_tokens.dart';
import '../utils/money.dart';
import 'station_card.dart';

/// Una fila por combustible: punto de color, nombre, «Más barato», precio y
/// unidad. La fila filtrada va resaltada y el diésel atenuado.
class FuelPriceList extends StatelessWidget {
  const FuelPriceList({
    super.key,
    required this.prices,
    required this.selected,
    required this.cheapestFuels,
  });

  final Map<FuelType, double> prices;
  final FuelType selected;

  /// Combustibles en los que este grifo es el más barato.
  final Set<FuelType> cheapestFuels;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.lineSoft),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                for (final (i, f) in FuelType.values.indexed)
                  Opacity(
                    opacity: f == FuelType.diesel ? .45 : 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 13,
                      ),
                      decoration: BoxDecoration(
                        color: f == selected ? AppColors.primaryTint : null,
                        border: i == 0
                            ? null
                            : const Border(
                                top: BorderSide(color: AppColors.lineSoft),
                              ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: f.color(t),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              f.longLabel(context),
                              style: AppText.ui(14.5, AppText.w6),
                            ),
                          ),
                          if (cheapestFuels.contains(f)) ...[
                            const CheapestPill(),
                            const SizedBox(width: 12),
                          ],
                          Text(
                            Money.format(prices[f]!),
                            style: AppText.ui(14.5, AppText.w7),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '/${f.unit}',
                            style: AppText.ui(12, AppText.w4, color: t.ink2),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l.pricesIncludeIgv,
          style: AppText.ui(11.5, AppText.w4, color: t.ink3),
        ),
      ],
    );
  }
}
