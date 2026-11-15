part of 'fueling_bloc.dart';

/// Máquina de estados de la carga:
/// `Idle → SafetyCheck (GNV) → Connecting → Dispensing → Completed →
/// HangingUp → AwaitingPayment → Idle`.
sealed class FuelingState extends Equatable {
  const FuelingState({
    required this.config,
    this.sheetOpen = false,
    this.chipValidated = false,
    this.chargeScreenVisible = false,
    this.quote,
    this.volume = 0,
    this.stopped = false,
  });

  final FuelingConfig config;

  /// ¿Está abierta la hoja del surtidor?
  final bool sheetOpen;

  /// ¿Se validó el chip Infogas en esta carga?
  final bool chipValidated;
  final bool chargeScreenVisible;

  /// Cotización fijada al empezar la carga.
  final FuelQuote? quote;

  /// Volumen despachado (gal o m³).
  final double volume;
  final bool stopped;

  /// Los controles de la pantalla de carga solo se editan en `Idle`
  /// (y mientras el diálogo de seguridad está abierto).
  bool get isIdleLike => this is Idle || this is SafetyCheck;
  bool get isBusy =>
      this is Connecting ||
      this is Dispensing ||
      this is Completed ||
      this is HangingUp;

  double get target => quote?.targetVolume ?? 0;
  double get progress =>
      target > 0 ? (volume / target).clamp(0.0, 1.0).toDouble() : 0;

  /// Importe que muestra el LCD: el monto exacto al llegar al objetivo,
  /// o `volumen × precio`.
  double get displayAmount {
    final q = quote;
    if (q == null ||
        this is Idle ||
        this is SafetyCheck ||
        this is Connecting) {
      return 0;
    }
    final reached = volume >= q.targetVolume - 1e-6;
    if (reached && !q.preset.isFull && q.targetVolume > 0 && !stopped) {
      return q.targetAmount;
    }
    return Money.round2(volume * q.price);
  }

  /// Nivel del depósito en vivo, de 0 a 100.
  double liveLevel(double baseLevel) {
    final q = quote;
    if (q == null ||
        !(this is Dispensing || this is Completed || this is HangingUp)) {
      return baseLevel;
    }
    return baseLevel + volume / q.tank.capacity * 100;
  }

  FuelingState copyBase({
    FuelingConfig? config,
    bool? sheetOpen,
    bool? chipValidated,
    bool? chargeScreenVisible,
  });

  @override
  List<Object?> get props => [
    config,
    sheetOpen,
    chipValidated,
    chargeScreenVisible,
    quote,
    volume,
    stopped,
  ];
}

/// Falla que dejó la carga en `Idle` y que la UI muestra en un diálogo.
enum FuelingIssue { pumpOffline, certExpired }

class Idle extends FuelingState {
  const Idle({
    required super.config,
    super.sheetOpen,
    super.chipValidated,
    super.chargeScreenVisible,
    this.issue,
    this.certExpiredOn,
  });

  /// Falla pendiente de mostrar (surtidor sin conexión, certificación vencida).
  final FuelingIssue? issue;
  final DateTime? certExpiredOn;

  @override
  FuelingState copyBase({
    FuelingConfig? config,
    bool? sheetOpen,
    bool? chipValidated,
    bool? chargeScreenVisible,
  }) => Idle(
    config: config ?? this.config,
    sheetOpen: sheetOpen ?? this.sheetOpen,
    chipValidated: chipValidated ?? this.chipValidated,
    chargeScreenVisible: chargeScreenVisible ?? this.chargeScreenVisible,
    issue: issue,
    certExpiredOn: certExpiredOn,
  );

  @override
  List<Object?> get props => [...super.props, issue, certExpiredOn];
}

/// Diálogo «Antes de cargar GNV» con sus tres casillas.
class SafetyCheck extends FuelingState {
  const SafetyCheck({
    required super.config,
    this.checked = const [false, false, false],
    super.chipValidated,
    super.chargeScreenVisible,
  });

  final List<bool> checked;

  bool get allChecked => checked.every((c) => c);

  SafetyCheck toggled(int i) => SafetyCheck(
    config: config,
    checked: [
      for (var k = 0; k < checked.length; k++)
        k == i ? !checked[k] : checked[k],
    ],
    chipValidated: chipValidated,
    chargeScreenVisible: chargeScreenVisible,
  );

  @override
  FuelingState copyBase({
    FuelingConfig? config,
    bool? sheetOpen,
    bool? chipValidated,
    bool? chargeScreenVisible,
  }) => SafetyCheck(
    config: config ?? this.config,
    checked: checked,
    chipValidated: chipValidated ?? this.chipValidated,
    chargeScreenVisible: chargeScreenVisible ?? this.chargeScreenVisible,
  );

  @override
  List<Object?> get props => [...super.props, checked];
}

/// «Validando chip Infogas…» (GNV) o «Conectando con el surtidor…».
class Connecting extends FuelingState {
  const Connecting({
    required super.config,
    required super.quote,
    super.chipValidated,
    super.chargeScreenVisible,
  });

  @override
  FuelingState copyBase({
    FuelingConfig? config,
    bool? sheetOpen,
    bool? chipValidated,
    bool? chargeScreenVisible,
  }) => Connecting(
    config: config ?? this.config,
    quote: quote,
    chipValidated: chipValidated ?? this.chipValidated,
    chargeScreenVisible: chargeScreenVisible ?? this.chargeScreenVisible,
  );
}

class Dispensing extends FuelingState {
  const Dispensing({
    required super.config,
    required super.quote,
    required super.volume,
    super.sheetOpen,
    super.chipValidated,
    super.chargeScreenVisible,
  });

  @override
  FuelingState copyBase({
    FuelingConfig? config,
    bool? sheetOpen,
    bool? chipValidated,
    bool? chargeScreenVisible,
  }) => Dispensing(
    config: config ?? this.config,
    quote: quote,
    volume: volume,
    sheetOpen: sheetOpen ?? this.sheetOpen,
    chipValidated: chipValidated ?? this.chipValidated,
    chargeScreenVisible: chargeScreenVisible ?? this.chargeScreenVisible,
  );

  Dispensing withVolume(double v) => Dispensing(
    config: config,
    quote: quote,
    volume: v,
    sheetOpen: sheetOpen,
    chipValidated: chipValidated,
    chargeScreenVisible: chargeScreenVisible,
  );
}

/// Carga terminada (o detenida): falta colgar la manguera.
class Completed extends FuelingState {
  const Completed({
    required super.config,
    required super.quote,
    required super.volume,
    super.stopped,
    super.sheetOpen,
    super.chipValidated,
    super.chargeScreenVisible,
  });

  @override
  FuelingState copyBase({
    FuelingConfig? config,
    bool? sheetOpen,
    bool? chipValidated,
    bool? chargeScreenVisible,
  }) => Completed(
    config: config ?? this.config,
    quote: quote,
    volume: volume,
    stopped: stopped,
    sheetOpen: sheetOpen ?? this.sheetOpen,
    chipValidated: chipValidated ?? this.chipValidated,
    chargeScreenVisible: chargeScreenVisible ?? this.chargeScreenVisible,
  );
}

class HangingUp extends FuelingState {
  const HangingUp({
    required super.config,
    required super.quote,
    required super.volume,
    super.stopped,
    super.sheetOpen,
    super.chipValidated,
    super.chargeScreenVisible,
  });

  @override
  FuelingState copyBase({
    FuelingConfig? config,
    bool? sheetOpen,
    bool? chipValidated,
    bool? chargeScreenVisible,
  }) => HangingUp(
    config: config ?? this.config,
    quote: quote,
    volume: volume,
    stopped: stopped,
    sheetOpen: sheetOpen ?? this.sheetOpen,
    chipValidated: chipValidated ?? this.chipValidated,
    chargeScreenVisible: chargeScreenVisible ?? this.chargeScreenVisible,
  );
}

/// Manguera colgada: la carga espera el pago («Pagar S/ 19.01»).
class AwaitingPayment extends FuelingState {
  const AwaitingPayment({
    required super.config,
    required this.result,
    super.chipValidated,
    super.chargeScreenVisible,
  });

  final FuelingResult result;

  @override
  FuelingState copyBase({
    FuelingConfig? config,
    bool? sheetOpen,
    bool? chipValidated,
    bool? chargeScreenVisible,
  }) => AwaitingPayment(
    config: config ?? this.config,
    result: result,
    chipValidated: chipValidated ?? this.chipValidated,
    chargeScreenVisible: chargeScreenVisible ?? this.chargeScreenVisible,
  );

  @override
  List<Object?> get props => [...super.props, result];
}
