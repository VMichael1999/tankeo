import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tankeo/core/domain/fuel_type.dart';
import 'package:tankeo/core/toast/toast_service.dart';
import 'package:tankeo/features/fueling/data/fueling_session_repository.dart';
import 'package:tankeo/features/fueling/domain/fueling_result.dart';
import 'package:tankeo/features/stations/bloc/stations_bloc.dart';
import 'package:tankeo/features/stations/data/station_repository.dart';

void main() {
  late FuelingSessionRepository session;
  late ToastService toast;
  late List<AppToast> toasts;

  setUp(() {
    session = FuelingSessionRepository();
    toast = ToastService();
    toasts = [];
    toast.events.listen((e) => toasts.add(e.kind));
  });

  StationsBloc build() => StationsBloc(
    repository: const InMemoryStationRepository(),
    session: session,
    toast: toast,
  );

  test('el más barato por combustible se calcula una sola vez', () {
    final s = build().state;
    expect(s.cheapestByFuel[FuelType.gnv], 3); // Grifo Benavides Express
    expect(s.cheapestByFuel[FuelType.regular], 0);
    expect(s.cheapestByFuel[FuelType.premium], 0);
    expect(s.cheapestByFuel[FuelType.diesel], 0);
    expect(s.filter, FuelType.gnv);
  });

  blocTest<StationsBloc, StationsState>(
    'el filtro de diésel solo muestra precios y avisa',
    build: build,
    act: (b) => b.add(const FilterChanged(FuelType.diesel)),
    verify: (b) async {
      await Future<void>.delayed(Duration.zero);
      expect(b.state.filter, FuelType.diesel);
      expect(toasts, [AppToast.dieselInfo]);
    },
  );

  blocTest<StationsBloc, StationsState>(
    'ir a cargar con una sesión activa en otro grifo se bloquea',
    build: build,
    setUp: () => session.markActive(0),
    act: (b) => b.add(const GoToFuel(1)),
    verify: (b) async {
      await Future<void>.delayed(Duration.zero);
      expect(b.state.effect, isNull);
      expect(toasts, [AppToast.finishCurrentCharge]);
    },
  );

  blocTest<StationsBloc, StationsState>(
    'ir a cargar con un pago pendiente lleva al Resumen',
    build: build,
    setUp: () => session.markAwaitingPayment(FuelingResult.sample()),
    act: (b) => b.add(const GoToFuel(0)),
    verify: (b) {
      expect(b.state.effect?.kind, StationsEffectKind.openSummary);
    },
  );

  blocTest<StationsBloc, StationsState>(
    'ir a cargar libre abre la carga y avisa el surtidor',
    build: build,
    act: (b) => b.add(const GoToFuel(3)),
    verify: (b) async {
      await Future<void>.delayed(Duration.zero);
      expect(b.state.effect?.kind, StationsEffectKind.openCharge);
      expect(toasts, [AppToast.arrived]);
    },
  );
}
