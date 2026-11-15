part of 'fueling_bloc.dart';

sealed class FuelingEvent extends Equatable {
  const FuelingEvent();

  @override
  List<Object?> get props => [];
}

class FuelChanged extends FuelingEvent {
  const FuelChanged(this.tank);
  final TankKind tank;

  @override
  List<Object?> get props => [tank];
}

class GradeChanged extends FuelingEvent {
  const GradeChanged(this.grade);
  final FuelType grade;

  @override
  List<Object?> get props => [grade];
}

class PresetChanged extends FuelingEvent {
  const PresetChanged(this.preset);
  final AmountPreset preset;

  @override
  List<Object?> get props => [preset];
}

/// «Autorizar surtidor N». Con GNV abre la lista de seguridad.
class AuthorizePressed extends FuelingEvent {
  const AuthorizePressed({this.reduceMotion = false});
  final bool reduceMotion;

  @override
  List<Object?> get props => [reduceMotion];
}

class SafetyItemToggled extends FuelingEvent {
  const SafetyItemToggled(this.index);
  final int index;

  @override
  List<Object?> get props => [index];
}

class SafetyCancelled extends FuelingEvent {
  const SafetyCancelled();
}

class SafetyConfirmed extends FuelingEvent {
  const SafetyConfirmed({this.reduceMotion = false});
  final bool reduceMotion;

  @override
  List<Object?> get props => [reduceMotion];
}

class StopPressed extends FuelingEvent {
  const StopPressed();
}

class HangUpPressed extends FuelingEvent {
  const HangUpPressed();
}

class SheetToggled extends FuelingEvent {
  const SheetToggled(this.open);
  final bool open;

  @override
  List<Object?> get props => [open];
}

/// La pantalla de carga avisa si está a la vista (decide si abrir la hoja o
/// mostrar el aviso «Carga completa»).
class ChargeScreenVisibilityChanged extends FuelingEvent {
  const ChargeScreenVisibilityChanged({required this.visible});
  final bool visible;

  @override
  List<Object?> get props => [visible];
}

/// Llega desde el mapa o el detalle vía `FuelingSessionRepository`.
class FuelSelectionReceived extends FuelingEvent {
  const FuelSelectionReceived(this.fuel, {this.stationIndex});
  final FuelType fuel;
  final int? stationIndex;

  @override
  List<Object?> get props => [fuel, stationIndex];
}

/// Llega desde el pago vía `FuelingSessionRepository`.
class SessionSettledReceived extends FuelingEvent {
  const SessionSettledReceived();
}

/// Cierra el diálogo de falla (Cerrar / Cargar gasolina / Reintentar).
class IssueDismissed extends FuelingEvent {
  const IssueDismissed();
}

/// «Usar otro surtidor» tras un surtidor sin conexión.
class AnotherPumpRequested extends FuelingEvent {
  const AnotherPumpRequested();
}
