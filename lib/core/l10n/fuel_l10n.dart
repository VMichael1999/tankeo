import 'package:flutter/widgets.dart';

import '../domain/fuel_type.dart';
import 'l10n.dart';

extension FuelTypeL10n on FuelType {
  /// Etiqueta corta: GNV, Regular, Premium, Diésel B5.
  String label(BuildContext context) {
    final l = context.l10n;
    return switch (this) {
      FuelType.gnv => l.fuelGnv,
      FuelType.regular => l.fuelRegular,
      FuelType.premium => l.fuelPremium,
      FuelType.diesel => l.fuelDiesel,
    };
  }

  /// Nombre completo: GNV, Gasohol Regular, Gasohol Premium, Diésel B5.
  String longLabel(BuildContext context) {
    final l = context.l10n;
    return switch (this) {
      FuelType.gnv => l.fuelGnv,
      FuelType.regular => l.fuelRegularLong,
      FuelType.premium => l.fuelPremiumLong,
      FuelType.diesel => l.fuelDiesel,
    };
  }
}
