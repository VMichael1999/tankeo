import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tankeo/core/toast/toast_service.dart';
import 'package:tankeo/features/auth/auth_repository.dart';
import 'package:tankeo/features/fueling/data/fueling_session_repository.dart';
import 'package:tankeo/features/fueling/domain/fueling_result.dart';
import 'package:tankeo/features/payment/bloc/payment_bloc.dart';
import 'package:tankeo/features/payment/data/payment_use_cases.dart';
import 'package:tankeo/features/payment/domain/tax_document_strategy.dart';
import 'package:tankeo/features/stations/data/station_repository.dart';

void main() {
  late FuelingSessionRepository session;
  late ToastService toast;
  late List<AppToast> toasts;

  setUp(() {
    session = FuelingSessionRepository(
      seed: FuelingResult.sample(at: DateTime(2026, 11, 13, 16, 20)),
    );
    toast = ToastService();
    toasts = [];
    toast.events.listen((e) => toasts.add(e.kind));
  });

  PaymentBloc build() => PaymentBloc(
    session: session,
    stations: const InMemoryStationRepository(),
    auth: FakeAuthRepository(),
    toast: toast,
    pay: const PayUseCase(delay: Duration(milliseconds: 5)),
    issue: const IssueTaxDocumentUseCase(),
  );

  test('la boleta parte con el usuario Michael Dev', () {
    final s = build().state;
    expect(s.documentType, TaxDocumentType.boleta);
    expect(s.customerName, 'Michael Dev');
  });

  blocTest<PaymentBloc, PaymentState>(
    'DNI inválido: avisa y no abre el diálogo',
    build: build,
    act: (b) {
      b.add(const CustomerIdChanged('1234'));
      b.add(const PayPressed());
    },
    verify: (b) async {
      await Future<void>.delayed(Duration.zero);
      expect(b.state.step, PaymentStep.editing);
      expect(toasts, [AppToast.invalidDni]);
    },
  );

  blocTest<PaymentBloc, PaymentState>(
    'RUC debe empezar con 10 o 20',
    build: build,
    act: (b) {
      b.add(const DocumentTypeChanged(TaxDocumentType.factura));
      b.add(const CustomerIdChanged('30601234567'));
      b.add(const PayPressed());
    },
    verify: (b) async {
      await Future<void>.delayed(Duration.zero);
      expect(b.state.step, PaymentStep.editing);
      expect(toasts, [AppToast.invalidRuc]);
    },
  );

  blocTest<PaymentBloc, PaymentState>(
    'cancelar el diálogo vuelve a editar',
    build: build,
    act: (b) {
      b.add(const PayPressed());
      b.add(const PaymentCancelled());
    },
    verify: (b) => expect(b.state.step, PaymentStep.editing),
  );

  blocTest<PaymentBloc, PaymentState>(
    'pagar: confirma, procesa, emite la factura y libera la sesión',
    build: build,
    act: (b) async {
      b.add(const DocumentTypeChanged(TaxDocumentType.factura));
      b.add(const PayPressed());
      await b.stream.firstWhere((s) => s.step == PaymentStep.confirming);
      b.add(const PaymentConfirmed());
      await b.stream.firstWhere((s) => s.step == PaymentStep.success);
    },
    verify: (b) {
      final s = b.state;
      expect(s.points, 19);
      expect(s.document!.number, 'F001-00001207');
      expect(s.document!.amounts.igv, 2.90);
      expect(session.status, SessionStatus.idle);
    },
  );

  test(
    'pago aprobado avisa al historial y usa los datos de facturación',
    () async {
      final paid = <int>[];
      final bloc = PaymentBloc(
        session: session,
        stations: const InMemoryStationRepository(),
        auth: FakeAuthRepository(),
        toast: toast,
        pay: const PayUseCase(delay: Duration.zero),
        issue: const IssueTaxDocumentUseCase(),
        billing: (t) => t == TaxDocumentType.factura
            ? (id: '20111111111', name: 'MI EMPRESA S.A.C.')
            : null,
        onPaid: (doc, points) => paid.add(points),
      )..add(const DocumentTypeChanged(TaxDocumentType.factura));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.customerId, '20111111111');
      expect(bloc.state.customerName, 'MI EMPRESA S.A.C.');
      bloc
        ..add(const PayPressed())
        ..add(const PaymentConfirmed());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(bloc.state.step, PaymentStep.success);
      expect(paid, [19]);
      await bloc.close();
    },
  );
}
