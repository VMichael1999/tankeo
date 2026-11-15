import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Recipiente de combustible (gasolina naranja o GNV teal) lleno hasta [percent].
class FuelVessel extends StatelessWidget {
  const FuelVessel({
    super.key,
    required this.percent,
    required this.gnv,
    this.width = 46,
    this.height = 96,
  });

  final double percent;
  final bool gnv;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final top = gnv ? AppColors.gnvFillA : AppColors.gasVesselTop;
    final bottom = gnv ? AppColors.gnv : AppColors.primary;
    final surface = gnv ? AppColors.gnvVesselCap : AppColors.gasVesselCap;
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            const Positioned.fill(child: ColoredBox(color: AppColors.warmTile)),
            Positioned(
              top: -6,
              left: 16,
              right: 16,
              height: 10,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.vesselCap,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: height * (percent.clamp(0, 100) / 100),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [top, bottom],
                        ),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -width * .1,
                    right: -width * .1,
                    top: -6,
                    height: 12,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(width),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
