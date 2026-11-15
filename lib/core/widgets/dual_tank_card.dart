import 'package:flutter/material.dart';

import '../domain/fuel_type.dart';
import '../icons/icons.dart';
import '../l10n/l10n.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../utils/volume_format.dart';
import 'app_card.dart';
import 'fuel_vessel.dart';

/// Tarjeta «Combustible» con los dos recipientes: gasolina y GNV, cada uno con
/// su porcentaje, su volumen y la autonomía total debajo.
class DualTankCard extends StatelessWidget {
  const DualTankCard({
    super.key,
    required this.gasolinePercent,
    required this.gnvPercent,
    required this.totalRange,
  });

  final int gasolinePercent;
  final int gnvPercent;
  final int totalRange;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final gasGal = TankKind.gasoline.capacity * gasolinePercent / 100;
    final gnvM3 = TankKind.gnv.capacity * gnvPercent / 100;
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l.homeFuelTitle, style: AppText.ui(16, AppText.w7)),
              const AppIconView(AppIcon.chev, size: 17, color: AppColors.ink),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            l.homeLastCharge,
            style: AppText.ui(12.5, AppText.w4, color: AppColors.ink2),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Column(
                  percent: gasolinePercent,
                  gnv: false,
                  detail: l.homeVolumeOf(
                    VolumeFormat.d1(gasGal),
                    VolumeFormat.format(TankKind.gasoline.capacity, digits: 0),
                    TankKind.gasoline.unit,
                  ),
                  tag: l.fuelGasoline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Column(
                  percent: gnvPercent,
                  gnv: true,
                  detail: l.homeVolumeOf(
                    VolumeFormat.d1(gnvM3),
                    VolumeFormat.format(TankKind.gnv.capacity, digits: 0),
                    TankKind.gnv.unit,
                  ),
                  tag: l.fuelGnv,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const ColoredBox(
            color: AppColors.line,
            child: SizedBox(height: 1, width: double.infinity),
          ),
          const SizedBox(height: 10),
          Text.rich(
            TextSpan(
              text: '${l.homeTotalRange} ',
              style: AppText.ui(12.5, AppText.w4, color: AppColors.ink2),
              children: [
                TextSpan(
                  text: l.kmValue(totalRange),
                  style: AppText.ui(15, AppText.w8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Column extends StatelessWidget {
  const _Column({
    required this.percent,
    required this.gnv,
    required this.detail,
    required this.tag,
  });

  final int percent;
  final bool gnv;
  final String detail;
  final String tag;

  @override
  Widget build(BuildContext context) {
    final soft = gnv ? AppColors.gnvSoft : AppColors.primarySoft;
    final fg = gnv ? AppColors.gnv : AppColors.primary;
    return Column(
      children: [
        FuelVessel(percent: percent.toDouble(), gnv: gnv),
        const SizedBox(height: 8),
        Text('$percent%', style: AppText.ui(19, AppText.w8, height: 1)),
        const SizedBox(height: 8),
        Text(
          detail,
          textAlign: TextAlign.center,
          style: AppText.ui(
            11.5,
            AppText.w4,
            color: AppColors.ink2,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: soft,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(tag, style: AppText.ui(11, AppText.w7, color: fg)),
        ),
      ],
    );
  }
}
