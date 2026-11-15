import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Cuatro columnas con el número del surtidor, sus combustibles y su estado.
class PumpGrid extends StatelessWidget {
  const PumpGrid({super.key, required this.total, required this.free});

  final int total;
  final int free;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return LayoutBuilder(
      builder: (context, c) {
        final w = (c.maxWidth - 24) / 4;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var k = 0; k < total; k++)
              _Pump(
                width: w,
                number: ((k * 5) % total) + 1,
                free: k < free,
                fuels: ((k * 5) % total + 1).isOdd
                    ? l.pumpFuelsGnv
                    : l.pumpFuelsLiquid,
                freeLabel: l.pumpFree,
                busyLabel: l.pumpBusy,
              ),
          ],
        );
      },
    );
  }
}

class _Pump extends StatelessWidget {
  const _Pump({
    required this.width,
    required this.number,
    required this.free,
    required this.fuels,
    required this.freeLabel,
    required this.busyLabel,
  });

  final double width;
  final int number;
  final bool free;
  final String fuels;
  final String freeLabel;
  final String busyLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.grayTile,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            '$number',
            style: AppText.ui(
              20,
              AppText.w8,
              color: free ? AppColors.ink : AppColors.ink3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            fuels,
            textAlign: TextAlign.center,
            style: AppText.ui(11, AppText.w4, color: AppColors.ink2),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: free ? AppColors.successSoft : AppColors.dangerSoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              free ? freeLabel : busyLabel,
              style: AppText.ui(
                11,
                AppText.w7,
                color: free ? AppColors.success : AppColors.danger,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
