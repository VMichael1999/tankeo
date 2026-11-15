import 'package:equatable/equatable.dart';

import 'station.dart';

/// Filtros del mapa: surtidores libres, pago en app, distancia y servicios.
class StationFilter extends Equatable {
  const StationFilter({
    this.onlyFree = false,
    this.appPayment = true,
    this.maxKm,
    this.services = const {},
  });

  final bool onlyFree;
  final bool appPayment;

  /// Distancia máxima en km (2 o 5); `null` es «Todas».
  final double? maxKm;
  final Set<StationService> services;

  /// Filtros activos (el número de la insignia del botón).
  int get activeCount =>
      (onlyFree ? 1 : 0) +
      (maxKm != null ? 1 : 0) +
      services.length +
      (appPayment ? 1 : 0);

  bool matches(Station s) =>
      (!onlyFree || s.hasFreePumps) &&
      (maxKm == null || s.distanceKm <= maxKm!) &&
      services.every(s.services.contains);

  StationFilter copyWith({
    bool? onlyFree,
    bool? appPayment,
    double? maxKm,
    bool clearMaxKm = false,
    Set<StationService>? services,
  }) => StationFilter(
    onlyFree: onlyFree ?? this.onlyFree,
    appPayment: appPayment ?? this.appPayment,
    maxKm: clearMaxKm ? null : (maxKm ?? this.maxKm),
    services: services ?? this.services,
  );

  @override
  List<Object?> get props => [onlyFree, appPayment, maxKm, services];
}
