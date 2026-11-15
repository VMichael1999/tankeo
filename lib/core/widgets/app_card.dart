import 'package:flutter/material.dart';

import '../theme/tankeo_tokens.dart';

/// Tarjeta blanca con radio 24.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.radius = TankeoTokens.rCard,
    this.color,
    this.clip = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final Color? color;
  final bool clip;

  @override
  Widget build(BuildContext context) => Container(
    margin: margin,
    padding: padding,
    clipBehavior: clip ? Clip.antiAlias : Clip.none,
    decoration: BoxDecoration(
      color: color ?? context.tokens.card,
      borderRadius: BorderRadius.circular(radius),
    ),
    child: child,
  );
}
