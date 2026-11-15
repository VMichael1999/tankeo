import 'package:flutter/material.dart';

import '../domain/fuel_type.dart';
import '../icons/icons.dart';
import '../l10n/l10n.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../theme/app_text.dart';
import '../theme/tankeo_tokens.dart';
import '../utils/money.dart';
import '../../features/stations/domain/station.dart';
import 'station_illustration.dart';

/// Tarjeta del carrusel: miniatura, nombre, precio del combustible filtrado,
/// surtidores libres, reseña y las acciones de compartir e ir al detalle.
class StationCard extends StatelessWidget {
  const StationCard({
    super.key,
    required this.station,
    required this.fuel,
    required this.cheapest,
    required this.onTap,
    required this.onShare,
    required this.onGo,
  });

  final Station station;
  final FuelType fuel;
  final bool cheapest;
  final VoidCallback onTap;
  final VoidCallback onShare;
  final VoidCallback onGo;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = context.l10n;
    final priceColor = fuel == FuelType.diesel ? t.ink : fuel.color(t);
    return Semantics(
      label: station.name,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: 350,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(TankeoTokens.rStationCard),
            boxShadow: AppShadows.stationCard,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: const SizedBox(
                        width: 92,
                        height: 76,
                        child: StationIllustration(),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text.rich(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            TextSpan(
                              text: station.name,
                              style: AppText.ui(16.5, AppText.w7, height: 1.25),
                              children: [
                                if (cheapest) ...[
                                  const WidgetSpan(child: SizedBox(width: 6)),
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: _BestPill(label: l.cheapestTag),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text.rich(
                            TextSpan(
                              style: AppText.ui(
                                13.5,
                                AppText.w6,
                                color: priceColor,
                              ),
                              children: [
                                TextSpan(
                                  text: Money.format(station.priceOf(fuel)),
                                ),
                                TextSpan(
                                  text: '/${fuel.unit}',
                                  style: AppText.ui(
                                    13.5,
                                    AppText.w5,
                                    color: t.ink2,
                                  ),
                                ),
                                TextSpan(
                                  text: ' • ',
                                  style: AppText.ui(
                                    13.5,
                                    AppText.w6,
                                    color: t.ink3,
                                  ),
                                ),
                                station.hasFreePumps
                                    ? TextSpan(
                                        text: l.pumpsFree(
                                          station.freePumps,
                                          station.totalPumps,
                                        ),
                                        style: AppText.ui(
                                          13.5,
                                          AppText.w6,
                                          color: t.ink2,
                                        ),
                                      )
                                    : TextSpan(
                                        text: l.pumpsAllBusy,
                                        style: AppText.ui(
                                          13.5,
                                          AppText.w6,
                                          color: t.danger,
                                        ),
                                      ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const AppIconView(
                                AppIcon.starFilled,
                                size: 13,
                                color: AppColors.starOn,
                                solid: true,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  l.ratingLine(
                                    station.rating.toString(),
                                    station.driveMinutes,
                                    station.distanceKm.toString(),
                                  ),
                                  style: AppText.ui(
                                    12.5,
                                    AppText.w4,
                                    color: t.ink2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 14, 14),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.line)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.grayChip,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: AppIconView(
                          AppIcon.pin,
                          size: 18,
                          color: AppColors.ink2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.addressLabel,
                            style: AppText.ui(11.5, AppText.w4, color: t.ink2),
                          ),
                          Text(
                            station.address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.ui(14.5, AppText.w6),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Semantics(
                      button: true,
                      label: l.share,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onShare,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: AppColors.grayChip,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: AppIconView(
                              AppIcon.share,
                              size: 19,
                              color: AppColors.ink2,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Semantics(
                      button: true,
                      label: l.viewDetail,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onGo,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: t.primary,
                            shape: BoxShape.circle,
                            boxShadow: AppShadows.orangeRound,
                          ),
                          child: const Center(
                            child: AppIconView(
                              AppIcon.send,
                              size: 19,
                              color: AppColors.white,
                            ),
                          ),
                        ),
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

class _BestPill extends StatelessWidget {
  const _BestPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    height: 20,
    padding: const EdgeInsets.symmetric(horizontal: 8),
    decoration: BoxDecoration(
      color: AppColors.primarySoft,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Center(
      widthFactor: 1,
      child: Text(
        label,
        style: AppText.ui(11, AppText.w7, color: AppColors.primary, height: 1),
      ),
    ),
  );
}

/// Pastilla «Más barato» reutilizable.
class CheapestPill extends StatelessWidget {
  const CheapestPill({super.key});

  @override
  Widget build(BuildContext context) =>
      _BestPill(label: context.l10n.cheapestTag);
}
