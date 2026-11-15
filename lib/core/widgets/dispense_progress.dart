import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../theme/tankeo_tokens.dart';

/// Barra de 12 con rayas animadas, «Nivel 25% → 100%» y lo que falta o el total.
class DispenseProgress extends StatefulWidget {
  const DispenseProgress({
    super.key,
    required this.progress,
    required this.gnv,
    required this.animating,
    required this.fromLabel,
    required this.toLabel,
    required this.levelLabel,
    required this.trailing,
  });

  /// De 0 a 1.
  final double progress;
  final bool gnv;
  final bool animating;
  final String fromLabel;
  final String toLabel;

  /// «Nivel»
  final String levelLabel;

  /// «Faltan S/ 11.05» o «Total S/ 19.01».
  final String trailing;

  @override
  State<DispenseProgress> createState() => _DispenseProgressState();
}

class _DispenseProgressState extends State<DispenseProgress>
    with SingleTickerProviderStateMixin {
  late final AnimationController _stripes = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(DispenseProgress old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    final go = widget.animating && !MediaQuery.disableAnimationsOf(context);
    if (go && !_stripes.isAnimating) {
      _stripes.repeat();
    } else if (!go && _stripes.isAnimating) {
      _stripes.stop();
    }
  }

  @override
  void dispose() {
    _stripes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final colors = widget.gnv
        ? const [AppColors.gnvFillA, AppColors.gnv]
        : const [AppColors.gasFillA, AppColors.primary];
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 12,
            width: double.infinity,
            child: LayoutBuilder(
              builder: (context, c) => Stack(
                children: [
                  const Positioned.fill(
                    child: ColoredBox(color: AppColors.progressTrack),
                  ),
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: c.maxWidth * widget.progress.clamp(0, 1),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: colors),
                        ),
                        child: widget.animating
                            ? AnimatedBuilder(
                                animation: _stripes,
                                builder: (context, _) => CustomPaint(
                                  painter: _StripesPainter(_stripes.value),
                                  child: const SizedBox.expand(),
                                ),
                              )
                            : const SizedBox.expand(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text.rich(
              TextSpan(
                text: '${widget.levelLabel} ',
                style: AppText.ui(12.5, AppText.w4, color: t.ink2),
                children: [
                  TextSpan(
                    text: widget.fromLabel,
                    style: AppText.ui(12.5, AppText.w7, color: t.ink),
                  ),
                  const TextSpan(text: ' → '),
                  TextSpan(
                    text: widget.toLabel,
                    style: AppText.ui(12.5, AppText.w7, color: t.ink),
                  ),
                ],
              ),
            ),
            Text(
              widget.trailing,
              style: AppText.ui(12.5, AppText.w4, color: t.ink2),
            ),
          ],
        ),
      ],
    );
  }
}

class _StripesPainter extends CustomPainter {
  _StripesPainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    const period = 22.63;
    const band = 11.31;
    final paint = Paint()..color = AppColors.stripe.withValues(alpha: .28);
    final h = size.height;
    final shift = t * period;
    for (var x = -h - period + shift; x < size.width + period; x += period) {
      canvas.drawPath(
        Path()
          ..moveTo(x, h)
          ..lineTo(x + h, 0)
          ..lineTo(x + h + band, 0)
          ..lineTo(x + band, h)
          ..close(),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StripesPainter old) => old.t != t;
}
