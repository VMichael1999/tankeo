import 'package:flutter/material.dart';

import '../../../app/di.dart';
import '../data/road_route_repository.dart';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/domain/fuel_type.dart';
import '../../../core/icons/icons.dart';
import '../../../core/l10n/fuel_l10n.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/circle_icon_button.dart';
import '../../../core/widgets/tankeo_map.dart';
import '../../../core/widgets/drop_shadow_image.dart';
import '../../../core/widgets/fuel_price_list.dart';
import '../../../core/widgets/pump_grid.dart';
import '../../../core/widgets/station_illustration.dart';
import '../../fueling/domain/fueling_config.dart';
import '../../fueling/domain/fuel_quote.dart';
import '../../vehicle/bloc/vehicle_cubit.dart';
import '../../vehicle/domain/vehicle.dart';
import '../bloc/stations_bloc.dart';
import '../domain/station.dart';

/// Detalle del grifo: mapa fijo con la ruta, resumen del auto, precios de
/// hoy, surtidores, servicios y reseñas, con la barra «Ir a cargar».
class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final _map = TankeoMapController();
  final _scroll = ScrollController();
  bool _covered = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      final c = _scroll.offset > 210;
      if (c != _covered) setState(() => _covered = c);
    });
    final s = context.read<StationsBloc>().state;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _map.focus(s.selected);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: MultiBlocListener(
        listeners: [
          BlocListener<StationsBloc, StationsState>(
            listenWhen: (a, b) => a.selectedIndex != b.selectedIndex,
            listener: (context, s) {
              _map.focus(s.selected);
              if (_scroll.hasClients) _scroll.jumpTo(0);
            },
          ),
          // «Ir a cargar»: el bloc decide, el router navega.
          BlocListener<StationsBloc, StationsState>(
            listenWhen: (a, b) => b.effect != null && a.effect != b.effect,
            listener: (context, s) {
              final kind = s.effect!.kind;
              context.read<StationsBloc>().add(const StationsEffectHandled());
              switch (kind) {
                case StationsEffectKind.openCharge:
                  context.go('/charge');
                case StationsEffectKind.openSummary:
                  context.go('/summary');
              }
            },
          ),
        ],
        child: BlocBuilder<StationsBloc, StationsState>(
          builder: (context, state) {
            final st = state.selected;
            final vehicle = context.watch<VehicleCubit>().state.vehicle;
            final charge = state.chargeFuel;
            final tank = charge.tank!;
            final quote = FuelQuote.forConfig(
              config: FuelingConfig(
                tank: tank,
                grade: charge == FuelType.premium
                    ? FuelType.premium
                    : FuelType.regular,
              ),
              vehicle: vehicle,
              station: st,
            );
            final cheapestFuels = {
              for (final f in FuelType.values)
                if (state.cheapestByFuel[f] == state.selectedIndex) f,
            };
            return Scaffold(
              backgroundColor: AppColors.white,
              body: Stack(
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    height: 360,
                    child: TankeoMap(
                      routes: getIt<RoadRouteRepository>(),
                      controller: _map,
                      padding: const EdgeInsets.only(top: 110, bottom: 20),
                      stations: state.stations,
                      selectedIndex: state.selectedIndex,
                      filter: state.filter,
                      cheapestIndex: state.cheapestIndex,
                      onPinTap: (i) =>
                          context.read<StationsBloc>().add(StationSelected(i)),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    height: 120,
                    child: IgnorePointer(
                      child: AnimatedOpacity(
                        opacity: _covered ? 1 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.white,
                                AppColors.white,
                                AppColors.white.withValues(alpha: 0),
                              ],
                              stops: const [0, .7, 1],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: CustomScrollView(
                      controller: _scroll,
                      hitTestBehavior: HitTestBehavior.deferToChild,
                      slivers: [
                        const SliverToBoxAdapter(
                          child: IgnorePointer(child: SizedBox(height: 262)),
                        ),
                        SliverToBoxAdapter(
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Column(
                                children: [
                                  _DarkCard(station: st, vehicle: vehicle),
                                  // La hoja blanca sube 44 sobre la tarjeta oscura (margin-top: -44).
                                  _SheetBody(
                                    station: st,
                                    filter: state.filter,
                                    cheapestFuels: cheapestFuels,
                                  ),
                                  const ColoredBox(
                                    color: AppColors.white,
                                    child: SizedBox(
                                      height: 130,
                                      width: double.infinity,
                                    ),
                                  ),
                                ],
                              ),
                              // El auto sale por la derecha, por encima de la hoja (z-index 2).
                              Positioned(
                                right: -22,
                                top: _DarkCard.height + 34 - 102,
                                width: 230,
                                height: 102,
                                child: IgnorePointer(
                                  child: DropShadowImage(
                                    asset: AppImages.carSide,
                                    shadowColor: AppColors.black.withValues(
                                      alpha: .4,
                                    ),
                                    offsetY: 14,
                                    blur: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 18,
                    right: 18,
                    top: 62,
                    child: Row(
                      children: [
                        PillBackButton(
                          title: l.detailTitle,
                          onPressed: () => context.go('/map'),
                        ),
                        const Spacer(),
                        CircleIconButton(
                          icon: AppIcon.heart,
                          semanticLabel: l.save,
                          iconColor: state.isFavorite(state.selectedIndex)
                              ? AppColors.danger
                              : AppColors.ink,
                          filled: state.isFavorite(state.selectedIndex),
                          onPressed: () => context.read<StationsBloc>().add(
                            const FavoriteToggled(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        CircleIconButton(
                          icon: AppIcon.dots,
                          semanticLabel: l.moreOptions,
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 116,
                    child: _BottomBar(
                      price: Money.format(st.priceOf(charge)),
                      unit: '/${charge.unit}',
                      fullLabel: l.detailFillEstimate(
                        Money.format(quote.fullAmount),
                        charge == FuelType.gnv
                            ? l.fuelGnv
                            : charge.label(context),
                      ),
                      onGo: () => context.push('/navigation'),
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

class _DarkCard extends StatelessWidget {
  const _DarkCard({required this.station, required this.vehicle});

  /// Alto de la tarjeta oscura (el contenido es estático).
  static const height = 191.0;

  final Station station;
  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final gas = vehicle.level(TankKind.gasoline).round();
    final gnv = vehicle.level(TankKind.gnv).round();
    return Container(
      height: height,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      decoration: const BoxDecoration(
        color: AppColors.detailDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: AppIconView(
                    AppIcon.pump,
                    size: 17,
                    color: AppColors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  station.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.ui(16, AppText.w6, color: AppColors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Metric(
                value: '${station.distanceKm} km',
                label: l.detailDistance,
                size: 24,
              ),
              const SizedBox(width: 28),
              _Metric(
                value: l.minutesValue(station.driveMinutes),
                label: l.detailByCar,
                size: 24,
              ),
              const Spacer(),
              _Metric(
                value: '$gas%',
                label: l.fuelGasoline,
                size: 19,
                end: true,
              ),
              const SizedBox(width: 14),
              _Metric(
                value: '$gnv%',
                label: l.fuelGnv,
                size: 19,
                end: true,
                valueColor: AppColors.lcdTeal,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.value,
    required this.label,
    required this.size,
    this.end = false,
    this.valueColor = AppColors.white,
  });

  final String value;
  final String label;
  final double size;
  final bool end;
  final Color valueColor;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: end ? CrossAxisAlignment.end : CrossAxisAlignment.start,
    children: [
      Text(
        value,
        style: AppText.ui(
          size,
          AppText.w7,
          color: valueColor,
          letterSpacing: size == 24 ? -.24 : null,
        ),
      ),
      Text(
        label,
        style: AppText.ui(
          end ? 11.5 : 12.5,
          AppText.w4,
          color: AppColors.white.withValues(alpha: .5),
        ),
      ),
    ],
  );
}

class _SheetBody extends StatelessWidget {
  const _SheetBody({
    required this.station,
    required this.filter,
    required this.cheapestFuels,
  });

  final Station station;
  final FuelType filter;
  final Set<FuelType> cheapestFuels;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    Widget h3(String text, {String? action}) => Padding(
      padding: const EdgeInsets.only(top: 26, bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text, style: AppText.ui(18, AppText.w7)),
          if (action != null)
            Text(
              action,
              style: AppText.ui(13, AppText.w6, color: AppColors.primary),
            ),
        ],
      ),
    );
    final amenities = <(AppIcon, String)>[
      (AppIcon.store, l.amenityStore),
      (AppIcon.users, l.amenityRestrooms),
      (AppIcon.wind, l.amenityAir),
      (AppIcon.drop, l.amenityWash),
      (AppIcon.coin, l.amenityAtm),
      (AppIcon.shield, l.amenitySecurity),
    ];
    return Transform.translate(
      offset: const Offset(0, -44),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 700),
        padding: const EdgeInsets.fromLTRB(20, 26, 20, 30),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.detailSummary,
              style: AppText.ui(22, AppText.w7, letterSpacing: -.22),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                    color: AppColors.grayChip,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: AppIconView(
                      AppIcon.pin,
                      size: 20,
                      color: AppColors.ink2,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        station.address,
                        style: AppText.ui(15.5, AppText.w6),
                      ),
                      Text(
                        station.district,
                        style: AppText.ui(
                          13,
                          AppText.w4,
                          color: AppColors.ink2,
                        ),
                      ),
                    ],
                  ),
                ),
                _OpenChip(label: l.open24h),
              ],
            ),
            const SizedBox(height: 18),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _Tile(
                      icon: AppIcon.pump,
                      title: station.hasFreePumps
                          ? l.pumpsFreeShort(
                              station.freePumps,
                              station.totalPumps,
                            )
                          : l.pumpsAllBusy,
                      subtitle: l.detailPumps,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Tile(
                      icon: AppIcon.chip,
                      title: l.detailGnvChip,
                      subtitle: l.detailInfogasOnline,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Tile(
                      icon: AppIcon.wallet,
                      title: l.detailPayInApp,
                      subtitle: l.detailPayMethods,
                    ),
                  ),
                ],
              ),
            ),
            h3(l.detailTodayPrices),
            FuelPriceList(
              prices: station.prices,
              selected: filter,
              cheapestFuels: cheapestFuels,
            ),
            const SizedBox(height: 22),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                height: 196,
                child: Stack(
                  children: [
                    const Positioned.fill(
                      child: ColoredBox(
                        color: AppColors.thumbBg,
                        child: StationIllustration(),
                      ),
                    ),
                    Positioned(
                      left: 12,
                      bottom: 12,
                      child: _HeroChip(
                        icon: AppIcon.clock,
                        label: l.open24hLong,
                      ),
                    ),
                    const Positioned(
                      right: 12,
                      bottom: 12,
                      child: _HeroChip(icon: AppIcon.photo, label: '1/9'),
                    ),
                  ],
                ),
              ),
            ),
            h3(l.detailPumpsTitle),
            PumpGrid(total: station.totalPumps, free: station.freePumps),
            h3(l.detailServices),
            Wrap(
              spacing: 9,
              runSpacing: 9,
              children: [
                for (final a in amenities)
                  Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.lineChip),
                      borderRadius: BorderRadius.circular(19),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppIconView(a.$1, size: 17, color: AppColors.ink2),
                        const SizedBox(width: 8),
                        Text(a.$2, style: AppText.ui(13.5, AppText.w5)),
                      ],
                    ),
                  ),
              ],
            ),
            h3(l.detailReviews, action: l.seeAll),
            _ReviewSummary(rating: station.rating, count: station.reviewCount),
            _Review(
              initials: 'LQ',
              name: l.reviewer1Name,
              when: l.reviewer1When,
              stars: 5,
              text: l.reviewer1Text,
            ),
            _Review(
              initials: 'JR',
              name: l.reviewer2Name,
              when: l.reviewer2When,
              stars: 4,
              text: l.reviewer2Text,
            ),
          ],
        ),
      ),
    );
  }
}

class _OpenChip extends StatelessWidget {
  const _OpenChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    height: 26,
    padding: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(
      color: AppColors.successSoft,
      borderRadius: BorderRadius.circular(13),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppText.ui(12, AppText.w6, color: AppColors.success),
        ),
      ],
    ),
  );
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final AppIcon icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(12, 14, 12, 13),
    decoration: BoxDecoration(
      color: AppColors.grayTile,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppIconView(icon, size: 20, color: AppColors.ink),
        const SizedBox(height: 16),
        Text(title, style: AppText.ui(14, AppText.w6)),
        Text(
          subtitle,
          style: AppText.ui(12, AppText.w4, color: AppColors.ink2),
        ),
      ],
    ),
  );
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.icon, required this.label});

  final AppIcon icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    height: 32,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: AppShadows.ctaSoft,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppIconView(icon, size: 15, color: AppColors.ink),
        const SizedBox(width: 6),
        Text(label, style: AppText.ui(12.5, AppText.w6)),
      ],
    ),
  );
}

class _Stars extends StatelessWidget {
  const _Stars(this.count);

  final int count;
  final double size = 13;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var k = 0; k < 5; k++) ...[
        if (k > 0) const SizedBox(width: 2),
        AppIconView(
          AppIcon.starFilled,
          size: size,
          solid: true,
          color: k < count ? AppColors.starOn : AppColors.starOff,
        ),
      ],
    ],
  );
}

class _ReviewSummary extends StatelessWidget {
  const _ReviewSummary({required this.rating, required this.count});

  final double rating;
  final int count;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    const bars = [(5, .76), (4, .15), (3, .05), (2, .02), (1, .02)];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.grayTile,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rating.toStringAsFixed(1),
                style: AppText.ui(
                  34,
                  AppText.w7,
                  height: 1,
                  letterSpacing: -.68,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 6, 0, 4),
                child: _Stars(rating.round()),
              ),
              Text(
                l.reviewCount(count),
                style: AppText.ui(12, AppText.w4, color: AppColors.ink2),
              ),
            ],
          ),
          const SizedBox(width: 22),
          Expanded(
            child: Column(
              children: [
                for (final (i, b) in bars.indexed) ...[
                  if (i > 0) const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '${b.$1}',
                        style: AppText.ui(
                          11,
                          AppText.w4,
                          color: AppColors.ink2,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: SizedBox(
                            height: 5,
                            child: Stack(
                              children: [
                                const Positioned.fill(
                                  child: ColoredBox(
                                    color: AppColors.ratingTrack,
                                  ),
                                ),
                                FractionallySizedBox(
                                  widthFactor: b.$2,
                                  child: const ColoredBox(
                                    color: AppColors.ratingFill,
                                    child: SizedBox.expand(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Review extends StatelessWidget {
  const _Review({
    required this.initials,
    required this.name,
    required this.when,
    required this.stars,
    required this.text,
  });

  final String initials;
  final String name;
  final String when;
  final int stars;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 10),
    padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
    decoration: BoxDecoration(
      color: AppColors.grayTile,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Text(
                initials,
                style: AppText.ui(13, AppText.w7, color: AppColors.primary),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppText.ui(14.5, AppText.w6)),
                  Text(
                    when,
                    style: AppText.ui(12, AppText.w4, color: AppColors.ink2),
                  ),
                ],
              ),
            ),
            _Stars(stars),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          text,
          style: AppText.ui(
            13.5,
            AppText.w4,
            color: AppColors.inkBody,
            height: 1.5,
          ),
        ),
      ],
    ),
  );
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.price,
    required this.unit,
    required this.fullLabel,
    required this.onGo,
  });

  final String price;
  final String unit;
  final String fullLabel;
  final VoidCallback onGo;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: AppShadows.detailBar,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      text: price,
                      style: AppText.ui(28, AppText.w7, letterSpacing: -.56),
                      children: [
                        TextSpan(
                          text: unit,
                          style: AppText.ui(
                            13,
                            AppText.w5,
                            color: AppColors.ink2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    fullLabel,
                    style: AppText.ui(12.5, AppText.w4, color: AppColors.ink2),
                  ),
                ],
              ),
            ),
            Semantics(
              button: true,
              label: l.goToCharge,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onGo,
                child: Container(
                  height: 58,
                  padding: const EdgeInsets.only(left: 30, right: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(29),
                    boxShadow: AppShadows.orangeButton,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l.goToCharge,
                        style: AppText.ui(
                          16,
                          AppText.w6,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: .16),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: AppIconView(
                            AppIcon.send,
                            size: 19,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
