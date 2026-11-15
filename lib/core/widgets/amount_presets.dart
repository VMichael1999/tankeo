import 'package:flutter/material.dart';

import '../../features/fueling/domain/amount_preset.dart';
import '../l10n/l10n.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../theme/tankeo_tokens.dart';
import '../utils/money.dart';
import '../utils/volume_format.dart';
import 'app_card.dart';

/// «¿Cuánto cargar?»: cuatro botones de 46 de alto, cuánto cabe y el
/// estimado `volumen × precio` con el total en el color del combustible.
class AmountPresets extends StatelessWidget {
  const AmountPresets({
    super.key,
    required this.presets,
    required this.selected,
    required this.enabledFor,
    required this.onSelected,
    required this.capacityLabel,
    required this.estimateVolume,
    required this.unit,
    required this.price,
    required this.total,
    required this.totalColor,
  });

  final List<AmountPreset> presets;
  final AmountPreset selected;

  /// ¿Se puede elegir este monto? Uno mayor a lo que cabe se deshabilita.
  final bool Function(AmountPreset) enabledFor;
  final ValueChanged<AmountPreset> onSelected;
  final String capacityLabel;
  final double estimateVolume;
  final String unit;
  final double price;
  final double total;
  final Color totalColor;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l.chargeHowMuch, style: AppText.ui(15.5, AppText.w7)),
              Text(
                capacityLabel,
                style: AppText.ui(14, AppText.w4, color: AppColors.ink2),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final (i, p) in presets.indexed) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _Amount(
                    preset: p,
                    on: p == selected,
                    enabled: enabledFor(p),
                    onTap: () => onSelected(p),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.only(top: 10),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.line)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${VolumeFormat.d3(estimateVolume)} $unit × ${Money.format(price)}',
                  style: AppText.ui(13.5, AppText.w4, color: AppColors.ink2),
                ),
                Text(
                  Money.format(total),
                  style: AppText.ui(20, AppText.w8, color: totalColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Amount extends StatelessWidget {
  const _Amount({
    required this.preset,
    required this.on,
    required this.enabled,
    required this.onTap,
  });

  final AmountPreset preset;
  final bool on;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = preset.isFull
        ? context.l10n.chargeFull
        : Money.format(preset.amount!).replaceAll('.00', '');
    return Semantics(
      button: true,
      selected: on,
      enabled: enabled,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? onTap : null,
        child: Opacity(
          opacity: enabled ? 1 : .35,
          child: Container(
            height: TankeoTokens.hAmount,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: on ? context.tokens.ink : AppColors.grayChip,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Text(
              label,
              style: AppText.ui(
                14.5,
                AppText.w7,
                color: on ? AppColors.white : context.tokens.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
