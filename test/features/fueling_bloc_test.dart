import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tankeo/core/domain/fuel_type.dart';
import 'package:tankeo/core/toast/toast_service.dart';
import 'package:tankeo/core/utils/clock.dart';
import 'package:tankeo/features/fueling/bloc/fueling_bloc.dart';
import 'package:tankeo/features/fueling/data/fueling_session_repository.dart';
import 'package:tankeo/features/fueling/data/infogas_service.dart';
import 'package:tankeo/features/fueling/data/pump_session_repository.dart';
import 'package:tankeo/features/fueling/domain/amount_preset.dart';
import 'package:tankeo/features/stations/data/station_repository.dart';
import 'package:tankeo/features/vehicle/data/vehicle_repository.dart';

class _MockInfogas extends Mock implements InfogasService {}

void main() {
  setUpAll(
    () => registerFallbackValue(InMemoryVehicleRepository().certification),
  );

  late InMemoryVehicleRepository vehicle;
  late FuelingSessionRepository session;
  late ToastService toast;
  late List<AppToast> toasts;
  late _MockInfogas infogas;

  setUp(() {
    vehicle = InMemoryVehicleRepository();
    session = FuelingSessionRepository();
    toast = ToastService();
    toasts = [];
    toast.events.listen((e) => toasts.add(e.kind));
    infogas = _MockInfogas();
    when(() => infogas.validateChip(any())).thenAnswer(
      (_) async =>
          ChipValidated(certificationValidUntil: DateTime(2027, 1, 18)),
    );
  });

  FuelingBloc build({PumpSessionRepository? pump}) => FuelingBloc(
    stations: const InMemoryStationRepository(),
    vehicle: vehicle,
    session: session,
    pump:
        pump ??
        SimulatedPumpSessionRepository(tick: const Duration(milliseconds: 1)),
    infogas: infogas,
    toast: toast,
    clock: FixedClock(DateTime(2026, 11, 13, 16, 20)),
    gasolineConnectDelay: Duration.zero,
    hangUpDelay: Duration.zero,
  );

  group('configuración en Idle', () {
    blocTest<FuelingBloc, FuelingState>(
      'cambia de combustible y de monto',
      build: build,
      act: (b) => b
        ..add(const FuelChanged(TankKind.gasoline))
        ..add(const PresetChanged(AmountPreset.soles(20))),
      verify: (b) {
        expect(b.state.config.tank, TankKind.gasoline);
        expect(b.state.config.preset, const AmountPreset.soles(20));
      },
    );

    blocTest<FuelingBloc, FuelingState>(
      'un monto que no cabe no se acepta',
      build: build,
      act: (b) => b.add(const PresetChanged(AmountPreset.soles(100))),
      expect: () => <FuelingState>[],
    );

    blocTest<FuelingBloc, FuelingState>(
      'el combustible llega desde el mapa por el repositorio de sesión',
      build: build,
      act: (b) => session.selectFuel(FuelType.premium, stationIndex: 2),
      wait: const Duration(milliseconds: 20),
      verify: (b) {
        expect(b.state.config.tank, TankKind.gasoline);
        expect(b.state.config.grade, FuelType.premium);
        expect(b.state.config.stationIndex, 2);
      },
    );
  });

  group('GNV', () {
    blocTest<FuelingBloc, FuelingState>(
      'secuencia completa: checklist, chip, despacho, colgar y pago pendiente',
      build: build,
      act: (b) async {
        b.add(const AuthorizePressed());
        await Future<void>.delayed(const Duration(milliseconds: 5));
        expect(b.state, isA<SafetyCheck>());
        b.add(const SafetyConfirmed()); // sin casillas: se ignora
        await Future<void>.delayed(const Duration(milliseconds: 5));
        expect(b.state, isA<SafetyCheck>());
        for (var i = 0; i < 3; i++) {
          b.add(SafetyItemToggled(i));
        }
        await Future<void>.delayed(const Duration(milliseconds: 5));
        b.add(const SafetyConfirmed(reduceMotion: true));
        await b.stream.firstWhere((s) => s is Connecting);
        await b.stream.firstWhere((s) => s is Dispensing);
        await b.stream
            .firstWhere((s) => s is Completed)
            .timeout(const Duration(seconds: 5));
        b.add(const HangUpPressed());
        await b.stream.firstWhere((s) => s is AwaitingPayment);
      },
      verify: (b) {
        final s = b.state as AwaitingPayment;
        expect(s.result.fuel, FuelType.gnv);
        expect(s.result.total, 19.01);
        expect(s.chipValidated, isTrue);
        expect(vehicle.vehicle.gnvLevel, 100);
        expect(session.status, SessionStatus.awaitingPayment);
        expect(toasts, contains(AppToast.chipValidated));
      },
      wait: const Duration(milliseconds: 50),
    );

    blocTest<FuelingBloc, FuelingState>(
      'cancelar el checklist vuelve a Idle',
      build: build,
      act: (b) async {
        b.add(const AuthorizePressed());
        await Future<void>.delayed(const Duration(milliseconds: 5));
        b.add(const SafetyCancelled());
      },
      verify: (b) => expect(b.state, isA<Idle>()),
    );
  });

  group('gasolina', () {
    blocTest<FuelingBloc, FuelingState>(
      'pasa directo a Connecting sin checklist y carga S/ 50',
      build: build,
      act: (b) async {
        b
          ..add(const FuelChanged(TankKind.gasoline))
          ..add(const GradeChanged(FuelType.premium));
        await Future<void>.delayed(const Duration(milliseconds: 5));
        b.add(const AuthorizePressed(reduceMotion: true));
        await b.stream.firstWhere((s) => s is Connecting);
        await b.stream
            .firstWhere((s) => s is Completed)
            .timeout(const Duration(seconds: 5));
        b.add(const HangUpPressed());
        await b.stream.firstWhere((s) => s is AwaitingPayment);
      },
      verify: (b) {
        final s = b.state as AwaitingPayment;
        expect(s.result.fuel, FuelType.premium);
        expect(s.result.total, 50.00);
        verifyNever(() => infogas.validateChip(any()));
      },
      wait: const Duration(milliseconds: 50),
    );
  });

  group('detener y bloqueos', () {
    blocTest<FuelingBloc, FuelingState>(
      'detener antes de terminar deja la carga a medias',
      build: () => build(
        pump: SimulatedPumpSessionRepository(
          tick: const Duration(milliseconds: 5),
        ),
      ),
      act: (b) async {
        b.add(const FuelChanged(TankKind.gasoline));
        await Future<void>.delayed(const Duration(milliseconds: 5));
        b.add(const AuthorizePressed()); // duración normal (> 5 s)
        await b.stream.firstWhere((s) => s is Dispensing);
        await Future<void>.delayed(const Duration(milliseconds: 300));
        b.add(const StopPressed());
        await b.stream.firstWhere((s) => s is Completed);
      },
      verify: (b) {
        final s = b.state as Completed;
        expect(s.stopped, isTrue);
        expect(s.volume, lessThan(s.target));
      },
      wait: const Duration(milliseconds: 50),
    );

    blocTest<FuelingBloc, FuelingState>(
      'no se cambia de combustible fuera de Idle',
      build: build,
      act: (b) async {
        b.add(const FuelChanged(TankKind.gasoline));
        await Future<void>.delayed(const Duration(milliseconds: 5));
        b.add(const AuthorizePressed(reduceMotion: true));
        await b.stream.firstWhere((s) => s is Connecting);
        b.add(const FuelChanged(TankKind.gnv));
        b.add(const GradeChanged(FuelType.premium));
        b.add(const PresetChanged(AmountPreset.soles(20)));
      },
      verify: (b) {
        expect(b.state.config.tank, TankKind.gasoline);
        expect(b.state.config.grade, FuelType.regular);
      },
      wait: const Duration(milliseconds: 30),
    );
  });
}
