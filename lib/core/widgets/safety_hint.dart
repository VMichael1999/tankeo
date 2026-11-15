import 'package:flutter/material.dart';

import '../icons/icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Tarjeta gris con escudo y la indicación de seguridad de la carga.
class SafetyHint extends StatelessWidget {
  const SafetyHint({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: AppColors.grayTile,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 1),
          child: AppIconView(AppIcon.shield, size: 18, color: AppColors.ink),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: AppText.ui(
              13,
              AppText.w4,
              color: AppColors.ink2,
              height: 1.4,
            ),
          ),
        ),
      ],
    ),
  );
}
