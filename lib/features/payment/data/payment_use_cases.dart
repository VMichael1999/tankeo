import '../../../core/toast/toast_service.dart';
import '../../fueling/data/fault_simulator.dart';
import '../../fueling/domain/fueling_result.dart';
import '../../stations/domain/station.dart';
import '../domain/payment_method_strategy.dart';
import '../domain/tax_document.dart';
import '../domain/tax_document_strategy.dart';

/// Pago aprobado.
class PaymentApproved {
  const PaymentApproved({required this.points});

  /// Puntos de fidelidad: la parte entera del total.
  final int points;
}

/// La pasarela rechazó el cargo.
class PaymentDeclined implements Exception {
  const PaymentDeclined();
}

/// Command: cobra la carga con el medio elegido.
class PayUseCase {
  const PayUseCase({
    this.delay = const Duration(milliseconds: 1700),
    this.faults,
  });

  final Duration delay;
  final FaultSimulator? faults;

  Future<PaymentApproved> call({
    required FuelingResult result,
    required PaymentMethod method,
  }) async {
    await Future<void>.delayed(delay);
    if (faults?.consumePaymentDeclined() ?? false)
      throw const PaymentDeclined();
    return PaymentApproved(points: result.total.floor());
  }
}

/// Command: emite el comprobante electrónico.
class IssueTaxDocumentUseCase {
  const IssueTaxDocumentUseCase();

  TaxDocument call({
    required FuelingResult result,
    required TaxDocumentType type,
    required Customer customer,
    required Station issuer,
    required PaymentMethod method,
  }) => TaxDocument.from(
    result: result,
    strategy: TaxDocumentStrategy.of(type),
    customer: customer,
    issuer: issuer,
    method: PaymentMethodStrategy.of(method),
  );
}

/// Command: comparte el comprobante (PDF y XML).
class ShareReceiptUseCase {
  const ShareReceiptUseCase(this._toast);

  final ToastService _toast;

  void call(TaxDocument document) => _toast.show(AppToast.receiptShared);
}
