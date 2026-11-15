import 'package:flutter_bloc/flutter_bloc.dart';

import '../../payment/domain/tax_document_strategy.dart';
import '../domain/account_models.dart';

enum BillingResult { saved, invalidDni, invalidRuc }

/// Datos de facturación: DNI y nombre para boletas; RUC y razón social para facturas.
class BillingProfileCubit extends Cubit<BillingProfile> {
  BillingProfileCubit()
    : super(
        const BillingProfile(
          dni: '45678912',
          name: 'Michael Dev',
          ruc: '20601234567',
          businessName: 'ANDES LOGÍSTICA S.A.C.',
        ),
      );

  BillingResult save(BillingProfile p) {
    if (p.dni.isNotEmpty && !const BoletaStrategy().isValidId(p.dni)) {
      return BillingResult.invalidDni;
    }
    if (p.ruc.isNotEmpty && !const FacturaStrategy().isValidId(p.ruc)) {
      return BillingResult.invalidRuc;
    }
    emit(p);
    return BillingResult.saved;
  }

  /// Cliente a usar en el resumen para el [type] de comprobante.
  ({String id, String name})? customerFor(TaxDocumentType type) {
    final p = state;
    final id = type == TaxDocumentType.boleta ? p.dni : p.ruc;
    final name = type == TaxDocumentType.boleta ? p.name : p.businessName;
    return id.isEmpty ? null : (id: id, name: name);
  }
}
