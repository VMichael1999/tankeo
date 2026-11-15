import 'package:flutter_test/flutter_test.dart';
import 'package:tankeo/core/domain/fuel_type.dart';
import 'package:tankeo/core/toast/toast_service.dart';
import 'package:tankeo/core/utils/clock.dart';
import 'package:tankeo/features/auth/auth_repository.dart';
import 'package:tankeo/features/fueling/bloc/fueling_bloc.dart';
import 'package:tankeo/features/fueling/data/fault_simulator.dart';
import 'package:tankeo/features/fueling/data/fueling_session_repository.dart';
import 'package:tankeo/features/fueling/data/infogas_service.dart';
import 'package:tankeo/features/fueling/data/pump_session_repository.dart';
import 'package:tankeo/features/fueling/domain/fueling_result.dart';
import 'package:tankeo/features/payment/bloc/payment_bloc.dart';
import 'package:tankeo/features/payment/data/payment_use_cases.dart';
import 'package:tankeo/features/queue/queue_cubit.dart';
import 'package:tankeo/features/stations/data/station_repository.dart';
import 'package:tankeo/features/stations/domain/station.dart';
import 'package:tankeo/features/stations/domain/station_filter.dart';
import 'package:tankeo/features/vehicle/data/vehicle_repository.dart';

void main() {
  late FaultSimulator faults;
  late ToastService toast;
  late FuelingSessionRepository session;

  setUp(() {
    faults = FaultSimulator();
    toast = ToastService();
    session = FuelingSessionRepository();
  });

  FuelingBloc fueling() => FuelingBloc(
    stations: const InMemoryStationRepository(),
    vehicle: InMemoryVehicleRepository(),
    session: session,
    pump: SimulatedPumpSessionRepository(
      tick: const Duration(milliseconds: 1),
      faults: faults,
    ),
    infogas: SimulatedInfogasService(delay: Duration.zero, faults: faults),
    toast: toast,
    clock: FixedClock(DateTime(2026, 11, 13)),
    gasolineConnectDelay: Duration.zero,
    hangUpDelay: Duration.zero,
  );

  Future<void> authorizeGnv(FuelingBloc b) async {
    b.add(const AuthorizePressed(reduceMotion: true));
    await b.stream.firstWhere((s) => s is SafetyCheck);
    for (var i = 0; i < 3; i++) {
      b.add(SafetyItemToggled(i));
    }
    await Future<void>.delayed(const Duration(milliseconds: 5));
    b.add(const SafetyConfirmed(reduceMotion: true));
  }

  group('errores de la carga', () {
    test('certificación vencida: Infogas rechaza el chip y vuelve a Idle sin cobrar', () async {
      faults.setCertExpired(true);
      final b = fueling();
      await authorizeGnv(b);
      final s = await b.stream.firstWhere(
        (s) => s is Idle && s.issue != null,
      ) as Idle;
      expect(s.issue, FuelingIssue.certExpired);
      expect(s.certExpiredOn, DateTime(2026, 10, 18));
      expect(session.status, SessionStatus.idle);
      b.add(const IssueDismissed());
      expect(
        (await b.stream.firstWhere((s) => s is Idle && s.issue == null))
            .isIdleLike,
        isTrue,
      );
    });

    test(
      'surtidor sin conexión: una sola vez, luego se puede reintentar',
      () async {
        faults.setPumpOffline(true);
        final b = fueling()..add(const FuelChanged(TankKind.gasoline));
        await Future<void>.delayed(const Duration(milliseconds: 5));
        b.add(const AuthorizePressed(reduceMotion: true));
        final s = await b.stream.firstWhere(
          (s) => s is Idle && s.issue != null,
        ) as Idle;
        expect(s.issue, FuelingIssue.pumpOffline);
        expect(faults.pumpOffline, isFalse);
        b.add(const IssueDismissed());
        await Future<void>.delayed(const Duration(milliseconds: 5));
        b.add(const AuthorizePressed(reduceMotion: true));
        await b.stream.firstWhere((s) => s is Dispensing);
      },
    );

    test('usar otro surtidor reasigna el número', () async {
      final b = fueling()..add(const AnotherPumpRequested());
      final s = await b.stream.firstWhere((s) => s.config.pumpOverride != null);
      expect(s.config.pumpOverride, '2 · Isla A');
    });

    test(
      'pago rechazado: vuelve a editar sin cobrar y deja el pago pendiente',
      () async {
        faults.setPaymentDeclined(true);
        final b =
            PaymentBloc(
                session: FuelingSessionRepository(
                  seed: FuelingResult.sample(at: DateTime(2026, 11, 13)),
                ),
                stations: const InMemoryStationRepository(),
                auth: FakeAuthRepository(),
                toast: toast,
                pay: PayUseCase(delay: Duration.zero, faults: faults),
                issue: const IssueTaxDocumentUseCase(),
              )
              ..add(const PayPressed())
              ..add(const PaymentConfirmed());
        final s = await b.stream.firstWhere((s) => s.declined != null);
        expect(s.step, PaymentStep.editing);
        expect(s.declined!.amount, 19.01);
        expect(s.document, isNull);
      },
    );
  });

  group('cola en grifo lleno', () {
    test('2 → 1 → te toca, y queda atendido', () async {
      final q = QueueCubit(toast)..join(3, reduceMotion: true);
      expect(q.state.status, QueueStatus.waiting);
      expect(q.state.position, 2);
      final ready = await q.stream.firstWhere(
        (s) => s.status == QueueStatus.ready,
      );
      expect(ready.position, 0);
      q.serve();
      expect(q.state.isServed(3), isTrue);
      expect(q.state.visible, isFalse);
    });

    test('salir de la cola avisa y la cierra', () async {
      final events = <AppToast>[];
      toast.events.listen((e) => events.add(e.kind));
      final q = QueueCubit(toast)..join(3);
      q.leave();
      await Future<void>.delayed(Duration.zero);
      expect(q.state.visible, isFalse);
      expect(events, [AppToast.leftQueue]);
    });
  });

  group('filtros del mapa', () {
    final stations = const InMemoryStationRepository().getStations();

    test('sin filtros activos solo cuenta «Pago desde la app»', () {
      expect(const StationFilter().activeCount, 1);
      expect(const StationFilter(appPayment: false).activeCount, 0);
    });

    test('con surtidores libres oculta Benavides', () {
      const f = StationFilter(onlyFree: true);
      expect(stations.where(f.matches).length, 3);
      expect(f.matches(stations[3]), isFalse);
    });

    test('distancia máxima y servicios', () {
      expect(stations.where(const StationFilter(maxKm: 2).matches).length, 1);
      expect(stations.where(const StationFilter(maxKm: 5).matches).length, 4);
      final f = StationFilter(
        services: {StationService.wash, StationService.store},
      );
      expect(
        stations.where(f.matches).map((s) => s.name),
        ['EcoGrifo Javier Prado', 'GasNorte Arequipa'].followedBy([
          'Grifo Benavides Express',
        ]).toList()..remove('GasNorte Arequipa'),
      );
    });
  });
}
