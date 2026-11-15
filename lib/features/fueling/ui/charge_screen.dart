import '../../../app/di.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/domain/fuel_type.dart';
import '../../../core/icons/icons.dart';
import '../../../core/l10n/fuel_l10n.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/tankeo_tokens.dart';
import '../../../core/utils/money.dart';
import '../../../core/utils/volume_format.dart';
import '../../../core/widgets/amount_presets.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/circle_icon_button.dart';
import '../../../core/widgets/fuel_segment.dart';
import '../../../core/widgets/grade_selector.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/error_dialog.dart';
import '../../../core/widgets/queue_dialog.dart';
import '../../../core/widgets/safety_checklist_dialog.dart';
import '../../../core/widgets/simulator_sheet.dart';
import '../../queue/queue_cubit.dart';
import '../data/fault_simulator.dart';
import '../../../core/widgets/top_down_car_tank.dart';
import '../../stations/bloc/stations_bloc.dart';
import '../../vehicle/bloc/vehicle_cubit.dart';
import '../bloc/fueling_bloc.dart';
import 'charge_sheet.dart';
import 'charge_view_model.dart';

/// Carga: elige combustible y cuánto cargar con el nivel objetivo sobre el
/// auto; autoriza el surtidor y sigue el despacho en la hoja.
class ChargeScreen extends StatefulWidget {
  const ChargeScreen({super.key});

  @override
  State<ChargeScreen> createState() => _ChargeScreenState();
}

class _ChargeScreenState extends State<ChargeScreen> {
  late final FuelingBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<FuelingBloc>()
      ..add(const ChargeScreenVisibilityChanged(visible: true));
  }

  @override
  void dispose() {
    _bloc.add(const ChargeScreenVisibilityChanged(visible: false));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: BlocListener<FuelingBloc, FuelingState>(
        listenWhen: (a, b) => a is HangingUp && b is AwaitingPayment,
        listener: (context, _) => context.go('/summary'),
        child: BlocBuilder<FuelingBloc, FuelingState>(
          builder: (context, fueling) {
            final stations = context.watch<StationsBloc>().state.stations;
            final vehicle = context.watch<VehicleCubit>().state.vehicle;
            final vm = ChargeViewModel(
              state: fueling,
              station: stations[fueling.config.stationIndex],
              vehicle: vehicle,
            );
            return Scaffold(
              backgroundColor: AppColors.bg,
              body: Stack(
                children: [
                  _Header(vm: vm),
                  Positioned(
                    left: 18,
                    right: 18,
                    top: 132,
                    child: FuelSegment(
                      selected: vm.tank,
                      enabled: fueling.isIdleLike,
                      onChanged: (k) =>
                          context.read<FuelingBloc>().add(FuelChanged(k)),
                    ),
                  ),
                  Positioned.fill(
                    top: 198,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 120),
                      child: Column(
                        children: [
                          _TankCard(vm: vm),
                          const SizedBox(height: 12),
                          _HowMuch(vm: vm),
                          const SizedBox(height: 12),
                          _ActionButton(vm: vm),
                        ],
                      ),
                    ),
                  ),
                  ChargeSheet(vm: vm),
                  _QueueHost(vm: vm),
                  _IssueHost(vm: vm),
                  SafetyChecklistDialog(
                    visible: fueling is SafetyCheck,
                    checked: fueling is SafetyCheck
                        ? fueling.checked
                        : const [false, false, false],
                    onToggle: (i) =>
                        context.read<FuelingBloc>().add(SafetyItemToggled(i)),
                    onCancel: () => context.read<FuelingBloc>().add(
                      const SafetyCancelled(),
                    ),
                    onConfirm: () => context.read<FuelingBloc>().add(
                      SafetyConfirmed(
                        reduceMotion: MediaQuery.disableAnimationsOf(context),
                      ),
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

class _Header extends StatelessWidget {
  const _Header({required this.vm});

  final ChargeViewModel vm;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Positioned(
      left: 0,
      right: 0,
      top: 62,
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          children: [
            CircleIconButton(
              icon: AppIcon.pin,
              semanticLabel: l.location,
              shadow: false,
              onPressed: () => context.go('/details'),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(vm.station.name, style: AppText.ui(17.5, AppText.w8)),
                  Text(
                    l.pumpLabel(vm.pump),
                    style: AppText.ui(12.5, AppText.w4, color: AppColors.ink2),
                  ),
                ],
              ),
            ),
            CircleIconButton(
              icon: AppIcon.dots,
              semanticLabel: l.moreOptions,
              shadow: false,
              onPressed: () =>
                  showSimulatorSheet(context, getIt<FaultSimulator>()),
            ),
          ],
        ),
      ),
    );
  }
}

class _TankCard extends StatelessWidget {
  const _TankCard({required this.vm});

  final ChargeViewModel vm;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final gnv = vm.isGnv;
    final soft = gnv ? AppColors.gnvSoft : AppColors.primarySoft;
    final fg = gnv ? AppColors.gnv : AppColors.primary;
    final chipOk = vm.state.chipValidated;
    final station = vm.station;
    final idle = vm.state.isIdleLike;
    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: soft, shape: BoxShape.circle),
                child: Center(
                  child: AppIconView(
                    gnv ? AppIcon.cylinder : AppIcon.pump,
                    size: 18,
                    color: fg,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  gnv ? l.tankGnvTitle : l.tankGasolineTitle,
                  style: AppText.ui(17, AppText.w8),
                ),
              ),
              Container(
                height: 26,
                padding: const EdgeInsets.symmetric(horizontal: 11),
                decoration: BoxDecoration(
                  color: soft,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Row(
                  children: [
                    AppIconView(
                      gnv
                          ? (chipOk ? AppIcon.check : AppIcon.chip)
                          : AppIcon.drop,
                      size: 13,
                      color: fg,
                      strokeWidth: 2.6,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      gnv
                          ? (chipOk ? l.chipValidated : l.chipInfogas)
                          : vm.fuel.longLabel(context),
                      style: AppText.ui(12, AppText.w6, color: fg),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 160,
            child: OverflowBox(
              maxWidth: 400,
              child: Center(
                child: TopDownCarTank(
                  level: vm.level,
                  targetLevel: vm.targetLevel,
                  gnv: gnv,
                  plugged: vm.plugged,
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _Stat(
                    value: '${vm.level.round()}',
                    unit: '%',
                    label: l.levelVolume(
                      VolumeFormat.d1(vm.levelVolume),
                      vm.tank.unit,
                    ),
                  ),
                ),
                const VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: AppColors.line,
                ),
                Expanded(
                  child: _Stat(
                    value: '${vm.rangeKm}',
                    unit: 'km',
                    label: gnv ? l.rangeGnv : l.rangeGasoline,
                  ),
                ),
              ],
            ),
          ),
          if (!gnv) ...[
            const SizedBox(height: 6),
            GradeSelector(
              selected: vm.state.config.grade,
              regularPrice: station.priceOf(FuelType.regular),
              premiumPrice: station.priceOf(FuelType.premium),
              enabled: idle,
              onChanged: (g) =>
                  context.read<FuelingBloc>().add(GradeChanged(g)),
            ),
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.unit, required this.label});

  final String value;
  final String unit;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text.rich(
        TextSpan(
          text: value,
          style: AppText.ui(23, AppText.w8),
          children: [
            const WidgetSpan(child: SizedBox(width: 2)),
            TextSpan(
              text: unit,
              style: AppText.ui(13, AppText.w5, color: AppColors.ink2),
            ),
          ],
        ),
      ),
      const SizedBox(height: 2),
      Text(label, style: AppText.ui(12.5, AppText.w4, color: AppColors.ink2)),
    ],
  );
}

class _HowMuch extends StatelessWidget {
  const _HowMuch({required this.vm});

  final ChargeViewModel vm;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final q = vm.quote;
    final idle = vm.state.isIdleLike;
    final profile = vm.state.config.profile;
    // Mientras se carga, los montos quedan fijos; antes, uno que no cabe se deshabilita.
    final idleQuote = vm.quote;
    return AmountPresets(
      presets: profile.presets,
      selected: vm.state.config.preset,
      enabledFor: (p) => idle && idleQuote.fits(p),
      onSelected: (p) => context.read<FuelingBloc>().add(PresetChanged(p)),
      capacityLabel: l.chargeFits(VolumeFormat.d2(q.freeVolume), vm.tank.unit),
      estimateVolume: q.targetVolume,
      unit: vm.tank.unit,
      price: vm.price,
      total: q.targetAmount,
      totalColor: vm.isGnv ? AppColors.gnv : AppColors.primary,
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.vm});

  final ChargeViewModel vm;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final s = vm.state;
    final color = vm.isGnv ? context.tokens.gnv : context.tokens.primary;
    final bloc = context.read<FuelingBloc>();
    final pump = vm.pumpNumber;
    return switch (s) {
      Idle() || SafetyCheck() => PrimaryButton(
        label: l.chargeAuthorize(pump),
        color: color,
        onPressed: () {
          final reduce = MediaQuery.disableAnimationsOf(context);
          final queue = context.read<QueueCubit>();
          final idx = s.config.stationIndex;
          if (vm.station.freePumps == 0 && !queue.state.isServed(idx)) {
            queue.join(idx, reduceMotion: reduce);
            return;
          }
          bloc.add(AuthorizePressed(reduceMotion: reduce));
        },
      ),
      Connecting() => PrimaryButton(
        label: vm.isGnv ? l.chargeValidatingChip : l.chargeConnecting,
        color: color,
        loading: true,
        onPressed: null,
      ),
      Dispensing() || Completed() => PrimaryButton(
        label: l.chargeViewPump,
        color: color,
        onPressed: () => bloc.add(const SheetToggled(true)),
      ),
      HangingUp() => PrimaryButton(
        color: color,
        spinnerOnly: true,
        onPressed: null,
      ),
      AwaitingPayment(:final result) => PrimaryButton(
        label: l.chargePay(Money.format(result.total)),
        color: color,
        onPressed: () => context.go('/summary'),
      ),
    };
  }
}

/// Diálogo de la cola en un grifo lleno.
class _QueueHost extends StatelessWidget {
  const _QueueHost({required this.vm});

  final ChargeViewModel vm;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QueueCubit, QueueState>(
      builder: (context, q) {
        final isle = vm.pump.contains('·') ? vm.pump.split('· ').last : vm.pump;
        return QueueDialog(
          visible: q.visible,
          progress: q.progress,
          position: q.position,
          minutesLeft: q.minutesLeft,
          stationName: vm.station.name,
          pumpNumber: vm.pumpNumber,
          isle: isle.toLowerCase(),
          onLeave: () => context.read<QueueCubit>().leave(),
          onGo: () {
            context.read<QueueCubit>().serve();
            context.read<FuelingBloc>().add(
              AuthorizePressed(
                reduceMotion: MediaQuery.disableAnimationsOf(context),
              ),
            );
          },
        );
      },
    );
  }
}

/// Diálogo de error del surtidor o del chip Infogas (la sesión vuelve a `Idle`).
class _IssueHost extends StatefulWidget {
  const _IssueHost({required this.vm});

  final ChargeViewModel vm;

  @override
  State<_IssueHost> createState() => _IssueHostState();
}

class _IssueHostState extends State<_IssueHost> {
  FuelingIssue _last = FuelingIssue.pumpOffline;
  DateTime _expired = DateTime(2026, 10, 18);

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final s = widget.vm.state;
    final issue = s is Idle ? s.issue : null;
    if (issue != null) {
      _last = issue;
      _expired = (s as Idle).certExpiredOn ?? _expired;
    }
    final bloc = context.read<FuelingBloc>();
    final cert = _last == FuelingIssue.certExpired;
    final date = DateFormat(
      'd MMM yyyy',
      'es',
    ).format(_expired).replaceAll('.', '').toUpperCase();
    return ErrorDialog(
      visible: issue != null,
      title: cert ? l.errCertTitle : l.errPumpTitle(widget.vm.pumpNumber),
      body: cert
          ? [
              TextSpan(text: l.errCertBodyA),
              ErrorDialog.bold(l.errCertBodyB(date)),
              TextSpan(text: l.errCertBodyC),
            ]
          : [TextSpan(text: l.errPumpBody)],
      secondaryLabel: cert ? l.errCertGasoline : l.errPumpOther,
      primaryLabel: cert ? l.errCertView : l.errRetry,
      onSecondary: () {
        if (cert) {
          bloc
            ..add(const IssueDismissed())
            ..add(const FuelChanged(TankKind.gasoline));
        } else {
          bloc.add(const AnotherPumpRequested());
        }
      },
      onPrimary: () {
        bloc.add(const IssueDismissed());
        if (cert) {
          context.push('/certification');
        } else {
          bloc.add(
            AuthorizePressed(
              reduceMotion: MediaQuery.disableAnimationsOf(context),
            ),
          );
        }
      },
    );
  }
}
