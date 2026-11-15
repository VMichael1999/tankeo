part of 'payment_bloc.dart';

enum PaymentStep { editing, confirming, processing, success }

enum PaymentEffectKind { goHome, openReceipt }

class PaymentEffect extends Equatable {
  const PaymentEffect(this.kind, this.nonce);

  final PaymentEffectKind kind;
  final int nonce;

  @override
  List<Object?> get props => [kind, nonce];
}

/// Cargo rechazado por la pasarela (para el diálogo de error).
class PaymentDeclinedInfo extends Equatable {
  const PaymentDeclinedInfo({required this.method, required this.amount});

  final PaymentMethod method;
  final double amount;

  @override
  List<Object?> get props => [method, amount];
}

class PaymentState extends Equatable {
  const PaymentState({
    required this.documentType,
    required this.customerId,
    required this.customerName,
    required this.method,
    required this.step,
    this.points = 0,
    this.document,
    this.effect,
    this.declined,
  });

  factory PaymentState.initial(String id, String name) => PaymentState(
    documentType: TaxDocumentType.boleta,
    customerId: id,
    customerName: name,
    method: PaymentMethod.yape,
    step: PaymentStep.editing,
  );

  final TaxDocumentType documentType;
  final String customerId;
  final String customerName;
  final PaymentMethod method;
  final PaymentStep step;
  final int points;

  /// Comprobante emitido al pagar (lo imprime la pantalla «Tu boleta»).
  final TaxDocument? document;
  final PaymentEffect? effect;
  final PaymentDeclinedInfo? declined;

  PaymentState copyWith({
    TaxDocumentType? documentType,
    String? customerId,
    String? customerName,
    PaymentMethod? method,
    PaymentStep? step,
    int? points,
    TaxDocument? document,
    PaymentEffect? effect,
    bool clearEffect = false,
    PaymentDeclinedInfo? declined,
    bool clearDeclined = false,
  }) => PaymentState(
    documentType: documentType ?? this.documentType,
    customerId: customerId ?? this.customerId,
    customerName: customerName ?? this.customerName,
    method: method ?? this.method,
    step: step ?? this.step,
    points: points ?? this.points,
    document: document ?? this.document,
    effect: clearEffect ? null : (effect ?? this.effect),
    declined: clearDeclined ? null : (declined ?? this.declined),
  );

  @override
  List<Object?> get props => [
    documentType,
    customerId,
    customerName,
    method,
    step,
    points,
    document,
    effect,
    declined,
  ];
}
