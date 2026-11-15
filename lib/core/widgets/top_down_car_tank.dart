import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../theme/tankeo_tokens.dart';
import 'drop_shadow_image.dart';

/// El auto visto desde arriba (frente a la izquierda) como depósito.
///
/// Lleva dos capas recortadas con la silueta real del auto: el **nivel
/// objetivo** al 32 % de opacidad y el **nivel actual** en color pleno, que
/// crece de la parte trasera (derecha) hacia el frente con un borde claro.
/// La manguera sale de la tapa trasera al conectar.
class TopDownCarTank extends StatefulWidget {
  const TopDownCarTank({
    super.key,
    required this.level,
    required this.targetLevel,
    required this.gnv,
    required this.plugged,
  });

  static const width = 300.0;
  static const height = 160.0;

  /// Nivel actual, de 0 a 100.
  final double level;

  /// Nivel objetivo (el que se alcanzará al terminar la carga).
  final double targetLevel;
  final bool gnv;

  /// ¿Está conectada la manguera?
  final bool plugged;

  @override
  State<TopDownCarTank> createState() => _TopDownCarTankState();
}

class _TopDownCarTankState extends State<TopDownCarTank> {
  ui.Image? _image;
  ImageStream? _stream;
  late final ImageStreamListener _listener = ImageStreamListener(
    (info, _) => setState(() => _image = info.image),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _stream?.removeListener(_listener);
    _stream = const AssetImage(
      AppImages.carTop,
    ).resolve(createLocalImageConfiguration(context))..addListener(_listener);
  }

  @override
  void dispose() {
    _stream?.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lvl = widget.level.clamp(0, 100).toDouble();
    return SizedBox(
      width: TopDownCarTank.width,
      height: TopDownCarTank.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _CarTankPainter(
                image: _image,
                level: lvl,
                target: widget.targetLevel.clamp(0, 100).toDouble(),
                gnv: widget.gnv,
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: widget.plugged ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                child: CustomPaint(painter: _HosePainter()),
              ),
            ),
          ),
          Positioned(
            left: TopDownCarTank.width * (1 - lvl / 200),
            top: TopDownCarTank.height / 2,
            child: FractionalTranslation(
              translation: const Offset(-.5, -.5),
              child: Text(
                '${lvl.round()}%',
                style:
                    AppText.ui(
                      22,
                      AppText.w8,
                      color: AppColors.white,
                      height: 1,
                    ).copyWith(
                      shadows: [
                        Shadow(
                          color: AppColors.pctShadow.withValues(alpha: .6),
                          blurRadius: 8,
                          offset: const Offset(0, 1),
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

class _CarTankPainter extends CustomPainter {
  _CarTankPainter({
    required this.image,
    required this.level,
    required this.target,
    required this.gnv,
  });

  final ui.Image? image;
  final double level;
  final double target;
  final bool gnv;

  @override
  void paint(Canvas canvas, Size size) {
    final img = image;
    if (img == null) return;
    final dst = Offset.zero & size;
    final src = Rect.fromLTWH(
      0,
      0,
      img.width.toDouble(),
      img.height.toDouble(),
    );
    final imgPaint = Paint()..filterQuality = FilterQuality.high;

    // Sombra proyectada de la silueta.
    canvas.saveLayer(
      dst.inflate(40),
      Paint()..imageFilter = ui.ImageFilter.blur(sigmaX: 7, sigmaY: 7),
    );
    canvas.drawImageRect(
      img,
      src,
      dst.shift(const Offset(0, 12)),
      Paint()
        ..filterQuality = FilterQuality.high
        ..colorFilter = ColorFilter.mode(
          AppColors.inkField.withValues(alpha: .22),
          BlendMode.srcIn,
        ),
    );
    canvas.restore();

    canvas.drawImageRect(img, src, dst, imgPaint);

    final gradient = gnv ? TankeoTokens.gnvFill : TankeoTokens.gasFill;

    void fillLayer(double pct, double opacity, {bool edge = false}) {
      final x = size.width * (1 - math.min(100, pct) / 100);
      final region = Rect.fromLTRB(x, 0, size.width, size.height);
      canvas.saveLayer(
        dst,
        Paint()
          ..blendMode = BlendMode.multiply
          ..color = AppColors.white.withValues(alpha: opacity),
      );
      canvas.clipRect(region);
      canvas.saveLayer(dst, Paint());
      canvas.drawImageRect(img, src, dst, imgPaint);
      canvas.drawRect(
        dst,
        Paint()
          ..shader = gradient.createShader(dst)
          ..blendMode = BlendMode.srcIn,
      );
      if (edge) {
        canvas.drawRect(
          Rect.fromLTWH(x - 1.5, 0, 3, size.height),
          Paint()
            ..color = AppColors.gasEdge
            ..blendMode = BlendMode.srcATop,
        );
      }
      canvas.restore();
      canvas.restore();
    }

    fillLayer(target, .32);
    fillLayer(level, 1, edge: true);
  }

  @override
  bool shouldRepaint(_CarTankPainter old) =>
      old.image != image ||
      old.level != level ||
      old.target != target ||
      old.gnv != gnv;
}

class _HosePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = AppColors.hose
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(232, 150)
        ..cubicTo(236, 168, 270, 176, 340, 172),
      p,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(224, 144, 16, 11),
        const Radius.circular(3),
      ),
      Paint()..color = AppColors.hose,
    );
  }

  @override
  bool shouldRepaint(_HosePainter old) => false;
}
