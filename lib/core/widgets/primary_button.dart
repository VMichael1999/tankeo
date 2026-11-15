import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../theme/tankeo_tokens.dart';
import 'app_spinner.dart';

/// Botón principal: alto 58, radio 16, texto 16.5/700. El color viene del
/// combustible (naranja o teal). Variantes: deshabilitado, cargando y oscuro.
class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    super.key,
    this.label,
    required this.onPressed,
    required this.color,
    this.loading = false,
    this.spinnerOnly = false,
    this.dark = false,
    this.width,
    this.shadows,
    this.radius = TankeoTokens.rButton,
    this.height = TankeoTokens.hButton,
    this.child,
  });

  final String? label;
  final VoidCallback? onPressed;
  final Color color;

  /// Muestra el spinner de 22 y el texto.
  final bool loading;

  /// Solo el spinner (colgando la manguera, ingresando).
  final bool spinnerOnly;
  final bool dark;
  final double? width;
  final List<BoxShadow>? shadows;
  final double radius;
  final double height;
  final Widget? child;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final disabled =
        widget.onPressed == null || widget.loading || widget.spinnerOnly;
    final bg = widget.dark ? t.ink : widget.color;
    final content =
        widget.child ??
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.loading || widget.spinnerOnly) ...[
              AppSpinner(
                color: AppColors.white,
                track: AppColors.white.withValues(alpha: .35),
              ),
              if (!widget.spinnerOnly && widget.label != null)
                const SizedBox(width: 10),
            ],
            if (!widget.spinnerOnly && widget.label != null)
              Flexible(
                child: Text(
                  widget.label!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.ui(16.5, AppText.w7, color: AppColors.white),
                ),
              ),
          ],
        );
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: disabled ? null : (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: widget.onPressed == null || widget.spinnerOnly || widget.loading
          ? null
          : widget.onPressed,
      child: AnimatedScale(
        scale: _down ? .99 : 1,
        duration: const Duration(milliseconds: 80),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.width ?? double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(widget.radius),
            boxShadow: widget.shadows,
          ),
          child: Opacity(
            opacity: disabled ? .75 : 1,
            child: Center(child: content),
          ),
        ),
      ),
    );
  }
}
