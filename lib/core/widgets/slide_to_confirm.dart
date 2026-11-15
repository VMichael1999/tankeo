import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../icons/icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Botón de deslizar para confirmar (`SlideToStartFueling`).
///
/// Pista oscura de 62 y radio 20 con un pulgar naranja de 50 × 50 (radio 15),
/// una estela naranja suave detrás del pulgar y «›››» que se ilumina de
/// izquierda a derecha en bucle. Al pasar el 85 % confirma con vibración; si se
/// suelta antes, el pulgar vuelve al inicio. Con lector de pantalla, un toque
/// doble confirma.
class SlideToConfirm extends StatefulWidget {
  const SlideToConfirm({
    super.key,
    required this.label,
    required this.onConfirmed,
    this.trackColor = AppColors.pinPill,
    this.thumbColor = AppColors.primary,
  });

  final String label;
  final VoidCallback onConfirmed;
  final Color trackColor;
  final Color thumbColor;

  static const height = 62.0;
  static const threshold = .85;

  @override
  State<SlideToConfirm> createState() => _SlideToConfirmState();
}

class _SlideToConfirmState extends State<SlideToConfirm>
    with TickerProviderStateMixin {
  static const _pad = 6.0;
  static const _thumb = 50.0;
  static const _trail = 110.0;

  late final AnimationController _back = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );
  late final AnimationController _shimmer = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );
  double _drag = 0; // 0..1
  double _from = 0;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _back.addListener(
      () => setState(
        () => _drag = _from * (1 - Curves.easeOut.transform(_back.value)),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _shimmer.stop();
    } else if (!_shimmer.isAnimating) {
      _shimmer.repeat();
    }
  }

  @override
  void dispose() {
    _back.dispose();
    _shimmer.dispose();
    super.dispose();
  }

  void _confirm() {
    if (_done) return;
    _done = true;
    HapticFeedback.mediumImpact();
    setState(() => _drag = 1);
    widget.onConfirmed();
  }

  void _release() {
    if (_done) return;
    if (_drag >= SlideToConfirm.threshold) {
      _confirm();
      return;
    }
    _from = _drag;
    _back.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      onTap: _confirm,
      excludeSemantics: true,
      child: LayoutBuilder(
        builder: (context, c) {
          final travel = c.maxWidth - _thumb - _pad * 2;
          final x = _pad + travel * _drag;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: (_) => _back.stop(),
            onHorizontalDragUpdate: (d) {
              if (_done) return;
              setState(() => _drag = (_drag + d.delta.dx / travel).clamp(0, 1));
            },
            onHorizontalDragEnd: (_) => _release(),
            onHorizontalDragCancel: _release,
            child: Container(
              height: SlideToConfirm.height,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: widget.trackColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  // Estela naranja suave que sigue al pulgar.
                  Positioned(
                    left: _pad,
                    top: _pad,
                    bottom: _pad,
                    width: x - _pad + _trail,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: LinearGradient(
                          colors: [
                            widget.thumbColor.withValues(alpha: .16),
                            widget.thumbColor.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Opacity(
                      opacity: (1 - _drag * 1.6).clamp(0, 1),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 40),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                widget.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppText.ui(
                                  15.5,
                                  AppText.w7,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _Chevrons(animation: _shimmer),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: x,
                    top: _pad,
                    child: Container(
                      width: _thumb,
                      height: _thumb,
                      decoration: BoxDecoration(
                        color: widget.thumbColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: AppIconView(
                          _done ? AppIcon.check : AppIcon.chev,
                          size: 24,
                          color: AppColors.white,
                          strokeWidth: 2.6,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// «›››» al 35 % con un destello que lo recorre de izquierda a derecha.
class _Chevrons extends StatelessWidget {
  const _Chevrons({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final base = AppText.ui(
      15.5,
      AppText.w7,
      color: AppColors.white,
      letterSpacing: -3,
    );
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value * 2 - .5; // de −0.5 a 1.5
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (r) => LinearGradient(
            colors: [
              AppColors.white.withValues(alpha: .35),
              AppColors.white.withValues(alpha: .95),
              AppColors.white.withValues(alpha: .35),
            ],
            stops: [(t - .3).clamp(0, 1), t.clamp(0, 1), (t + .3).clamp(0, 1)],
          ).createShader(r),
          child: Text('›››', style: base),
        );
      },
    );
  }
}
