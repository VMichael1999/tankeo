import 'package:flutter/material.dart';

import '../../../app/di.dart';
import '../data/road_route_repository.dart';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/icons/icons.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/toast/toast_service.dart';
import '../../../core/widgets/circle_icon_button.dart';
import '../../../core/widgets/tankeo_map.dart';
import '../../../core/widgets/fuel_filter_chips.dart';
import '../../../core/widgets/station_carousel.dart';
import '../bloc/stations_bloc.dart';
import 'filter_sheet.dart';

/// Grifos cercanos: mapa a pantalla completa, filtros por combustible,
/// carrusel de tarjetas y ruta hasta el grifo elegido.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _map = TankeoMapController();
  late final PageController _pages;

  @override
  void initState() {
    super.initState();
    final s = context.read<StationsBloc>().state;
    _pages = PageController(
      viewportFraction: StationCarousel.pageFraction,
      initialPage: s.visible.indexOf(s.selectedIndex).clamp(0, 99),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _map.focus(s.selected);
    });
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  /// Desplaza el carrusel al grifo [station] (índice global).
  void _scrollTo(int station) {
    if (!_pages.hasClients) return;
    final page = context.read<StationsBloc>().state.visible.indexOf(station);
    if (page < 0) return;
    _pages.animateToPage(
      page,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final bloc = context.read<StationsBloc>();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: MultiBlocListener(
        listeners: [
          BlocListener<StationsBloc, StationsState>(
            listenWhen: (a, b) => a.selectedIndex != b.selectedIndex,
            listener: (context, s) {
              _map.focus(s.selected);
              if (_pages.hasClients &&
                  _pages.page?.round() != s.visible.indexOf(s.selectedIndex)) {
                _scrollTo(s.selectedIndex);
              }
            },
          ),
          BlocListener<StationsBloc, StationsState>(
            listenWhen: (a, b) =>
                a.filter != b.filter || a.filters != b.filters,
            listener: (context, s) => _map.focus(s.selected, animate: false),
          ),
        ],
        child: BlocBuilder<StationsBloc, StationsState>(
          builder: (context, state) {
            final vis = state.visible;
            return Scaffold(
              backgroundColor: AppColors.mapViewport,
              body: Stack(
                children: [
                  Positioned.fill(
                    child: TankeoMap(
                      routes: getIt<RoadRouteRepository>(),
                      controller: _map,
                      padding: const EdgeInsets.only(top: 190, bottom: 250),
                      stations: state.stations,
                      selectedIndex: state.selectedIndex,
                      filter: state.filter,
                      cheapestIndex: state.cheapestIndex,
                      visible: vis.toSet(),
                      onPinTap: (i) {
                        if (!vis.contains(i)) {
                          context.read<ToastService>().show(
                            AppToast.hiddenByFilters,
                          );
                          return;
                        }
                        _scrollTo(i);
                        bloc.add(StationSelected(i));
                      },
                    ),
                  ),
                  Positioned(
                    left: 18,
                    right: 18,
                    top: 62,
                    child: Row(
                      children: [
                        PillBackButton(
                          title: l.mapTitle,
                          onPressed: () => context.go('/home'),
                        ),
                        const Spacer(),
                        CircleIconButton(
                          icon: AppIcon.filter,
                          semanticLabel: l.filters,
                          badge: state.filters.activeCount == 0
                              ? null
                              : '${state.filters.activeCount}',
                          badgeColor: AppColors.primary,
                          onPressed: () async {
                            final f = await showFilterSheet(
                              context,
                              initial: state.filters,
                              stations: state.stations,
                            );
                            if (f != null) bloc.add(FiltersApplied(f));
                          },
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 120,
                    child: FuelFilterChips(
                      selected: state.filter,
                      onSelected: (f) => bloc.add(FilterChanged(f)),
                    ),
                  ),
                  Positioned(
                    right: 18,
                    top: 176,
                    child: Container(
                      width: 46,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(23),
                        boxShadow: AppShadows.floating,
                      ),
                      child: Column(
                        children: [
                          _ZoomButton(
                            icon: AppIcon.plus,
                            label: l.zoomIn,
                            onTap: () => _map.zoomBy(1.25),
                          ),
                          const ColoredBox(
                            color: AppColors.line,
                            child: SizedBox(height: 1, width: 46),
                          ),
                          _ZoomButton(
                            icon: AppIcon.minus,
                            label: l.zoomOut,
                            onTap: () => _map.zoomBy(.8),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: 18,
                    top: 284,
                    child: CircleIconButton(
                      icon: AppIcon.target,
                      semanticLabel: l.centerOnCar,
                      onPressed: () =>
                          _map.focus(state.selected, animate: false),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 252,
                    child: Center(child: _LocationChip(label: l.mapLocation)),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 30,
                    child: StationCarousel(
                      controller: _pages,
                      stations: [for (final i in vis) state.stations[i]],
                      fuel: state.filter,
                      cheapestIndex: vis.indexOf(state.cheapestIndex),
                      onSettled: (k) {
                        if (k >= 0 && k < vis.length)
                          bloc.add(StationSelected(vis[k]));
                      },
                      onCardTap: (k) {
                        if (vis[k] != state.selectedIndex) {
                          _scrollTo(vis[k]);
                        } else {
                          context.go('/details');
                        }
                      },
                      onShare: (k) => context.read<ToastService>().show(
                        AppToast.stationShared,
                        args: [state.stations[vis[k]].name],
                      ),
                      onGo: (k) {
                        bloc.add(StationSelected(vis[k]));
                        context.go('/details');
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ZoomButton extends StatelessWidget {
  const _ZoomButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final AppIcon icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 46,
        height: 46,
        child: Center(child: AppIconView(icon, size: 20, color: AppColors.ink)),
      ),
    ),
  );
}

class _LocationChip extends StatelessWidget {
  const _LocationChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    height: 38,
    padding: const EdgeInsets.only(left: 12, right: 16),
    decoration: BoxDecoration(
      color: AppColors.mapChip,
      borderRadius: BorderRadius.circular(19),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppIconView(
          AppIcon.pin,
          size: 16,
          color: AppColors.mapChip,
          fillColor: AppColors.white,
        ),
        const SizedBox(width: 7),
        Text(
          label,
          style: AppText.ui(13.5, AppText.w6, color: AppColors.white),
        ),
      ],
    ),
  );
}
