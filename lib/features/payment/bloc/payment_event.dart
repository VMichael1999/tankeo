part of 'payment_bloc.dart';

sealed class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

class DocumentTypeChanged extends PaymentEvent {
  const DocumentTypeChanged(this.type);
  final TaxDocumentType type;

  @override
  List<Object?> get props => [type];
}

class CustomerIdChanged extends PaymentEvent {
  const CustomerIdChanged(this.value);
  final String value;

  @override
  List<Object?> get props => [value];
}

class CustomerNameChanged extends PaymentEvent {
  const CustomerNameChanged(this.value);
  final String value;

  @override
  List<Object?> get props => [value];
}

class PaymentMethodChanged extends PaymentEvent {
  const PaymentMethodChanged(this.method);
  final PaymentMethod method;

  @override
  List<Object?> get props => [method];
}

/// «Pagar»: valida el documento y abre «Confirmar pago».
class PayPressed extends PaymentEvent {
  const PayPressed();
}

class PaymentCancelled extends PaymentEvent {
  const PaymentCancelled();
}

/// «Sí, pagar».
class PaymentConfirmed extends PaymentEvent {
  const PaymentConfirmed();
}

/// «No, gracias»: vuelve al Inicio.
class ReceiptDeclined extends PaymentEvent {
  const ReceiptDeclined();
}

/// «Ver boleta» / «Ver factura».
class ReceiptRequested extends PaymentEvent {
  const ReceiptRequested();
}

class PaymentEffectHandled extends PaymentEvent {
  const PaymentEffectHandled();
}

/// Cierra el diálogo «Pago rechazado».
class PaymentErrorDismissed extends PaymentEvent {
  const PaymentErrorDismissed();
}
