import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/l10n/l10n.dart';
import '../core/theme/tankeo_tokens.dart';
import '../core/widgets/tankeo_tab_bar.dart';
import '../features/fueling/bloc/fueling_bloc.dart';
import 'router.dart';

/// Marco de Inicio, Carga y Ajustes: contiene la barra de pestañas flotante.
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _compact = false;

  bool get _onCharge => widget.location.startsWith(AppRoutes.charge);
  bool get _onSettings => widget.location.startsWith(AppRoutes.settings);

  /// Solo Inicio y Ajustes compactan la barra al hacer scroll.
  bool get _canCompact => !_onCharge;

  @override
  void didUpdateWidget(AppShell old) {
    super.didUpdateWidget(old);
    if (old.location != widget.location && _compact) {
      setState(() => _compact = false);
    }
  }

  bool _onScroll(ScrollNotification n) {
    if (!_canCompact || n.depth != 0) return false;
    if (n is UserScrollNotification) {
      final down = n.direction == ScrollDirection.reverse;
      final up = n.direction == ScrollDirection.forward;
      if (down && !_compact) setState(() => _compact = true);
      if (up && _compact) setState(() => _compact = false);
    } else if (n is ScrollEndNotification && _compact) {
      setState(() => _compact = false);
    }
    return false;
  }

  void _go(int tab) {
    switch (tab) {
      case 0:
        context.go(AppRoutes.home);
      case 1:
        context.go(AppRoutes.charge);
      case 2:
        context.go(AppRoutes.map);
      default:
        context.go(AppRoutes.settings);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final selected = _onSettings ? 3 : (_onCharge ? 1 : 0);
    return Stack(
      children: [
        Positioned.fill(
          child: NotificationListener<ScrollNotification>(
            onNotification: _onScroll,
            child: widget.child,
          ),
        ),
        // La hoja del surtidor cubre la barra con su velo.
        BlocBuilder<FuelingBloc, FuelingState>(
          builder: (context, s) {
            final hide =
                _onCharge && ((s.sheetOpen && s.isBusy) || s is SafetyCheck);
            return Positioned(
              left: 0,
              right: 0,
              bottom:
                  TankeoTokens.navBottom + MediaQuery.paddingOf(context).bottom,
              child: IgnorePointer(
                ignoring: hide,
                child: AnimatedOpacity(
                  opacity: hide ? 0 : 1,
                  duration: const Duration(milliseconds: 300),
                  child: Center(
                    child: TankeoTabBar(
                      selectedIndex: selected,
                      compact: _compact,
                      charging: s is! Idle,
                      chargingLabel: l.navFuelInProgress,
                      labels: [
                        l.navTabCar,
                        l.navTabFuel,
                        l.navTabStations,
                        l.navTabSettings,
                      ],
                      onSelected: _go,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
