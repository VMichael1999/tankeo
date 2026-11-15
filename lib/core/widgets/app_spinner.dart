import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Anillo giratorio: pista suave con un arco de color (el `.spin` del prototipo).
class AppSpinner extends StatefulWidget {
  const AppSpinner({
    super.key,
    this.size = 22,
    this.stroke = 3,
    required this.color,
    required this.track,
    this.period = const Duration(milliseconds: 800),
  });

  final double size;
  final double stroke;
  final Color color;
  final Color track;
  final Duration period;

  @override
  State<AppSpinner> createState() => _AppSpinnerState();
}

class _AppSpinnerState extends State<AppSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.period,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RotationTransition(
    turns: _c,
    child: CustomPaint(
      size: Size.square(widget.size),
      painter: _SpinnerPainter(widget.color, widget.track, widget.stroke),
    ),
  );
}

class _SpinnerPainter extends CustomPainter {
  _SpinnerPainter(this.color, this.track, this.stroke);

  final Color color;
  final Color track;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(stroke / 2);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawArc(rect, 0, math.pi * 2, false, p..color = track);
    canvas.drawArc(rect, -math.pi * .75, math.pi / 2, false, p..color = color);
  }

  @override
  bool shouldRepaint(_SpinnerPainter old) =>
      old.color != color || old.track != track || old.stroke != stroke;
}
