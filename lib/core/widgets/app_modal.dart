import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/tankeo_tokens.dart';

/// Capa modal con velo al 45 % y diálogo de 342 de ancho que aparece con un
/// ligero zoom (`scale .94 → 1`). Se coloca dentro de un [Stack].
class AppModal extends StatelessWidget {
  const AppModal({
    super.key,
    required this.visible,
    required this.child,
    this.onScrimTap,
  });

  final bool visible;
  final Widget child;
  final VoidCallback? onScrimTap;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    final dur = reduce ? Duration.zero : const Duration(milliseconds: 250);
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: !visible,
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: dur,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onScrimTap,
            child: ColoredBox(
              color: AppColors.scrim.withValues(alpha: .45),
              child: Center(
                child: AnimatedScale(
                  scale: visible ? 1 : .94,
                  duration: dur,
                  child: GestureDetector(onTap: () {}, child: child),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Caja blanca del diálogo (342 de ancho, radio 26).
class DialogCard extends StatelessWidget {
  const DialogCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: 342,
    padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(TankeoTokens.rDialog),
    ),
    child: DefaultTextStyle.merge(textAlign: TextAlign.center, child: child),
  );
}
