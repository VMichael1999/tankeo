import '../../auth/user_profile.dart';

enum TaxDocumentType { boleta, factura }

/// Strategy: serie, validación y datos de ejemplo de cada comprobante peruano.
abstract class TaxDocumentStrategy {
  const TaxDocumentStrategy();

  factory TaxDocumentStrategy.of(TaxDocumentType type) =>
      type == TaxDocumentType.boleta
      ? const BoletaStrategy()
      : const FacturaStrategy();

  TaxDocumentType get type;
  String get series;
  String get sampleNumber;

  /// Código SUNAT del tipo de comprobante (01 factura, 03 boleta).
  String get sunatCode;

  /// Código SUNAT del documento del cliente (1 DNI, 6 RUC).
  String get idTypeCode;
  String get defaultId;
  String defaultName(UserProfile user);
  bool isValidId(String id);

  String get fullNumber => '$series-$sampleNumber';
}

class BoletaStrategy extends TaxDocumentStrategy {
  const BoletaStrategy();

  @override
  TaxDocumentType get type => TaxDocumentType.boleta;
  @override
  String get series => 'B001';
  @override
  String get sampleNumber => '00004582';
  @override
  String get sunatCode => '03';
  @override
  String get idTypeCode => '1';
  @override
  String get defaultId => '45678912';
  @override
  String defaultName(UserProfile user) => user.name;

  /// DNI de 8 dígitos.
  @override
  bool isValidId(String id) => RegExp(r'^\d{8}$').hasMatch(id);
}

class FacturaStrategy extends TaxDocumentStrategy {
  const FacturaStrategy();

  @override
  TaxDocumentType get type => TaxDocumentType.factura;
  @override
  String get series => 'F001';
  @override
  String get sampleNumber => '00001207';
  @override
  String get sunatCode => '01';
  @override
  String get idTypeCode => '6';
  @override
  String get defaultId => '20601234567';
  @override
  String defaultName(UserProfile user) => 'ANDES LOGÍSTICA S.A.C.';

  /// RUC de 11 dígitos que empieza con 10 o 20.
  @override
  bool isValidId(String id) => RegExp(r'^(10|20)\d{9}$').hasMatch(id);
}
