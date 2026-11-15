import 'dart:ui';

import 'package:equatable/equatable.dart';

import '../../../core/domain/fuel_type.dart';

/// Servicios que ofrece un grifo (filtros del mapa).
enum StationService { store, air, atm, wash }

/// Grifo con precios por combustible, surtidores y ubicación en el mapa.
class Station extends Equatable {
  const Station({
    required this.name,
    required this.company,
    required this.ruc,
    required this.address,
    required this.district,
    required this.prices,
    required this.freePumps,
    required this.totalPumps,
    required this.assignedPump,
    required this.rating,
    required this.reviewCount,
    required this.driveMinutes,
    required this.distanceKm,
    required this.position,
    required this.route,
    this.services = const {},
  });

  final String name;
  final String company;
  final String ruc;
  final String address;
  final String district;

  /// Precios con IGV incluido, por combustible.
  final Map<FuelType, double> prices;
  final int freePumps;
  final int totalPumps;

  /// Surtidor asignado, por ejemplo «4 · Isla B».
  final String assignedPump;
  final double rating;
  final int reviewCount;
  final int driveMinutes;
  final double distanceKm;

  /// Posición del pin en el mapa (coordenadas del mundo, 900 × 1400).
  final Offset position;

  /// Vértices de la ruta desde la posición del auto hasta el grifo.
  final List<Offset> route;
  final Set<StationService> services;

  Station withPumps({required int free}) => Station(
    name: name,
    company: company,
    ruc: ruc,
    address: address,
    district: district,
    prices: prices,
    freePumps: free,
    totalPumps: totalPumps,
    assignedPump: assignedPump,
    rating: rating,
    reviewCount: reviewCount,
    driveMinutes: driveMinutes,
    distanceKm: distanceKm,
    position: position,
    route: route,
    services: services,
  );

  double priceOf(FuelType fuel) => prices[fuel]!;
  bool get hasFreePumps => freePumps > 0;

  /// Número del surtidor asignado («4 · Isla B» → `4`).
  String get assignedPumpNumber => assignedPump.split(' ').first;

  @override
  List<Object?> get props => [name, ruc, address];
}
