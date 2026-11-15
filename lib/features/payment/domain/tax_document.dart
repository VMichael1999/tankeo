import 'package:equatable/equatable.dart';

import '../../../core/utils/money.dart';
import '../../fueling/domain/fueling_result.dart';
import '../../stations/domain/station.dart';
import 'invoice_calculator.dart';
import 'payment_method_strategy.dart';
import 'tax_document_strategy.dart';

/// Cliente del comprobante: DNI + nombre, o RUC + razón social.
class Customer extends Equatable {
  const Customer({required this.id, required this.name});

  final String id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}

/// Comprobante electrónico emitido (boleta o factura).
class TaxDocument extends Equatable {
  const TaxDocument({
    required this.strategy,
    required this.customer,
    required this.issuer,
    required this.result,
    required this.method,
    required this.amounts,
  });

  /// Factory: arma el comprobante desde la carga, el tipo y el cliente.
  factory TaxDocument.from({
    required FuelingResult result,
    required TaxDocumentStrategy strategy,
    required Customer customer,
    required Station issuer,
    required PaymentMethodStrategy method,
  }) => TaxDocument(
    strategy: strategy,
    customer: customer,
    issuer: issuer,
    result: result,
    method: method,
    amounts: InvoiceCalculator.fromTotal(result.total),
  );

  final TaxDocumentStrategy strategy;
  final Customer customer;
  final Station issuer;
  final FuelingResult result;
  final PaymentMethodStrategy method;
  final InvoiceAmounts amounts;

  TaxDocumentType get type => strategy.type;
  String get number => strategy.fullNumber;
  DateTime get issuedAt => result.createdAt;

  /// Texto del QR con el formato SUNAT:
  /// RUC | tipo | serie | número | IGV | total | fecha | tipo doc. cliente | doc. cliente.
  String get qrPayload {
    final d = issuedAt;
    final date =
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    return [
      issuer.ruc,
      strategy.sunatCode,
      strategy.series,
      strategy.sampleNumber,
      Money.plain(amounts.igv),
      Money.plain(amounts.total),
      date,
      strategy.idTypeCode,
      customer.id,
    ].join('|');
  }

  @override
  List<Object?> get props => [strategy.type, customer, issuer, result, method];
}
