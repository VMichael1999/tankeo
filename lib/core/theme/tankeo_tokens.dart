import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Tokens de diseño de Tankeo expuestos como [ThemeExtension].
@immutable
class TankeoTokens extends ThemeExtension<TankeoTokens> {
  const TankeoTokens({
    this.primary = AppColors.primary,
    this.primarySoft = AppColors.primarySoft,
    this.gnv = AppColors.gnv,
    this.gnvSoft = AppColors.gnvSoft,
    this.premium = AppColors.premium,
    this.diesel = AppColors.diesel,
    this.ink = AppColors.ink,
    this.ink2 = AppColors.ink2,
    this.ink3 = AppColors.ink3,
    this.bg = AppColors.bg,
    this.card = AppColors.card,
    this.line = AppColors.line,
    this.navPill = AppColors.navPill,
    this.paper = AppColors.paper,
    this.success = AppColors.success,
    this.danger = AppColors.danger,
  });

  final Color primary;
  final Color primarySoft;
  final Color gnv;
  final Color gnvSoft;
  final Color premium;
  final Color diesel;
  final Color ink;
  final Color ink2;
  final Color ink3;
  final Color bg;
  final Color card;
  final Color line;
  final Color navPill;
  final Color paper;
  final Color success;
  final Color danger;

  // Radios
  static const double rButton = 16;
  static const double rCard = 24;
  static const double rStationCard = 26;
  static const double rSheetTop = 34;
  static const double rDialog = 26;
  static const double rLcd = 24;
  static const double rChip = 19;

  // Alturas
  static const double hButton = 58;
  static const double hSegment = 54;
  static const double hChip = 38;
  static const double hAmount = 46;
  static const double navWidth = 316;
  static const double navHeight = 64;
  static const double navBottom = 28;
  static const double navHeightCompact = 52;

  // Lienzo de diseño (iPhone 16 Pro Max)
  static const double designWidth = 440;

  /// Degradado vertical del relleno de gasolina.
  static const LinearGradient gasFill = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.gasFillA, AppColors.gasFillB, AppColors.gasFillC],
    stops: [0, .45, 1],
  );

  /// Degradado vertical del relleno de GNV.
  static const LinearGradient gnvFill = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.gnvFillA, AppColors.gnvFillB, AppColors.gnvFillC],
    stops: [0, .45, 1],
  );

  static const LinearGradient lcd = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.lcdTop, AppColors.lcdBottom],
  );

  static const RadialGradient splash = RadialGradient(
    center: Alignment(0, -.1),
    radius: 1.05,
    colors: [AppColors.splashA, AppColors.splashB, AppColors.splashC],
    stops: [0, .55, 1],
  );

  static const RadialGradient loginHero = RadialGradient(
    center: Alignment(.4, -.2),
    radius: 1.1,
    colors: [AppColors.loginHeroA, AppColors.loginHeroB, AppColors.loginHeroC],
    stops: [0, .6, 1],
  );

  static const LinearGradient receipt = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.receiptA, AppColors.receiptB, AppColors.receiptC],
    stops: [0, .5, 1],
  );

  static const LinearGradient homeHeader = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.homeHdrA, AppColors.homeHdrB],
  );

  static TankeoTokens of(BuildContext context) =>
      Theme.of(context).extension<TankeoTokens>() ?? const TankeoTokens();

  @override
  TankeoTokens copyWith() => this;

  @override
  TankeoTokens lerp(ThemeExtension<TankeoTokens>? other, double t) => this;
}

extension TankeoTokensContext on BuildContext {
  TankeoTokens get tokens => TankeoTokens.of(this);
}
