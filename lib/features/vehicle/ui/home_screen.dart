import '../../../app/di.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'dart:ui' as ui;

import '../../../core/domain/fuel_type.dart';
import '../../../core/icons/icons.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/tankeo_tokens.dart';
import '../../../core/toast/toast_service.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/money.dart';
import '../../../core/utils/volume_format.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/drop_shadow_image.dart';
import '../../../core/widgets/dual_tank_card.dart';
import '../../../core/widgets/gnv_certification_card.dart';
import '../../../core/widgets/mini_map.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/quick_control_tile.dart';
import '../../../core/widgets/tire_pressure_card.dart';
import '../../../core/widgets/weekly_spend_bars.dart';
import '../../auth/auth_repository.dart';
import '../../fueling/bloc/fueling_bloc.dart';
import '../../fueling/data/fault_simulator.dart';
import '../../stations/bloc/stations_bloc.dart';
import '../../account/bloc/notifications_cubit.dart';
import '../bloc/vehicle_cubit.dart';
import '../domain/vehicle.dart';

/// Inicio: el auto dual, el grifo más barato, controles, certificación GNV,
/// gasto de la semana y llantas.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.clock = const SystemClock()});

  final Clock clock;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scroll = ScrollController();
  bool _scrolled = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      final past = _scroll.offset >= 200;
      if (past != _scrolled) setState(() => _scrolled = past);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  String _greeting(BuildContext context, String name) {
    final l = context.l10n;
    final h = widget.clock.now().hour;
    if (h < 12) return l.greetingMorning(name);
    if (h < 19) return l.greetingAfternoon(name);
    return l.greetingEvening(name);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final user = context.read<AuthRepository>().currentUser;
    final vehicleState = context.watch<VehicleCubit>().state;
    final fueling = context.watch<FuelingBloc>().state;
    final stations = context.watch<StationsBloc>().state;
    final vehicle = vehicleState.vehicle;

    // Niveles en vivo si se está cargando (el prototipo los refleja en Inicio).
    int pct(TankKind t) {
      final base = vehicle.level(t);
      final live = fueling.config.tank == t ? fueling.liveLevel(base) : base;
      return live.round();
    }

    final lg = pct(TankKind.gasoline), ln = pct(TankKind.gnv);
    final range =
        vehicle.range(TankKind.gasoline, pct: lg.toDouble()) +
        vehicle.range(TankKind.gnv, pct: ln.toDouble());
    final cheapestGnv = stations
        .stations[stations.cheapestByFuel[FuelType.gnv]!]
        .priceOf(FuelType.gnv);
    final controls = vehicleState.controls;
    final cubit = context.read<VehicleCubit>();
    final cert = vehicleState.certification;
    final now = widget.clock.now();
    final first = stations.stations.first;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _scrolled ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: Stack(
          children: [
            SingleChildScrollView(
              controller: _scroll,
              child: Column(
                children: [
                  _Header(
                    greeting: _greeting(context, user.firstName),
                    carLabel: l.homeCarSubtitle,
                    carSemantic: l.carSemanticYear,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 140),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: 112,
                                child: DualTankCard(
                                  gasolinePercent: lg,
                                  gnvPercent: ln,
                                  totalRange: range,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 100,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: _MiniStat(
                                        icon: AppIcon.route,
                                        color: AppColors.primary,
                                        value: l.odometerValue(
                                          VolumeFormat.grouped(
                                            vehicle.odometerKm,
                                          ),
                                        ),
                                        label: l.homeOdometer,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Expanded(
                                      child: _MiniStat(
                                        icon: AppIcon.coin,
                                        color: AppColors.gnv,
                                        value: Money.format(cheapestGnv),
                                        label: l.homeCheapestGnv,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _FindCard(
                          eta: l.etaMinKm(
                            first.driveMinutes,
                            first.distanceKm.toString(),
                          ),
                          onSeeStations: () => context.go('/map'),
                        ),
                        _SectionHeader(
                          title: l.homeQuickControls,
                          action: l.homeEdit,
                        ),
                        _QuickControls(
                          doorsOn: controls[QuickControl.doors] ?? false,
                          gnvOn: controls[QuickControl.gnv] ?? false,
                          lightsOn: controls[QuickControl.lights] ?? false,
                          capOn: controls[QuickControl.fuelCap] ?? false,
                          onToggle: (c) {
                            cubit.toggle(c);
                            if (c == QuickControl.gnv &&
                                context.read<FuelingBloc>().state is Idle) {
                              final turnOn =
                                  !(controls[QuickControl.gnv] ?? false);
                              context.read<FuelingBloc>().add(
                                FuelChanged(
                                  turnOn ? TankKind.gnv : TankKind.gasoline,
                                ),
                              );
                              context.read<ToastService>().show(
                                turnOn
                                    ? AppToast.gnvPreferred
                                    : AppToast.gasolineOnly,
                              );
                            }
                          },
                        ),
                        ListenableBuilder(
                          listenable: getIt<FaultSimulator>(),
                          builder: (context, _) => GestureDetector(
                            onTap: () => context.push('/certification'),
                            child: GnvCertificationCard(
                              cylinder: cert.cylinder,
                              validUntil: cert.validUntil,
                              daysLeft: cert.daysLeft(now),
                              progress: cert.progress,
                              nextReview: cert.nextReview,
                              expired: getIt<FaultSimulator>().certExpired,
                            ),
                          ),
                        ),
                        WeeklySpendBars(
                          total: vehicleState.weeklySpend.total,
                          saved: vehicleState.weeklySpend.savedWithGnv,
                          barHeights: vehicleState.weeklySpend.barHeights,
                          todayIndex: vehicleState.weeklySpend.todayIndex,
                          todayAmount: vehicleState.weeklySpend.todayAmount,
                        ),
                        TirePressureCard(
                          psi: vehicleState.tires.psi,
                          celsius: vehicleState.tires.celsius,
                          lowThreshold: TirePressure.lowThreshold,
                        ),
                        const _DuoCard(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Velo de la barra de estado al bajar.
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: 58,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: _scrolled ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: ColoredBox(
                        color: AppColors.bg.withValues(alpha: .92),
                      ),
                    ),
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

class _Header extends StatelessWidget {
  const _Header({
    required this.greeting,
    required this.carLabel,
    required this.carSemantic,
  });

  final String greeting;
  final String carLabel;
  final String carSemantic;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: TankeoTokens.homeHeader),
            ),
          ),
          Positioned(
            left: 26,
            top: 78,
            right: 26,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: AppText.ui(
                    31,
                    AppText.w8,
                    color: AppColors.white,
                    height: 1.15,
                    letterSpacing: -.62,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  carLabel,
                  style: AppText.ui(
                    13.5,
                    AppText.w4,
                    color: AppColors.white.withValues(alpha: .45),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 24,
            top: 70,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => context.push('/notifications'),
              child: Semantics(
                button: true,
                label: context.l10n.notifications,
                child: SizedBox(
                  width: 46,
                  height: 46,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: .08),
                          shape: BoxShape.circle,
                        ),
                        child: const SizedBox(
                          width: 46,
                          height: 46,
                          child: Center(
                            child: AppIconView(
                              AppIcon.bell,
                              size: 20,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                      if (context.watch<NotificationsCubit>().state.unread > 0)
                        Positioned(
                          top: 4,
                          right: 2,
                          child: Container(
                            width: 18,
                            height: 18,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.danger,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Text(
                              '${context.watch<NotificationsCubit>().state.unread}',
                              style: AppText.ui(
                                10.5,
                                AppText.w7,
                                color: AppColors.white,
                                height: 18 / 10.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: -18,
            top: 168,
            width: 300,
            height: 133,
            child: Semantics(
              image: true,
              label: carSemantic,
              child: DropShadowImage(
                asset: AppImages.carSide,
                shadowColor: AppColors.black.withValues(alpha: .45),
                offsetY: 18,
                blur: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  final AppIcon icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              AppIconView(icon, size: 20, color: color),
              const SizedBox(height: 12),
              Text(value, style: AppText.ui(19, AppText.w8)),
              Text(
                label,
                style: AppText.ui(12.5, AppText.w4, color: AppColors.ink2),
              ),
            ],
          ),
          const Positioned(
            right: -2,
            top: 0,
            child: AppIconView(AppIcon.chev, size: 17, color: AppColors.ink2),
          ),
        ],
      ),
    );
  }
}

class _FindCard extends StatelessWidget {
  const _FindCard({required this.eta, required this.onSeeStations});

  final String eta;
  final VoidCallback onSeeStations;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AppCard(
      clip: true,
      child: SizedBox(
        height: 170,
        child: Stack(
          children: [
            const Positioned(
              right: 0,
              top: 0,
              width: 230,
              height: 170,
              child: MiniMap(),
            ),
            Positioned(
              left: 232,
              top: 116,
              width: 70,
              height: 31,
              child: Image.asset(AppImages.carSide, fit: BoxFit.contain),
            ),
            Positioned(
              right: 16,
              top: 14,
              child: Container(
                height: 28,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: AppShadows.ctaSoft,
                ),
                child: Row(
                  children: [
                    const AppIconView(
                      AppIcon.route,
                      size: 13,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(eta, style: AppText.ui(12, AppText.w7)),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 20,
              top: 24,
              width: 180,
              child: Text(
                l.homeFindCheapest,
                style: AppText.ui(17, AppText.w8),
              ),
            ),
            Positioned(
              left: 20,
              bottom: 22,
              child: PrimaryButton(
                label: l.homeSeeStations,
                color: AppColors.primary,
                width: 138,
                height: 46,
                radius: 23,
                onPressed: onSeeStations,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.action});

  final String title;
  final String action;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 26, 4, 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppText.ui(18, AppText.w8)),
        Text(
          action,
          style: AppText.ui(13.5, AppText.w6, color: AppColors.primary),
        ),
      ],
    ),
  );
}

class _QuickControls extends StatelessWidget {
  const _QuickControls({
    required this.doorsOn,
    required this.gnvOn,
    required this.lightsOn,
    required this.capOn,
    required this.onToggle,
  });

  final bool doorsOn;
  final bool gnvOn;
  final bool lightsOn;
  final bool capOn;
  final ValueChanged<QuickControl> onToggle;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    Widget tile(
      QuickControl c,
      AppIcon icon,
      String title,
      bool on,
      String onText,
      String offText,
    ) => Expanded(
      child: QuickControlTile(
        icon: icon,
        title: title,
        status: on ? onText : offText,
        on: on,
        onTap: () => onToggle(c),
      ),
    );
    return Row(
      children: [
        tile(
          QuickControl.doors,
          AppIcon.lock,
          l.controlDoors,
          doorsOn,
          l.controlDoorsOn,
          l.controlDoorsOff,
        ),
        const SizedBox(width: 10),
        tile(
          QuickControl.gnv,
          AppIcon.cylinder,
          l.fuelGnv,
          gnvOn,
          l.controlGnvOn,
          l.controlGnvOff,
        ),
        const SizedBox(width: 10),
        tile(
          QuickControl.lights,
          AppIcon.lamp,
          l.controlLights,
          lightsOn,
          l.controlLightsOn,
          l.controlLightsOff,
        ),
        const SizedBox(width: 10),
        tile(
          QuickControl.fuelCap,
          AppIcon.pump,
          l.controlCap,
          capOn,
          l.controlCapOn,
          l.controlCapOff,
        ),
      ],
    );
  }
}

class _DuoCard extends StatelessWidget {
  const _DuoCard();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    Widget half(
      AppIcon icon,
      Color color,
      String value,
      String label, {
      bool border = false,
    }) => Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          border: border
              ? const Border(left: BorderSide(color: AppColors.line))
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.warmTile,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: AppIconView(icon, size: 20, color: color)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: AppText.ui(18, AppText.w8)),
                  Text(
                    label,
                    style: AppText.ui(12, AppText.w4, color: AppColors.ink2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    return AppCard(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: IntrinsicHeight(
        child: Row(
          children: [
            half(
              AppIcon.cylinder,
              AppColors.gnv,
              l.gnvSavingsValue,
              l.gnvSavingsLabel,
            ),
            half(
              AppIcon.gauge,
              AppColors.primary,
              l.gnvEfficiencyValue,
              l.gnvEfficiencyLabel,
              border: true,
            ),
          ],
        ),
      ),
    );
  }
}
