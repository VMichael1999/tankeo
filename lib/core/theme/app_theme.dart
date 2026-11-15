import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text.dart';
import 'tankeo_tokens.dart';

abstract final class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: AppFonts.ui,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.card,
      ),
      splashFactory: NoSplash.splashFactory,
      highlightColor: AppColors.black.withValues(alpha: 0),
      extensions: const [TankeoTokens()],
    );
    return base.copyWith(
      textTheme: base.textTheme.apply(
        fontFamily: AppFonts.ui,
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
      ),
    );
  }
}
