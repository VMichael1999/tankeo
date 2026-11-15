import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Imagen con sombra proyectada siguiendo su silueta
/// (`filter: drop-shadow(0 Ypx Bpx color)` del prototipo).
class DropShadowImage extends StatelessWidget {
  const DropShadowImage({
    super.key,
    required this.asset,
    required this.shadowColor,
    this.offsetY = 14,
    this.blur = 14,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
  });

  final String asset;
  final Color shadowColor;
  final double offsetY;

  /// Radio de desenfoque CSS (la sigma es la mitad).
  final double blur;
  final BoxFit fit;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    Widget image() => Image.asset(
      asset,
      fit: fit,
      alignment: alignment,
      gaplessPlayback: true,
    );
    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        Transform.translate(
          offset: Offset(0, offsetY),
          child: ImageFiltered(
            imageFilter: ui.ImageFilter.blur(
              sigmaX: blur / 2,
              sigmaY: blur / 2,
            ),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(shadowColor, BlendMode.srcIn),
              child: image(),
            ),
          ),
        ),
        image(),
      ],
    );
  }
}

/// Rutas de los assets de imagen.
abstract final class AppImages {
  static const carSide = 'assets/images/car_side.png';

  /// McLaren F1 visto desde arriba, horizontal (frente a la izquierda).
  static const carTop = 'assets/images/car_top.webp';

  /// McLaren F1 visto desde arriba, vertical (frente arriba).
  static const carTopVertical = 'assets/images/car_topv.webp';

  /// Logos oficiales de los accesos sociales del login.
  static const logoGoogle = 'assets/images/logo_google.png';
  static const logoApple = 'assets/images/logo_apple.png';
  static const logoFacebook = 'assets/images/logo_facebook.png';
}
