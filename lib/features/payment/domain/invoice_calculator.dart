import 'package:equatable/equatable.dart';

import '../../../core/utils/money.dart';

/// Importes de un comprobante peruano.
class InvoiceAmounts extends Equatable {
  const InvoiceAmounts({
    required this.total,
    required this.opGravada,
    required this.igv,
  });

  final double total;
  final double opGravada;
  final double igv;

  @override
  List<Object?> get props => [total, opGravada, igv];
}

/// El precio del combustible ya incluye IGV (18 %).
abstract final class InvoiceCalculator {
  static const igvRate = .18;

  /// `total = round2(volumen × precio)`, o el monto exacto elegido.
  static double total({
    required double volume,
    required double price,
    double? exactAmount,
  }) => exactAmount ?? Money.round2(volume * price);

  /// `opGravada = round2(total / 1.18)`; `igv = total − opGravada`.
  static InvoiceAmounts fromTotal(double total) {
    final grav = Money.round2(total / (1 + igvRate));
    return InvoiceAmounts(
      total: total,
      opGravada: grav,
      igv: Money.round2(total - grav),
    );
  }
}
