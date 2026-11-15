import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/icons/icons.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/account_widgets.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/drop_shadow_image.dart';
import '../bloc/vehicles_cubit.dart';
import '../domain/account_models.dart';

/// Mis vehículos: tarjetas con foto, placa peruana, tanque y certificación.
class VehiclesScreen extends StatelessWidget {
  const VehiclesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cubit = context.watch<VehiclesCubit>();
    final list = cubit.state;
    return AccountScaffold(
      title: l.vehiclesTitle,
      body: Column(
        children: [
          for (var i = 0; i < list.length; i++)
            VehicleCard(
              vehicle: list[i],
              inUse: i == cubit.inUse,
              onUse: () => cubit.use(i),
            ),
          const SizedBox(height: 4),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => context.push('/vehicles/add'),
            child: CustomPaint(
              painter: _Dashed(),
              child: SizedBox(
                height: 62,
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const AppIconView(
                      AppIcon.plus,
                      size: 19,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l.vehicleAdd,
                      style: AppText.ui(
                        15,
                        AppText.w7,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VehicleCard extends StatelessWidget {
  const VehicleCard({
    required this.vehicle,
    required this.inUse,
    required this.onUse,
  });

  final AccountVehicle vehicle;
  final bool inUse;
  final VoidCallback onUse;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final v = vehicle;
    final fuel = switch (v.fuel) {
      VehicleFuel.dual => l.vehicleFuelDual,
      VehicleFuel.gasoline => l.vehicleFuelGasoline,
      VehicleFuel.gnv => l.vehicleFuelGnv,
    };
    return AppCard(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Image.asset(
              AppImages.carSide,
              height: 110,
              semanticLabel: l.carSemantic,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${v.name} ${v.year}',
                      style: AppText.ui(18, AppText.w8),
                    ),
                    Text(
                      fuel,
                      style: AppText.ui(13, AppText.w4, color: AppColors.ink2),
                    ),
                  ],
                ),
              ),
              PlateBadge(v.plate),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (inUse)
                _Tag(l.vehicleInUse, AppColors.success, AppColors.successSoft)
              else
                GestureDetector(
                  onTap: onUse,
                  child: _Tag(
                    l.vehicleUse,
                    AppColors.primary,
                    AppColors.primarySoft,
                  ),
                ),
              if (v.hasGasoline)
                _Tag(
                  l.vehicleTankGas(v.gasLevel),
                  AppColors.primary,
                  AppColors.primarySoft,
                ),
              if (v.hasGnv)
                _Tag(
                  '${v.cylinder ?? ''} · ${l.vehicleTankGnv(v.gnvLevel)}',
                  AppColors.gnv,
                  AppColors.gnvSoft,
                ),
              _Tag(
                v.certified ? l.vehicleCertOk : l.vehicleCertNone,
                v.certified ? AppColors.gnv : AppColors.ink2,
                v.certified ? AppColors.gnvSoft : AppColors.grayChip,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.text, this.fg, this.bg);

  final String text;
  final Color fg;
  final Color bg;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Text(text, style: AppText.ui(12.5, AppText.w7, color: fg)),
  );
}

/// Placa peruana: fondo blanco, marco oscuro y «PERÚ» en rojo.
class PlateBadge extends StatelessWidget {
  const PlateBadge(this.plate);

  final String plate;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(12, 3, 12, 5),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppColors.ink, width: 2),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'PERÚ',
          style: AppText.ui(
            8,
            AppText.w8,
            color: AppColors.danger,
            letterSpacing: 1.4,
            height: 1,
          ),
        ),
        Text(
          plate,
          style: AppText.mono(
            17,
            FontWeight.w600,
            letterSpacing: 1.5,
            height: 1.15,
          ),
        ),
      ],
    ),
  );
}

class _Dashed extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(20),
    );
    final path = Path()..addRRect(r);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = AppColors.primaryBorder;
    for (final m in path.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 12) {
        canvas.drawPath(m.extractPath(d, d + 6), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
