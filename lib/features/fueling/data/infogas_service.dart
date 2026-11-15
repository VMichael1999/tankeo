import '../../vehicle/domain/vehicle.dart';
import 'fault_simulator.dart';

/// Resultado de leer el chip Infogas del cilindro.
class ChipValidated {
  const ChipValidated({required this.certificationValidUntil});

  final DateTime certificationValidUntil;
}

/// Infogas rechazó el chip: la certificación anual venció.
class ChipRejected implements Exception {
  const ChipRejected(this.expiredOn);

  final DateTime expiredOn;
}

/// Validación del chip Infogas (certificación vigente del cilindro).
abstract class InfogasService {
  Future<ChipValidated> validateChip(GnvCertification certification);
}

class SimulatedInfogasService implements InfogasService {
  const SimulatedInfogasService({
    this.delay = const Duration(milliseconds: 1700),
    this.faults,
  });

  final Duration delay;
  final FaultSimulator? faults;

  @override
  Future<ChipValidated> validateChip(GnvCertification certification) async {
    await Future<void>.delayed(delay);
    if (faults?.certExpired ?? false)
      throw ChipRejected(DateTime(2026, 10, 18));
    return ChipValidated(certificationValidUntil: certification.validUntil);
  }
}
