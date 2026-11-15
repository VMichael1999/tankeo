import 'package:flutter/painting.dart';

/// Sombras del prototipo.
abstract final class AppShadows {
  static const _slate = Color(0x5A0F172A); // rgba(15,23,42,.35)

  /// Botones redondos, píldoras y chips flotantes sobre el mapa.
  static const floating = [
    BoxShadow(
      color: _slate,
      blurRadius: 16,
      offset: Offset(0, 6),
      spreadRadius: -8,
    ),
  ];

  /// Tarjetas del carrusel de grifos.
  static const stationCard = [
    BoxShadow(
      color: Color(0x730F172A),
      blurRadius: 30,
      offset: Offset(0, 14),
      spreadRadius: -18,
    ),
  ];

  /// Chips de filtro.
  static const chip = [
    BoxShadow(
      color: Color(0x730F172A),
      blurRadius: 16,
      offset: Offset(0, 6),
      spreadRadius: -10,
    ),
  ];

  /// Campos del login y botones sociales.
  static const field = [
    BoxShadow(
      color: Color(0x400F172A),
      blurRadius: 18,
      offset: Offset(0, 6),
      spreadRadius: -12,
    ),
  ];

  static const nav = [
    BoxShadow(
      color: Color(0x8C000000),
      blurRadius: 30,
      offset: Offset(0, 14),
      spreadRadius: -14,
    ),
  ];

  static const bottomBar = [
    BoxShadow(
      color: Color(0x59000000),
      blurRadius: 30,
      offset: Offset(0, -10),
      spreadRadius: -20,
    ),
  ];

  static const detailBar = [
    BoxShadow(
      color: Color(0x66000000),
      blurRadius: 24,
      offset: Offset(0, -12),
      spreadRadius: -20,
    ),
  ];

  static const orangeButton = [
    BoxShadow(
      color: Color(0xE6F2620F),
      blurRadius: 22,
      offset: Offset(0, 12),
      spreadRadius: -12,
    ),
  ];

  static const orangeRound = [
    BoxShadow(
      color: Color(0xCCF2620F),
      blurRadius: 16,
      offset: Offset(0, 8),
      spreadRadius: -8,
    ),
  ];

  static const lcd = [
    BoxShadow(
      color: Color(0x99000000),
      blurRadius: 30,
      offset: Offset(0, 18),
      spreadRadius: -18,
    ),
  ];

  static const ctaSoft = [
    BoxShadow(
      color: Color(0x40000000),
      blurRadius: 12,
      offset: Offset(0, 4),
      spreadRadius: -6,
    ),
  ];

  static const printer = [
    BoxShadow(
      color: Color(0x99000000),
      blurRadius: 18,
      offset: Offset(0, 8),
      spreadRadius: -8,
    ),
  ];

  static const toggle = [
    BoxShadow(color: Color(0x33000000), blurRadius: 4, offset: Offset(0, 2)),
  ];
}
