import 'package:flutter/foundation.dart';

/// Interruptores de «Simular errores» para probar los casos de falla.
/// Certificación vencida queda activa hasta apagarla; surtidor sin conexión y
/// pago rechazado se disparan una sola vez.
class FaultSimulator extends ChangeNotifier {
  bool certExpired = false;
  bool pumpOffline = false;
  bool paymentDeclined = false;

  void setCertExpired(bool v) {
    certExpired = v;
    notifyListeners();
  }

  void setPumpOffline(bool v) {
    pumpOffline = v;
    notifyListeners();
  }

  void setPaymentDeclined(bool v) {
    paymentDeclined = v;
    notifyListeners();
  }

  /// Devuelve `true` una vez si había una falla de surtidor programada.
  bool consumePumpOffline() {
    final v = pumpOffline;
    if (v) setPumpOffline(false);
    return v;
  }

  bool consumePaymentDeclined() {
    final v = paymentDeclined;
    if (v) setPaymentDeclined(false);
    return v;
  }
}
