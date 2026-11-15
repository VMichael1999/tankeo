import 'dart:async';

/// Avisos breves de la app (el «toast» del prototipo). Cada valor se traduce
/// en la capa de UI; los BLoCs solo dicen qué pasó.
enum AppToast {
  dieselInfo,
  finishCurrentCharge,
  payPreviousFirst,
  arrived,
  gridBusy,
  chipValidated,
  chargeComplete,
  gnvPreferred,
  gasolineOnly,
  stationShared,
  favoriteAdded,
  favoriteRemoved,
  filtersInfo,
  settingsUnavailable,
  invalidDni,
  invalidRuc,
  receiptShared,
  paidByEmail,
  newPumpAssigned,
  leftQueue,
  pickAnotherMethod,
  filtersApplied,
  hiddenByFilters,
  apptConfirmed,
  redeemed,
  paymentDefault,
  paymentRemoved,
  paymentLast,
  cardAdded,
  billingSaved,
  help,
  passwordUpdated,
  codeSent,
  near3d,
}

class ToastEvent {
  const ToastEvent(this.kind, {this.args = const []});

  final AppToast kind;

  /// Valores para los textos con parámetros (grifo, monto, documento…).
  final List<String> args;
}

/// Canal de avisos: los BLoCs publican y `ToastHost` los muestra.
class ToastService {
  final _controller = StreamController<ToastEvent>.broadcast();

  Stream<ToastEvent> get events => _controller.stream;

  void show(AppToast kind, {List<String> args = const []}) =>
      _controller.add(ToastEvent(kind, args: args));

  void dispose() => _controller.close();
}
