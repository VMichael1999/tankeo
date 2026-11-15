import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

void _paintText(
  Canvas canvas,
  String text,
  Offset anchor,
  TextStyle style, {
  TextAlign align = TextAlign.center,
}) {
  final tp = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
  )..layout();
  final base = tp.computeDistanceToActualBaseline(TextBaseline.alphabetic);
  final dx = align == TextAlign.center ? tp.width / 2 : 0.0;
  tp.paint(canvas, Offset(anchor.dx - dx, anchor.dy - base));
}

/// Ilustración del grifo (techo oscuro con franja naranja, dos surtidores y
/// panel de precios). Equivale al símbolo `station-ill` del prototipo
/// (360 × 190) y se recorta como `slice`.
class StationIllustration extends StatelessWidget {
  const StationIllustration({super.key, this.fit = BoxFit.cover});

  final BoxFit fit;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _StationPainter(fit),
    child: const SizedBox.expand(),
  );
}

class _StationPainter extends CustomPainter {
  _StationPainter(this.fit);

  final BoxFit fit;

  static const _w = 360.0;
  static const _h = 190.0;

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / _w, sy = size.height / _h;
    final s = fit == BoxFit.cover ? (sx > sy ? sx : sy) : (sx < sy ? sx : sy);
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.translate((size.width - _w * s) / 2, (size.height - _h * s) / 2);
    canvas.scale(s);
    _scene(canvas);
    canvas.restore();
  }

  void _scene(Canvas c) {
    Paint fill(Color col) => Paint()..color = col;
    RRect rr(double x, double y, double w, double h, double r) =>
        RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r));

    c.drawRect(const Rect.fromLTWH(0, 0, _w, _h), fill(AppColors.stationSky));
    c.drawRect(
      const Rect.fromLTWH(0, 132, _w, 58),
      fill(AppColors.stationFloor),
    );
    final lane = Paint()
      ..color = AppColors.stationLane
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    c.drawPath(
      Path()
        ..moveTo(70, 190)
        ..relativeLineTo(30, -58)
        ..moveTo(180, 190)
        ..relativeLineTo(0, -58)
        ..moveTo(290, 190)
        ..relativeLineTo(-30, -58),
      lane,
    );
    c.drawRRect(rr(18, 14, 290, 26, 4), fill(AppColors.stationRoof));
    c.drawRect(const Rect.fromLTWH(18, 40, 290, 6), fill(AppColors.primary));
    final pillar = Paint()
      ..color = AppColors.stationPillar
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    c.drawPath(
      Path()
        ..moveTo(70, 46)
        ..relativeLineTo(0, 86)
        ..moveTo(256, 46)
        ..relativeLineTo(0, 86),
      pillar,
    );
    paintPumpUnit(c, const Offset(104, 56));
    paintPumpUnit(c, const Offset(186, 56));
    c.drawRRect(rr(318, 20, 34, 112, 6), fill(AppColors.stationRoof));
    c.drawRRect(rr(322, 26, 26, 10, 2), fill(AppColors.primary));
    final price = AppText.mono(
      7.5,
      AppText.w6,
      color: AppColors.lcdTeal,
      height: 1,
    );
    _paintText(c, '1.69', const Offset(335, 54), price);
    _paintText(
      c,
      '17.99',
      const Offset(335, 72),
      price.copyWith(color: AppColors.lcdAmber),
    );
    _paintText(
      c,
      '21.49',
      const Offset(335, 90),
      price.copyWith(color: AppColors.lcdAmber),
    );
    _paintText(
      c,
      '22.42',
      const Offset(335, 108),
      price.copyWith(color: AppColors.white),
    );
    c.drawRect(const Rect.fromLTWH(331, 132, 8, 30), fill(AppColors.pumpPole));
  }

  /// Un surtidor de 46 × 80 (símbolo `pump-unit`).
  static void paintPumpUnit(Canvas c, Offset o) {
    c.save();
    c.translate(o.dx, o.dy);
    Paint fill(Color col) => Paint()..color = col;
    RRect rr(double x, double y, double w, double h, double r) =>
        RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r));
    c.drawRRect(rr(0, 0, 46, 80, 10), fill(AppColors.pumpBody));
    c.drawRRect(
      rr(.5, .5, 45, 79, 10),
      Paint()
        ..color = AppColors.pumpStroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    c.drawRRect(rr(0, 0, 46, 14, 7), fill(AppColors.primary));
    c.drawRect(const Rect.fromLTWH(0, 7, 46, 7), fill(AppColors.primary));
    c.drawRRect(rr(8, 20, 30, 16, 3), fill(AppColors.pumpScreen));
    c.drawRRect(rr(11, 25, 18, 3, 1.5), fill(AppColors.lcdAmber));
    c.drawRRect(rr(8, 44, 13, 6, 2), fill(AppColors.gnv));
    c.drawRRect(rr(25, 44, 13, 6, 2), fill(AppColors.primary));
    c.drawPath(
      Path()
        ..moveTo(44, 56)
        ..relativeCubicTo(12, 2, 12, 24, 0, 26),
      Paint()
        ..color = AppColors.pumpScreen
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    c.drawRRect(rr(6, 80, 34, 8, 2), fill(AppColors.pumpBase));
    c.restore();
  }

  @override
  bool shouldRepaint(_StationPainter old) => old.fit != fit;
}

/// Surtidor del login (pantalla con «19.01» y manguera), 300 × 190.
class LoginPumpIllustration extends StatelessWidget {
  const LoginPumpIllustration({super.key, this.amount = '19.01'});

  final String amount;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: const Size(300, 190),
    painter: _LoginPumpPainter(amount),
  );
}

class _LoginPumpPainter extends CustomPainter {
  _LoginPumpPainter(this.amount);

  final String amount;

  @override
  void paint(Canvas c, Size size) {
    c.translate(40, 4);
    Paint fill(Color col) => Paint()..color = col;
    RRect rr(double x, double y, double w, double h, double r) =>
        RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r));
    c.drawRRect(rr(0, 6, 66, 128, 14), fill(AppColors.loginPump));
    c.drawRRect(rr(0, 6, 66, 22, 11), fill(AppColors.primary));
    c.drawRect(const Rect.fromLTWH(0, 17, 66, 11), fill(AppColors.primary));
    c.drawRRect(rr(9, 38, 48, 30, 7), fill(AppColors.pumpScreen));
    _paintText(
      c,
      amount,
      const Offset(33, 58),
      AppText.mono(12, AppText.w6, color: AppColors.lcdAmber, height: 1),
    );
    c.drawRRect(rr(11, 78, 20, 8, 3), fill(AppColors.gnv));
    c.drawRRect(rr(35, 78, 20, 8, 3), fill(AppColors.primary));
    c.drawRRect(rr(18, 134, 30, 36, 4), fill(AppColors.loginPumpBase));
    c.drawPath(
      Path()
        ..moveTo(64, 70)
        ..relativeCubicTo(30, 2, 32, 52, 62, 62),
      Paint()
        ..color = AppColors.hose
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_LoginPumpPainter old) => old.amount != amount;
}

/// Pin del mapa: surtidor con techo naranja, luz verde (libre) o roja (lleno)
/// y, encima, la píldora con el precio del combustible filtrado.
/// El origen es el centro de la base; ocupa 62 × 71.
class PumpPin extends StatelessWidget {
  const PumpPin({
    super.key,
    required this.label,
    required this.best,
    required this.free,
  });

  static const width = 62.0;
  static const height = 71.0;

  final String label;
  final bool best;
  final bool free;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: const Size(width, height),
    painter: PumpPinPainter(label, best, free),
  );
}

class PumpPinPainter extends CustomPainter {
  PumpPinPainter(this.label, this.best, this.free);

  final String label;
  final bool best;
  final bool free;

  @override
  void paint(Canvas c, Size size) {
    // Origen SVG (0,0) = centro de la base del pin.
    c.translate(31, 67);
    Paint fill(Color col) => Paint()..color = col;
    RRect rr(double x, double y, double w, double h, double r) =>
        RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r));
    c.drawOval(
      const Rect.fromLTWH(-13, -3.5, 26, 7),
      fill(AppColors.black.withValues(alpha: .15)),
    );
    c.drawRRect(rr(-13, -40, 26, 38, 7), fill(AppColors.white));
    c.drawRRect(
      rr(-12.5, -39.5, 25, 37, 7),
      Paint()
        ..color = AppColors.pinStroke
        ..style = PaintingStyle.stroke,
    );
    c.drawRRect(rr(-13, -40, 26, 9, 4.5), fill(AppColors.primary));
    c.drawRect(const Rect.fromLTWH(-13, -36, 26, 5), fill(AppColors.primary));
    c.drawRRect(rr(-8, -27, 16, 9, 2), fill(AppColors.pumpScreen));
    c.drawRRect(rr(-5, -24, 9, 2, 1), fill(AppColors.lcdAmber));
    c.drawRRect(rr(-8, -14, 7, 3, 1.5), fill(AppColors.gnv));
    c.drawRRect(
      rr(1, -14, 7, 3, 1.5),
      fill(free ? AppColors.successLight : AppColors.danger),
    );
    c.drawPath(
      Path()
        ..moveTo(12, -20)
        ..relativeCubicTo(7, 1, 7, 15, 0, 17),
      Paint()
        ..color = AppColors.pumpScreen
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );
    c.drawRRect(
      rr(-31, -67, 62, 22, 11),
      fill(best ? AppColors.primary : AppColors.pinPill),
    );
    _paintText(
      c,
      label,
      const Offset(0, -52),
      AppText.ui(11, AppText.w7, color: AppColors.white, height: 1),
    );
  }

  @override
  bool shouldRepaint(PumpPinPainter old) =>
      old.label != label || old.best != best || old.free != free;
}
