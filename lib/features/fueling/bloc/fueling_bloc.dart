import 'dart:async';
import 'dart:math' as math;

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/domain/fuel_type.dart';
import '../../../core/toast/toast_service.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/money.dart';
import '../../stations/data/station_repository.dart';
import '../../vehicle/data/vehicle_repository.dart';
import '../data/fueling_session_repository.dart';
import '../data/infogas_service.dart';
import '../data/pump_session_repository.dart';
import '../domain/amount_preset.dart';
import '../domain/connect_pump_flow.dart';
import '../domain/fuel_quote.dart';
import '../domain/fueling_config.dart';
import '../domain/fueling_result.dart';

part 'fueling_event.dart';
part 'fueling_state.dart';

/// Orquesta la carga de combustible: configuración, lista de seguridad,
/// conexión, despacho en vivo, colgar la manguera y pago pendiente.
class FuelingBloc extends Bloc<FuelingEvent, FuelingState> {
  FuelingBloc({
    required StationRepository stations,
    required VehicleRepository vehicle,
    required FuelingSessionRepository session,
    required PumpSessionRepository pump,
    required InfogasService infogas,
    required ToastService toast,
    required Clock clock,
    this.gasolineConnectDelay = const Duration(milliseconds: 1300),
    this.hangUpDelay = const Duration(milliseconds: 1500),
  }) : _stations = stations,
       _vehicle = vehicle,
       _session = session,
       _pump = pump,
       _infogas = infogas,
       _toast = toast,
       _clock = clock,
       super(const Idle(config: FuelingConfig())) {
    on<FuelChanged>(_onFuelChanged);
    on<GradeChanged>(_onGradeChanged);
    on<PresetChanged>(_onPresetChanged);
    on<AuthorizePressed>(_onAuthorize, transformer: droppable());
    on<SafetyItemToggled>(_onSafetyToggled);
    on<SafetyCancelled>(_onSafetyCancelled);
    on<SafetyConfirmed>(_onSafetyConfirmed, transformer: droppable());
    on<StopPressed>(_onStop);
    on<HangUpPressed>(_onHangUp, transformer: droppable());
    on<SheetToggled>(_onSheetToggled);
    on<ChargeScreenVisibilityChanged>(_onVisibility);
    on<FuelSelectionReceived>(_onFuelSelection);
    on<SessionSettledReceived>(_onSettled);
    on<IssueDismissed>(_onIssueDismissed);
    on<AnotherPumpRequested>(_onAnotherPump);

    _signals = _session.signals.listen((s) {
      switch (s) {
        case FuelSelected():
          add(FuelSelectionReceived(s.fuel, stationIndex: s.stationIndex));
        case SessionSettled():
          add(const SessionSettledReceived());
      }
    });
  }

  final StationRepository _stations;
  final VehicleRepository _vehicle;
  final FuelingSessionRepository _session;
  final PumpSessionRepository _pump;
  final InfogasService _infogas;
  final ToastService _toast;
  final Clock _clock;
  final Duration gasolineConnectDelay;
  final Duration hangUpDelay;

  late final StreamSubscription<SessionSignal> _signals;
  bool _stopRequested = false;

  // ---- configuración (solo en Idle) ----

  void _onFuelChanged(FuelChanged e, Emitter<FuelingState> emit) {
    if (state is! Idle) return;
    emit(
      state.copyBase(
        config: state.config.copyWith(tank: e.tank),
        chipValidated: false,
      ),
    );
  }

  void _onGradeChanged(GradeChanged e, Emitter<FuelingState> emit) {
    if (state is! Idle || e.grade == FuelType.gnv) return;
    emit(state.copyBase(config: state.config.copyWith(grade: e.grade)));
  }

  void _onPresetChanged(PresetChanged e, Emitter<FuelingState> emit) {
    if (state is! Idle) return;
    final quote = _idleQuote(state.config);
    if (!quote.fits(e.preset)) return;
    emit(state.copyBase(config: state.config.copyWith(preset: e.preset)));
  }

  void _onFuelSelection(FuelSelectionReceived e, Emitter<FuelingState> emit) {
    if (state is! Idle || e.fuel.tank == null) return;
    final tank = e.fuel.tank!;
    emit(
      state.copyBase(
        config: state.config.copyWith(
          tank: tank,
          grade: tank == TankKind.gasoline ? e.fuel : null,
          stationIndex: e.stationIndex,
        ),
        chipValidated: false,
      ),
    );
  }

  FuelQuote _idleQuote(FuelingConfig config) => FuelQuote.forConfig(
    config: config,
    vehicle: _vehicle.vehicle,
    station: _stations.getStations()[config.stationIndex],
  );

  // ---- autorización y lista de seguridad ----

  Future<void> _onAuthorize(
    AuthorizePressed e,
    Emitter<FuelingState> emit,
  ) async {
    if (state is! Idle) return;
    if (state.config.profile.requiresSafetyCheck) {
      emit(
        SafetyCheck(
          config: state.config,
          chipValidated: state.chipValidated,
          chargeScreenVisible: state.chargeScreenVisible,
        ),
      );
      return;
    }
    await _startCharge(emit, reduceMotion: e.reduceMotion);
  }

  void _onSafetyToggled(SafetyItemToggled e, Emitter<FuelingState> emit) {
    final s = state;
    if (s is SafetyCheck) emit(s.toggled(e.index));
  }

  void _onSafetyCancelled(SafetyCancelled e, Emitter<FuelingState> emit) {
    final s = state;
    if (s is SafetyCheck) {
      emit(
        Idle(
          config: s.config,
          chipValidated: s.chipValidated,
          chargeScreenVisible: s.chargeScreenVisible,
        ),
      );
    }
  }

  Future<void> _onSafetyConfirmed(
    SafetyConfirmed e,
    Emitter<FuelingState> emit,
  ) async {
    final s = state;
    if (s is! SafetyCheck || !s.allChecked) return;
    await _startCharge(emit, reduceMotion: e.reduceMotion);
  }

  // ---- conexión y despacho ----

  Future<void> _startCharge(
    Emitter<FuelingState> emit, {
    required bool reduceMotion,
  }) async {
    final config = state.config;
    final visible = state.chargeScreenVisible;
    final quote = _idleQuote(config);
    _session.markActive(config.stationIndex);
    emit(
      Connecting(
        config: config,
        quote: quote,
        chipValidated: state.chipValidated,
        chargeScreenVisible: visible,
      ),
    );

    final flow = ConnectPumpFlow.forProfile(
      config.profile,
      infogas: _infogas,
      certification: _vehicle.certification,
      gasolineDelay: gasolineConnectDelay,
    );
    ChipValidated? chip;
    try {
      chip = await flow.run();
      await _pump.connect();
    } on ChipRejected catch (e) {
      _session.markIdle();
      emit(
        Idle(
          config: config,
          chargeScreenVisible: state.chargeScreenVisible,
          issue: FuelingIssue.certExpired,
          certExpiredOn: e.expiredOn,
        ),
      );
      return;
    } on PumpOfflineException {
      _session.markIdle();
      emit(
        Idle(
          config: config,
          chipValidated: state.chipValidated,
          chargeScreenVisible: state.chargeScreenVisible,
          issue: FuelingIssue.pumpOffline,
        ),
      );
      return;
    }
    var chipOk = state.chipValidated;
    if (chip != null) {
      chipOk = true;
      _toast.show(AppToast.chipValidated);
    }

    _stopRequested = false;
    emit(
      Dispensing(
        config: config,
        quote: quote,
        volume: 0,
        sheetOpen: true,
        chipValidated: chipOk,
        chargeScreenVisible: state.chargeScreenVisible,
      ),
    );

    // 5 s + 6 s × (objetivo / capacidad); 1.2 s si se piden menos animaciones.
    final duration = reduceMotion
        ? const Duration(milliseconds: 1200)
        : Duration(
            milliseconds:
                (5000 + 6000 * (quote.targetVolume / config.tank.capacity))
                    .round(),
          );
    await emit.forEach<double>(
      _pump.dispense(target: quote.targetVolume, duration: duration),
      onData: (v) {
        final s = state;
        return s is Dispensing ? s.withVolume(v) : s;
      },
    );

    final s = state;
    if (s is! Dispensing) return;
    if (_stopRequested) {
      emit(
        Completed(
          config: s.config,
          quote: s.quote,
          volume: math.max(s.volume, .001),
          stopped: true,
          sheetOpen: s.sheetOpen,
          chipValidated: s.chipValidated,
          chargeScreenVisible: s.chargeScreenVisible,
        ),
      );
      return;
    }
    final open = !s.sheetOpen && s.chargeScreenVisible;
    emit(
      Completed(
        config: s.config,
        quote: s.quote,
        volume: s.quote!.targetVolume,
        sheetOpen: s.sheetOpen || open,
        chipValidated: s.chipValidated,
        chargeScreenVisible: s.chargeScreenVisible,
      ),
    );
    if (!s.chargeScreenVisible) _toast.show(AppToast.chargeComplete);
  }

  void _onStop(StopPressed e, Emitter<FuelingState> emit) {
    if (state is! Dispensing) return;
    _stopRequested = true;
    _pump.cancel();
  }

  Future<void> _onHangUp(HangUpPressed e, Emitter<FuelingState> emit) async {
    final s = state;
    if (s is! Completed) return;
    emit(
      HangingUp(
        config: s.config,
        quote: s.quote,
        volume: s.volume,
        stopped: s.stopped,
        sheetOpen: s.sheetOpen,
        chipValidated: s.chipValidated,
        chargeScreenVisible: s.chargeScreenVisible,
      ),
    );
    await Future<void>.delayed(hangUpDelay);

    final q = s.quote!;
    final result = FuelingResult.fromSession(
      fuel: s.config.fuelType,
      stationIndex: s.config.stationIndex,
      levelBefore: q.level,
      volume: s.volume,
      price: q.price,
      createdAt: _clock.now(),
      exactAmount: !s.stopped && q.isExactAmount ? q.preset.amount : null,
    );
    _vehicle.setLevel(q.tank, result.levelAfter);
    _session.markAwaitingPayment(result);
    emit(
      AwaitingPayment(
        config: s.config,
        result: result,
        chipValidated: s.chipValidated,
        chargeScreenVisible: s.chargeScreenVisible,
      ),
    );
  }

  void _onIssueDismissed(IssueDismissed e, Emitter<FuelingState> emit) {
    final s = state;
    if (s is Idle && s.issue != null) {
      emit(Idle(config: s.config, chargeScreenVisible: s.chargeScreenVisible));
    }
  }

  /// Reasigna otro surtidor del mismo grifo («2 · Isla A» ↔ «5 · Isla A»).
  void _onAnotherPump(AnotherPumpRequested e, Emitter<FuelingState> emit) {
    final s = state;
    if (s is! Idle) return;
    final station = _stations.getStations()[s.config.stationIndex];
    final current =
        s.config.pumpOverride?.split(' ').first ?? station.assignedPumpNumber;
    final next = '${current == '2' ? '5' : '2'} · Isla A';
    emit(
      Idle(
        config: s.config.copyWith(pumpOverride: next),
        chargeScreenVisible: s.chargeScreenVisible,
      ),
    );
    _toast.show(AppToast.newPumpAssigned, args: [next.split(' ').first]);
  }

  void _onSheetToggled(SheetToggled e, Emitter<FuelingState> emit) {
    if (state.isBusy) emit(state.copyBase(sheetOpen: e.open));
  }

  void _onVisibility(
    ChargeScreenVisibilityChanged e,
    Emitter<FuelingState> emit,
  ) => emit(state.copyBase(chargeScreenVisible: e.visible));

  void _onSettled(SessionSettledReceived e, Emitter<FuelingState> emit) {
    final s = state;
    if (s is AwaitingPayment) {
      emit(Idle(config: s.config, chargeScreenVisible: s.chargeScreenVisible));
    }
  }

  @override
  Future<void> close() {
    _signals.cancel();
    return super.close();
  }
}
