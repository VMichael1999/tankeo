import 'package:flutter/material.dart';

import '../../../core/icons/icons.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/app_switch.dart';
import '../../../core/widgets/primary_button.dart';
import '../domain/station.dart';
import '../domain/station_filter.dart';

/// Hoja de filtros del mapa: surtidores libres, pago en app, distancia
/// máxima y servicios. El botón dice cuántos grifos coinciden.
Future<StationFilter?> showFilterSheet(
  BuildContext context, {
  required StationFilter initial,
  required List<Station> stations,
}) {
  return showModalBottomSheet<StationFilter>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.loginSheet,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    builder: (_) => _FilterSheet(initial: initial, stations: stations),
  );
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.initial, required this.stations});

  final StationFilter initial;
  final List<Station> stations;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late StationFilter f = widget.initial;

  int get count => widget.stations.where(f.matches).length;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final n = count;
    final services = <(StationService, AppIcon, String)>[
      (StationService.store, AppIcon.store, l.amenityStore),
      (StationService.wash, AppIcon.drop, l.amenityWash),
      (StationService.atm, AppIcon.coin, l.amenityAtm),
      (StationService.air, AppIcon.wind, l.amenityAir),
    ];
    Widget row(String t, String sub, bool v, ValueChanged<bool> on) =>
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t, style: AppText.ui(15, AppText.w7)),
                    Text(
                      sub,
                      style: AppText.ui(
                        12.5,
                        AppText.w4,
                        color: AppColors.ink2,
                      ),
                    ),
                  ],
                ),
              ),
              AppSwitch(value: v, onChanged: on),
            ],
          ),
        );
    Widget chip(String label, bool on, VoidCallback tap, {AppIcon? icon}) =>
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: tap,
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: on ? AppColors.ink : AppColors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: on ? AppColors.ink : AppColors.chipBorder,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  AppIconView(
                    icon,
                    size: 15,
                    color: on ? AppColors.white : AppColors.ink,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: AppText.ui(
                    13,
                    AppText.w6,
                    color: on ? AppColors.white : AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
        );
    Widget lbl(String t) => Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 10),
      child: Text(t, style: AppText.ui(13, AppText.w7, color: AppColors.ink2)),
    );
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 5,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.checkBorder,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l.filterTitle, style: AppText.ui(20, AppText.w8)),
                GestureDetector(
                  onTap: () => setState(
                    () => f = f.copyWith(
                      onlyFree: false,
                      clearMaxKm: true,
                      services: {},
                    ),
                  ),
                  child: Text(
                    l.filterClear,
                    style: AppText.ui(
                      13.5,
                      AppText.w7,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            row(
              l.filterFree,
              l.filterFreeSub,
              f.onlyFree,
              (v) => setState(() => f = f.copyWith(onlyFree: v)),
            ),
            row(
              l.filterApp,
              l.filterAppSub,
              f.appPayment,
              (v) => setState(() => f = f.copyWith(appPayment: v)),
            ),
            lbl(l.filterDistance),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                chip(
                  '2 km',
                  f.maxKm == 2,
                  () => setState(() => f = f.copyWith(maxKm: 2)),
                ),
                chip(
                  '5 km',
                  f.maxKm == 5,
                  () => setState(() => f = f.copyWith(maxKm: 5)),
                ),
                chip(
                  l.filterAll,
                  f.maxKm == null,
                  () => setState(() => f = f.copyWith(clearMaxKm: true)),
                ),
              ],
            ),
            lbl(l.filterServices),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final (svc, icon, label) in services)
                  chip(label, f.services.contains(svc), () {
                    final next = {...f.services};
                    next.contains(svc) ? next.remove(svc) : next.add(svc);
                    setState(() => f = f.copyWith(services: next));
                  }, icon: icon),
              ],
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: n == 0
                  ? l.filterNone
                  : l.filterShow(
                      n,
                      n == 1 ? l.filterStationOne : l.filterStationMany,
                    ),
              color: AppColors.primary,
              height: 56,
              onPressed: n == 0 ? null : () => Navigator.of(context).pop(f),
            ),
          ],
        ),
      ),
    );
  }
}
