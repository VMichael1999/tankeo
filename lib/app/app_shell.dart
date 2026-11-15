import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/l10n/l10n.dart';
import '../core/widgets/floating_nav_pill.dart';
import '../features/fueling/bloc/fueling_bloc.dart';
import 'router.dart';

/// Marco de Inicio y Carga: contiene la barra de navegación flotante.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final onCharge = location.startsWith(AppRoutes.charge);
    final onSettings = location.startsWith(AppRoutes.settings);
    return Stack(
      children: [
        Positioned.fill(child: child),
        // La hoja del surtidor cubre la barra con su velo.
        BlocSelector<FuelingBloc, FuelingState, bool>(
          selector: (s) =>
              onCharge && ((s.sheetOpen && s.isBusy) || s is SafetyCheck),
          builder: (context, hide) => Positioned.fill(
            child: IgnorePointer(
              ignoring: hide,
              child: AnimatedOpacity(
                opacity: hide ? 0 : 1,
                duration: const Duration(milliseconds: 300),
                child: Stack(
                  children: [
                    FloatingNavPill(
                      selectedIndex: onSettings ? 3 : (onCharge ? 1 : 0),
                      labels: [
                        l.navCar,
                        l.navCharge,
                        l.navStations,
                        l.navSettings,
                      ],
                      onSelected: (i) {
                        switch (i) {
                          case 0:
                            context.go(AppRoutes.home);
                          case 1:
                            context.go(AppRoutes.charge);
                          case 2:
                            context.go(AppRoutes.map);
                          default:
                            context.go(AppRoutes.settings);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
