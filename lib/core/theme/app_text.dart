import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Familias tipográficas.
abstract final class AppFonts {
  static const ui = 'PlusJakartaSans';
  static const mono = 'IBMPlexMono';
}

/// Construye estilos con las medidas del prototipo (interlineado 1.3 por defecto).
abstract final class AppText {
  static TextStyle ui(
    double size,
    FontWeight weight, {
    Color color = AppColors.ink,
    double height = 1.3,
    double? letterSpacing,
    FontStyle? fontStyle,
  }) => TextStyle(
    fontFamily: AppFonts.ui,
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
    fontStyle: fontStyle,
  );

  static TextStyle mono(
    double size,
    FontWeight weight, {
    Color color = AppColors.ink,
    double height = 1.3,
    double? letterSpacing,
    List<Shadow>? shadows,
  }) => TextStyle(
    fontFamily: AppFonts.mono,
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
    shadows: shadows,
  );

  static const w4 = FontWeight.w400;
  static const w5 = FontWeight.w500;
  static const w6 = FontWeight.w600;
  static const w7 = FontWeight.w700;
  static const w8 = FontWeight.w800;
}
