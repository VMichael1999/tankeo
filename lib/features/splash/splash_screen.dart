import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/theme/tankeo_tokens.dart';

/// Pantalla de bienvenida: la marca aparece con un destello naranja y pasa
/// al login a los 2.8 s (1.5 s con menos animaciones).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );
  Timer? _timer;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final reduce = MediaQuery.disableAnimationsOf(context);
    if (reduce) {
      _c.value = 1;
    } else {
      _c.forward();
    }
    _timer = Timer(
      Duration(milliseconds: reduce ? 1500 : 2800),
      () => mounted ? context.go('/login') : null,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  // Tiempos en ms sobre 2400: logo .3–1.2 s, etiqueta .9–1.8 s, destello .5–1.9 s.
  double _t(double from, double to, [Curve curve = Curves.ease]) =>
      curve.transform(((_c.value * 2400 - from) / (to - from)).clamp(0, 1));

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.splashC,
        body: DecoratedBox(
          decoration: const BoxDecoration(gradient: TankeoTokens.splash),
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) {
              final logoT = _t(300, 1200);
              final tagT = _t(900, 1800);
              final streakT = _t(500, 1900, Curves.ease);
              final width = MediaQuery.sizeOf(context).width;
              // streak: left -60% → 110%, opacidad 0 → 1 (20 %) → 0.
              final sLeft = -.6 * width + (1.7 * width) * streakT;
              final sOpacity = streakT <= 0
                  ? 0.0
                  : streakT < .2
                  ? streakT / .2
                  : 1 - (streakT - .2) / .8;
              return Stack(
                children: [
                  Positioned(
                    top: 460,
                    left: sLeft,
                    width: width * .6,
                    height: 2,
                    child: Opacity(
                      opacity: sOpacity.clamp(0, 1),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryMid.withValues(alpha: 0),
                              AppColors.primaryMid,
                              AppColors.primaryMid.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 430,
                    left: 0,
                    right: 0,
                    child: Opacity(
                      opacity: logoT,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 52 * .24),
                          child: Text(
                            l.appName,
                            style: AppText.ui(
                              52,
                              AppText.w6,
                              color: AppColors.white,
                              letterSpacing: 52 * (.5 + (.24 - .5) * logoT),
                              height: 1.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 500,
                    left: 0,
                    right: 0,
                    child: Opacity(
                      opacity: tagT,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12 * .35),
                          child: Text(
                            l.splashTagline,
                            style: AppText.ui(
                              12,
                              AppText.w6,
                              color: AppColors.white.withValues(alpha: .35),
                              letterSpacing: 12 * (.5 + (.35 - .5) * tagT),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
