import 'package:equatable/equatable.dart';

/// Monto elegido para cargar: un importe en soles o «Lleno».
class AmountPreset extends Equatable {
  const AmountPreset._(this.amount);

  const AmountPreset.soles(double amount) : this._(amount);

  static const full = AmountPreset._(null);

  /// Importe en soles; `null` si es «Lleno».
  final double? amount;

  bool get isFull => amount == null;

  @override
  List<Object?> get props => [amount];
}
