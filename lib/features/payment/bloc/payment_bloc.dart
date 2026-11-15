import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/toast/toast_service.dart';
import '../../../core/utils/money.dart';
import '../../auth/auth_repository.dart';
import '../../fueling/data/fueling_session_repository.dart';
import '../../stations/data/station_repository.dart';
import '../data/payment_use_cases.dart';
import '../domain/payment_method_strategy.dart';
import '../domain/tax_document.dart';
import '../domain/tax_document_strategy.dart';

part 'payment_event.dart';
part 'payment_state.dart';

/// Resumen de carga y pago: tipo de comprobante, cliente, medio de pago,
/// confirmación, procesamiento y éxito.
class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  PaymentBloc({
    required FuelingSessionRepository session,
    required StationRepository stations,
    required AuthRepository auth,
    required ToastService toast,
    required PayUseCase pay,
    required IssueTaxDocumentUseCase issue,
    this.onPaid,
    this.billing,
  }) : _session = session,
       _stations = stations,
       _toast = toast,
       _pay = pay,
       _issue = issue,
       super(
         PaymentState.initial(
           const BoletaStrategy().defaultId,
           const BoletaStrategy().defaultName(auth.currentUser),
         ),
       ) {
    _user = auth;
    on<DocumentTypeChanged>(_onTypeChanged);
    on<CustomerIdChanged>(
      (e, emit) => emit(state.copyWith(customerId: e.value)),
    );
    on<CustomerNameChanged>(
      (e, emit) => emit(state.copyWith(customerName: e.value)),
    );
    on<PaymentMethodChanged>(
      (e, emit) => emit(state.copyWith(method: e.method)),
    );
    on<PayPressed>(_onPayPressed);
    on<PaymentCancelled>(
      (e, emit) => emit(state.copyWith(step: PaymentStep.editing)),
    );
    on<PaymentConfirmed>(_onConfirmed);
    on<ReceiptDeclined>(_onDeclined);
    on<ReceiptRequested>(_onRequested);
    on<PaymentErrorDismissed>(
      (e, emit) => emit(state.copyWith(clearDeclined: true)),
    );
    on<PaymentEffectHandled>(
      (e, emit) => emit(state.copyWith(clearEffect: true)),
    );
  }

  final FuelingSessionRepository _session;
  final StationRepository _stations;
  final ToastService _toast;
  final PayUseCase _pay;
  final IssueTaxDocumentUseCase _issue;

  /// Se llama al aprobarse un pago (historial, puntos y avisos).
  final void Function(TaxDocument document, int points)? onPaid;

  /// Cliente guardado en «Datos de facturación» para el tipo de comprobante.
  final ({String id, String name})? Function(TaxDocumentType type)? billing;
  late final AuthRepository _user;
  int _nonce = 0;

  TaxDocumentStrategy get _strategy =>
      TaxDocumentStrategy.of(state.documentType);

  void _onTypeChanged(DocumentTypeChanged e, Emitter<PaymentState> emit) {
    final s = TaxDocumentStrategy.of(e.type);
    final saved = billing?.call(e.type);
    emit(
      state.copyWith(
        documentType: e.type,
        customerId: saved?.id ?? s.defaultId,
        customerName: saved?.name ?? s.defaultName(_user.currentUser),
      ),
    );
  }

  void _onPayPressed(PayPressed e, Emitter<PaymentState> emit) {
    if (!_strategy.isValidId(state.customerId.trim())) {
      _toast.show(
        state.documentType == TaxDocumentType.boleta
            ? AppToast.invalidDni
            : AppToast.invalidRuc,
      );
      return;
    }
    emit(state.copyWith(step: PaymentStep.confirming));
  }

  Future<void> _onConfirmed(
    PaymentConfirmed e,
    Emitter<PaymentState> emit,
  ) async {
    final result = _session.lastResult;
    if (result == null || state.step != PaymentStep.confirming) return;
    emit(state.copyWith(step: PaymentStep.processing));
    final PaymentApproved approved;
    try {
      approved = await _pay(result: result, method: state.method);
    } on PaymentDeclined {
      emit(
        state.copyWith(
          step: PaymentStep.editing,
          declined: PaymentDeclinedInfo(
            method: state.method,
            amount: result.total,
          ),
        ),
      );
      return;
    }
    final station = _stations.getStations()[result.stationIndex];
    final document = _issue(
      result: result,
      type: state.documentType,
      customer: Customer(
        id: state.customerId.trim(),
        name: state.customerName.trim(),
      ),
      issuer: station,
      method: state.method,
    );
    _session.settle();
    onPaid?.call(document, approved.points);
    emit(
      state.copyWith(
        step: PaymentStep.success,
        points: approved.points,
        document: document,
      ),
    );
  }

  void _onDeclined(ReceiptDeclined e, Emitter<PaymentState> emit) {
    final doc = state.document;
    emit(
      state.copyWith(
        step: PaymentStep.editing,
        effect: PaymentEffect(PaymentEffectKind.goHome, ++_nonce),
      ),
    );
    if (doc != null) {
      _toast.show(
        AppToast.paidByEmail,
        args: [Money.format(doc.amounts.total), state.documentType.name],
      );
    }
  }

  void _onRequested(ReceiptRequested e, Emitter<PaymentState> emit) => emit(
    state.copyWith(
      step: PaymentStep.editing,
      effect: PaymentEffect(PaymentEffectKind.openReceipt, ++_nonce),
    ),
  );
}
