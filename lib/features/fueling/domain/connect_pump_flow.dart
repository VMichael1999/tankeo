import '../../vehicle/domain/vehicle.dart';
import '../data/infogas_service.dart';
import 'fuel_profile.dart';

/// Template Method: `prepare()` → `connect()` → (el despacho lo hace el bloc).
/// GNV agrega la lista de seguridad y la validación del chip Infogas.
abstract class ConnectPumpFlow {
  const ConnectPumpFlow();

  factory ConnectPumpFlow.forProfile(
    FuelProfile profile, {
    required InfogasService infogas,
    required GnvCertification certification,
    Duration gasolineDelay = const Duration(milliseconds: 1300),
  }) => profile.requiresSafetyCheck
      ? GnvConnectFlow(infogas, certification)
      : GasolineConnectFlow(gasolineDelay);

  /// Ejecuta los pasos en orden y devuelve el resultado de la conexión.
  Future<ChipValidated?> run() async {
    await prepare();
    return connect();
  }

  Future<void> prepare() async {}

  Future<ChipValidated?> connect();
}

class GasolineConnectFlow extends ConnectPumpFlow {
  const GasolineConnectFlow(this.delay);

  final Duration delay;

  @override
  Future<ChipValidated?> connect() async {
    await Future<void>.delayed(delay);
    return null;
  }
}

class GnvConnectFlow extends ConnectPumpFlow {
  const GnvConnectFlow(this._infogas, this._certification);

  final InfogasService _infogas;
  final GnvCertification _certification;

  /// La lista de seguridad ya se confirmó en el diálogo antes de llegar aquí.
  @override
  Future<void> prepare() async {}

  @override
  Future<ChipValidated?> connect() => _infogas.validateChip(_certification);
}
