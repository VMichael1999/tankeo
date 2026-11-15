import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tankeo/core/domain/fuel_type.dart';
import 'package:tankeo/core/toast/toast_service.dart';
import 'package:tankeo/core/utils/clock.dart';
import 'package:tankeo/features/account/bloc/billing_cubit.dart';
import 'package:tankeo/features/account/bloc/history_cubit.dart';
import 'package:tankeo/features/account/bloc/payment_methods_cubit.dart';
import 'package:tankeo/features/account/bloc/points_cubit.dart';
import 'package:tankeo/features/account/bloc/vehicles_cubit.dart';
import 'package:tankeo/features/account/domain/account_models.dart';
import 'package:tankeo/features/account/domain/card_validator.dart';
import 'package:tankeo/features/account/domain/password_strength.dart';
import 'package:tankeo/features/auth/auth_repository.dart';
import 'package:tankeo/features/auth/bloc/password_reset_bloc.dart';
import 'package:tankeo/features/auth/bloc/sign_up_bloc.dart';
import 'package:tankeo/features/navigation/bloc/navigation_bloc.dart';
import 'package:tankeo/features/navigation/data/route_simulator.dart';
import 'package:tankeo/features/navigation/domain/route_path.dart';
import 'package:tankeo/features/navigation/domain/turn_instruction.dart';
import 'package:tankeo/features/stations/data/station_repository.dart';

void main() {
  group('Tarjeta', () {
    test('Luhn, marca y fecha', () {
      expect(CardValidator.luhn('4111 1111 1111 1111'), isTrue);
      expect(CardValidator.luhn('4111 1111 1111 1112'), isFalse);
      expect(CardValidator.brand('4111'), CardBrand.visa);
      expect(CardValidator.brand('5105'), CardBrand.mastercard);
      expect(CardValidator.brand('2221'), CardBrand.mastercard);
      expect(CardValidator.brand('3714'), CardBrand.amex);
      final now = DateTime(2026, 11, 15);
      expect(CardValidator.expiryValid('12/26', now), isTrue);
      expect(CardValidator.expiryValid('10/26', now), isFalse);
      expect(CardValidator.expiryValid('13/28', now), isFalse);
      expect(CardValidator.cvvValid('123'), isTrue);
      expect(CardValidator.cvvValid('12'), isFalse);
      expect(CardValidator.holderValid('Michael Dev'), isTrue);
      expect(CardValidator.holderValid('Michael'), isFalse);
      expect(CardValidator.format('4111111111111111'), '4111 1111 1111 1111');
    });

    test('contraseña: 2 de 3 reglas', () {
      expect(PasswordStrength.score('abc'), 0);
      expect(PasswordStrength.isAcceptable('abcdefgh'), isFalse);
      expect(PasswordStrength.isAcceptable('Abcdefg1'), isTrue);
      expect(PasswordStrength.score('Abcdefg1!'), 3);
    });
  });

  group('SignUpBloc', () {
    late VehiclesCubit vehicles;
    late PointsCubit points;
    late FakeAuthRepository auth;
    SignUpBloc build({bool addMode = false}) => SignUpBloc(
      auth: auth,
      vehicles: vehicles,
      points: points,
      addMode: addMode,
    );

    setUp(() {
      vehicles = VehiclesCubit();
      points = PointsCubit(FixedClock(DateTime.utc(2026, 11, 15)));
      auth = FakeAuthRepository(delay: Duration.zero);
    });

    void fill(SignUpBloc b, Map<SignUpField, Object> f) {
      for (final e in f.entries) {
        b.add(SignUpFieldChanged(e.key, e.value));
      }
    }

    test('no avanza con datos inválidos y muestra errores', () async {
      final b = build()..add(const SignUpNextPressed());
      await Future<void>.delayed(Duration.zero);
      expect(b.state.step, SignUpStep.account);
      expect(b.state.showErrors, isTrue);
      await b.close();
    });

    test('flujo dual: cuenta → vehículo → GNV → listo (+200 pts)', () async {
      final b = build();
      fill(b, {
        SignUpField.name: 'Ana Pérez',
        SignUpField.email: 'ana@correo.com',
        SignUpField.phone: '987654321',
        SignUpField.password: 'Abcdefg1',
        SignUpField.terms: true,
      });
      b.add(const SignUpNextPressed());
      await Future<void>.delayed(Duration.zero);
      expect(b.state.step, SignUpStep.vehicle);
      expect(b.state.steps.length, 4);
      fill(b, {
        SignUpField.vehicleName: 'Toyota Yaris',
        SignUpField.year: '2020',
        SignUpField.plate: 'abc123',
      });
      await Future<void>.delayed(Duration.zero);
      expect(b.state.plate, 'ABC-123');
      b.add(const SignUpNextPressed());
      await Future<void>.delayed(Duration.zero);
      expect(b.state.step, SignUpStep.gnv);
      fill(b, {
        SignUpField.chip: '1234-5678-90',
        SignUpField.expiry: '18/01/2027',
      });
      b.add(const SignUpNextPressed());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(b.state.step, SignUpStep.done);
      expect(vehicles.state.length, 2);
      expect(points.state.balance, 1240 + SignUpBloc.welcomePoints);
      expect(auth.currentUser.name, 'Ana Pérez');
      await b.close();
    });

    test('solo gasolina salta el paso del cilindro (3 segmentos)', () async {
      final b = build();
      fill(b, {
        SignUpField.name: 'Ana Pérez',
        SignUpField.email: 'ana@correo.com',
        SignUpField.phone: '987654321',
        SignUpField.password: 'Abcdefg1',
        SignUpField.terms: true,
        SignUpField.fuel: VehicleFuel.gasoline,
      });
      await Future<void>.delayed(Duration.zero);
      expect(b.state.steps.length, 3);
      await b.close();
    });

    test('agregar vehículo termina en la lista', () async {
      final b = build(addMode: true);
      fill(b, {
        SignUpField.vehicleName: 'Kia Rio',
        SignUpField.year: '2019',
        SignUpField.plate: 'XYZ987',
        SignUpField.fuel: VehicleFuel.gasoline,
      });
      b.add(const SignUpNextPressed());
      await Future<void>.delayed(Duration.zero);
      expect(b.state.finished, isTrue);
      expect(vehicles.state.length, 2);
      await b.close();
    });
  });

  group('PasswordResetBloc', () {
    test('el código 0000 falla y descuenta intentos; otro avanza', () async {
      final b = PasswordResetBloc(toast: ToastService())
        ..add(const ResetEmailChanged('ana@correo.com'))
        ..add(const ResetCodeRequested());
      await Future<void>.delayed(Duration.zero);
      expect(b.state.step, ResetStep.code);
      expect(b.state.resendIn, PasswordResetBloc.resendSeconds);
      b
        ..add(const ResetCodeChanged('0000'))
        ..add(const ResetCodeSubmitted());
      await Future<void>.delayed(Duration.zero);
      expect(b.state.wrongCode, isTrue);
      expect(b.state.attemptsLeft, 2);
      expect(b.state.shake, 1);
      b
        ..add(const ResetCodeChanged('1234'))
        ..add(const ResetCodeSubmitted());
      await Future<void>.delayed(Duration.zero);
      expect(b.state.step, ResetStep.newPassword);
      b
        ..add(const ResetPasswordChanged('Abcdefg1', 'Otra1234'))
        ..add(const ResetSubmitted());
      await Future<void>.delayed(Duration.zero);
      expect(b.state.completed, isFalse);
      b
        ..add(const ResetPasswordChanged('Abcdefg1', 'Abcdefg1'))
        ..add(const ResetSubmitted());
      await Future<void>.delayed(Duration.zero);
      expect(b.state.completed, isTrue);
      await b.close();
    });
  });

  group('Cuenta', () {
    test('puntos: canje descuenta y entrega código TQ-', () {
      final c = PointsCubit(FixedClock(DateTime.utc(2026, 11, 15)));
      expect(c.redeem(Reward.gasoline20, 'x'), isNull);
      final code = c.redeem(Reward.coffee, 'Café');
      expect(code, startsWith('TQ-'));
      expect(c.state.balance, 940);
      c.earn(50, 'Grifo');
      expect(c.state.balance, 990);
      expect(c.state.lifetime, 1590);
    });

    test('métodos de pago: no se quita el último', () {
      final c = PaymentMethodsCubit();
      expect(c.remove('plin'), RemoveResult.removed);
      expect(c.remove('card-4821'), RemoveResult.removed);
      expect(c.remove('yape'), RemoveResult.last);
      expect(c.state.methods.length, 1);
    });

    test('facturación valida DNI y RUC', () {
      final c = BillingProfileCubit();
      expect(
        c.save(const BillingProfile(dni: '123', name: 'a')),
        BillingResult.invalidDni,
      );
      expect(
        c.save(const BillingProfile(ruc: '30123456789')),
        BillingResult.invalidRuc,
      );
      expect(
        c.save(const BillingProfile(dni: '45678912', ruc: '20601234567')),
        BillingResult.saved,
      );
    });

    test('historial: agrega «Nuevo» y filtra', () {
      final h = HistoryCubit(const InMemoryStationRepository());
      expect(h.state.records.length, 6);
      h.setFilter(RecordFilter.invoices);
      expect(h.state.visible.length, 1);
      h.setFilter(RecordFilter.gnv);
      expect(
        h.state.visible.every((r) => r.document.result.fuel.isGnv),
        isTrue,
      );
      h.setFilter(RecordFilter.all);
      expect(
        h.state.visible.first.date.isAfter(h.state.visible.last.date),
        isTrue,
      );
      h.add(h.state.records.first.document);
      expect(h.state.records.first.isNew, isTrue);
      expect(h.state.records.where((r) => r.isNew).length, 1);
    });
  });

  group('Ruta y navegación', () {
    const a = LatLng(-12.0975, -77.0385);
    final b = LatLng(a.latitude + 100 / 111320, a.longitude);
    final c = LatLng(b.latitude, b.longitude + 100 / 108900);
    final path = RoutePath([a, b, c]);

    test('distancias, rumbo y giro a la derecha', () {
      expect(path.total, closeTo(200, 3));
      expect(path.headingOfSegment(0), closeTo(0, 1));
      expect(path.headingOfSegment(1), closeTo(90, 1));
      expect(path.turnAngle(0), greaterThan(60)); // derecha
      final i = TurnInstructionBuilder.current(path, 40);
      expect(i.type, TurnType.right);
      expect(i.distanceM, closeTo(60, 3));
      final n = TurnInstructionBuilder.next(path, 40);
      expect(n!.type, TurnType.destination);
      expect(
        TurnInstructionBuilder.current(path, 150).type,
        TurnType.destination,
      );
    });

    test('giro a la izquierda y redondeo de distancias', () {
      final left = RoutePath([a, b, LatLng(b.latitude, b.longitude - 0.001)]);
      expect(left.turnAngle(0), lessThan(-60));
      expect(TurnInstructionBuilder.roundDistance(234).value, 230);
      final km = TurnInstructionBuilder.roundDistance(1234);
      expect(km.km, isTrue);
      expect(km.value, 1.2);
    });

    test('simulador: 13–19 s y baja al 42 % en las esquinas', () {
      final sim = RouteSimulator(path);
      final s = sim.totalDuration.inSeconds;
      expect(s, inInclusiveRange(13, 19));
      expect(sim.speedAt(10), 46);
      expect(sim.speedAt(100), closeTo(46 * .42, .01));
      expect(sim.distanceAt(0), 0);
      expect(sim.distanceAt(1), closeTo(path.total, 1));
      var last = -1.0;
      for (var f = 0.0; f <= 1; f += .1) {
        final d = sim.distanceAt(f);
        expect(d, greaterThanOrEqualTo(last));
        last = d;
      }
    });

    test('paso a 3D: máx(230 uds, 34 % de la ruta)', () {
      // 1000 m ≈ 227 uds; 34 % de 4000 m ≈ 309 uds.
      expect(NavigationBloc.shouldAuto3D(900, 4000), isTrue);
      expect(NavigationBloc.shouldAuto3D(1100, 4000), isTrue);
      expect(NavigationBloc.shouldAuto3D(1500, 4000), isFalse);
      expect(NavigationBloc.shouldAuto3D(1100, 1500), isFalse);
    });

    test('Overview → Driving → Arrived y continuar al surtidor', () async {
      final station = const InMemoryStationRepository().getStations().first;
      final bloc = NavigationBloc(
        clock: FixedClock(DateTime.utc(2026, 11, 15, 16, 20)),
        toast: ToastService(),
        overviewDelay: const Duration(milliseconds: 10),
        simulatorFor: (p) => RouteSimulator(
          p,
          duration: const Duration(milliseconds: 120),
          tick: const Duration(milliseconds: 10),
        ),
      )..add(NavigationStarted(station));
      final seen = <Type>[];
      final sub = bloc.stream.listen((s) => seen.add(s.runtimeType));
      await Future<void>.delayed(const Duration(milliseconds: 600));
      expect(seen.first, NavOverview);
      expect(seen, contains(NavDriving));
      expect(bloc.state, isA<NavArrived>());
      bloc.add(const ContinueToFuelPressed());
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state!.effect!.kind, NavEffectKind.continueToFuel);
      await sub.cancel();
      await bloc.close();
    });

    test('recentrar vuelve a auto y el botón 2D/3D deja modo manual', () async {
      final station = const InMemoryStationRepository().getStations().first;
      final bloc = NavigationBloc(
        clock: FixedClock(DateTime.utc(2026, 11, 15, 16, 20)),
        toast: ToastService(),
        overviewDelay: const Duration(milliseconds: 5),
        simulatorFor: (p) => RouteSimulator(
          p,
          duration: const Duration(seconds: 30),
          tick: const Duration(milliseconds: 50),
        ),
      )..add(NavigationStarted(station));
      await Future<void>.delayed(const Duration(milliseconds: 80));
      final d0 = bloc.state! as NavDriving;
      bloc.add(const ViewToggled());
      await Future<void>.delayed(Duration.zero);
      final d1 = bloc.state! as NavDriving;
      expect(d1.is3D, !d0.is3D);
      expect(d1.viewMode, isNot(ViewMode.auto));
      bloc.add(const RecenterPressed());
      await Future<void>.delayed(Duration.zero);
      expect((bloc.state! as NavDriving).viewMode, ViewMode.auto);
      bloc.add(const ExitPressed());
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state!.effect!.kind, NavEffectKind.exit);
      await bloc.close();
    });
  });

  test('TankKind sigue disponible', () => expect(TankKind.values.length, 2));
}
