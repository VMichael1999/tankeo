import 'package:flutter/material.dart';

import '../theme/tankeo_tokens.dart';

/// Lienzo de diseño de 440 puntos de ancho (iPhone 16 Pro Max, el del
/// prototipo). En pantallas más angostas o anchas escala todo de forma
/// uniforme, así cada pantalla conserva sus medidas exactas.
class DesignCanvas extends StatelessWidget {
  const DesignCanvas({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return LayoutBuilder(
      builder: (context, c) {
        const dw = TankeoTokens.designWidth;
        final scale = c.maxWidth <= 500
            ? c.maxWidth / dw
            : (c.maxWidth / dw).clamp(0, c.maxHeight / 956).toDouble();
        final h = c.maxHeight / scale;
        final inner = MediaQuery(
          data: mq.copyWith(
            size: Size(dw, h),
            padding: mq.padding / scale,
            viewPadding: mq.viewPadding / scale,
            viewInsets: mq.viewInsets / scale,
            systemGestureInsets: mq.systemGestureInsets / scale,
          ),
          child: child,
        );
        return ColoredBox(
          color: TankeoTokens.of(context).bg,
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: dw * scale,
              height: c.maxHeight,
              child: OverflowBox(
                alignment: Alignment.topLeft,
                minWidth: dw,
                maxWidth: dw,
                minHeight: h,
                maxHeight: h,
                child: Transform.scale(
                  scale: scale,
                  alignment: Alignment.topLeft,
                  child: inner,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
