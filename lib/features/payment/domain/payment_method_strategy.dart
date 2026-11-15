enum PaymentMethod { yape, plin, visa }

/// Strategy: cómo se nombra cada medio de pago en el diálogo y el comprobante.
abstract class PaymentMethodStrategy {
  const PaymentMethodStrategy();

  factory PaymentMethodStrategy.of(PaymentMethod method) => switch (method) {
    PaymentMethod.yape => const YapeStrategy(),
    PaymentMethod.plin => const PlinStrategy(),
    PaymentMethod.visa => const VisaStrategy(),
  };

  PaymentMethod get method;

  /// Nombre corto: «Yape», «Plin», «Visa».
  String get shortName;

  /// Etiqueta del diálogo de confirmación: «Yape •••• 789».
  String get dialogLabel;

  /// Forma de pago impresa en el comprobante: «YAPE», «VISA •••• 4821».
  String get receiptLabel;

  /// Detalle de la fila: «Celular •••• 789» o «•••• 4821».
  String get detail;
}

class YapeStrategy extends PaymentMethodStrategy {
  const YapeStrategy();
  @override
  PaymentMethod get method => PaymentMethod.yape;
  @override
  String get shortName => 'Yape';
  @override
  String get dialogLabel => 'Yape •••• 789';
  @override
  String get receiptLabel => 'YAPE';
  @override
  String get detail => 'Celular •••• 789';
}

class PlinStrategy extends PaymentMethodStrategy {
  const PlinStrategy();
  @override
  PaymentMethod get method => PaymentMethod.plin;
  @override
  String get shortName => 'Plin';
  @override
  String get dialogLabel => 'Plin •••• 789';
  @override
  String get receiptLabel => 'PLIN';
  @override
  String get detail => 'Celular •••• 789';
}

class VisaStrategy extends PaymentMethodStrategy {
  const VisaStrategy();
  @override
  PaymentMethod get method => PaymentMethod.visa;
  @override
  String get shortName => 'Visa';
  @override
  String get dialogLabel => 'Visa •••• 4821';
  @override
  String get receiptLabel => 'VISA •••• 4821';
  @override
  String get detail => '•••• 4821';
}
