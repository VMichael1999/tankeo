import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../theme/tankeo_tokens.dart';

/// Pantalla del surtidor: IMPORTE S/, VOLUMEN y PRECIO en dígitos de
/// 7 segmentos sobre fondo oscuro, con dígitos fantasma y brillo.
class PumpLcd extends StatefulWidget {
  const PumpLcd({
    super.key,
    required this.gnv,
    required this.flowing,
    required this.product,
    required this.status,
    required this.amount,
    required this.volume,
    required this.volumeLabel,
    required this.price,
    required this.priceLabel,
    required this.amountLabel,
  });

  final bool gnv;

  /// Mientras despacha, el punto del encabezado parpadea.
  final bool flowing;
  final String product;
  final String status;
  final String amount;
  final String volume;
  final String price;
  final String amountLabel;
  final String volumeLabel;
  final String priceLabel;

  @override
  State<PumpLcd> createState() => _PumpLcdState();
}

class _PumpLcdState extends State<PumpLcd> with SingleTickerProviderStateMixin {
  late final AnimationController _blink = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  );

  @override
  void didUpdateWidget(PumpLcd old) {
    super.didUpdateWidget(old);
    _sync();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  void _sync() {
    final go = widget.flowing && !MediaQuery.disableAnimationsOf(context);
    if (go && !_blink.isAnimating) {
      _blink.repeat();
    } else if (!go && _blink.isAnimating) {
      _blink.stop();
      _blink.value = 0;
    }
  }

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.gnv ? AppColors.lcdTeal : AppColors.lcdAmber;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        gradient: TankeoTokens.lcd,
        borderRadius: BorderRadius.circular(TankeoTokens.rLcd),
        border: Border.all(color: AppColors.white.withValues(alpha: .06)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.product,
                  style: AppText.ui(
                    11.5,
                    AppText.w6,
                    color: AppColors.white.withValues(alpha: .55),
                  ),
                ),
                Row(
                  children: [
                    AnimatedBuilder(
                      animation: _blink,
                      builder: (context, _) {
                        // blink: 50 % → .25 de opacidad.
                        final v = _blink.value;
                        final o = widget.flowing
                            ? (v < .5 ? 1 - v * 1.5 : .25 + (v - .5) * 1.5)
                            : 1.0;
                        return Opacity(
                          opacity: o.clamp(.25, 1),
                          child: Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: AppColors.white.withValues(alpha: .55),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.white.withValues(alpha: .55),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.status,
                      style: AppText.ui(
                        11.5,
                        AppText.w6,
                        color: AppColors.white.withValues(alpha: .55),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _Row(
            label: widget.amountLabel,
            value: widget.amount,
            ghost: '888.88',
            size: 54,
            lineHeight: 1.05,
            color: color,
            first: true,
          ),
          _Row(
            label: widget.volumeLabel,
            value: widget.volume,
            ghost: '88.888',
            size: 28,
            color: color,
          ),
          _Row(
            label: widget.priceLabel,
            value: widget.price,
            ghost: '88.88',
            size: 18,
            color: color,
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    required this.ghost,
    required this.size,
    required this.color,
    this.lineHeight = 1.3,
    this.first = false,
  });

  final String label;
  final String value;
  final String ghost;
  final double size;
  final double lineHeight;
  final Color color;
  final bool first;

  @override
  Widget build(BuildContext context) {
    final base = AppText.mono(
      size,
      AppText.w6,
      height: lineHeight,
      letterSpacing: size * .02,
    );
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        border: first
            ? null
            : Border(
                top: BorderSide(color: AppColors.white.withValues(alpha: .07)),
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppText.ui(
              11,
              AppText.w6,
              color: AppColors.white.withValues(alpha: .45),
              letterSpacing: 11 * .14,
            ),
          ),
          Stack(
            alignment: Alignment.centerRight,
            children: [
              Text(
                ghost,
                style: base.copyWith(
                  color: AppColors.white.withValues(alpha: .05),
                ),
              ),
              Text(
                value,
                style: base.copyWith(
                  color: color,
                  shadows: [Shadow(color: color, blurRadius: 12)],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
