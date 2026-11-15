import 'dart:ui';

import '../../../core/domain/fuel_type.dart';
import '../domain/station.dart';

/// Origen de los grifos. Hoy son datos de ejemplo; mañana, una API.
abstract class StationRepository {
  List<Station> getStations();
}

class InMemoryStationRepository implements StationRepository {
  const InMemoryStationRepository();

  @override
  List<Station> getStations() => _stations;

  static const _stations = <Station>[
    Station(
      name: 'EcoGrifo Javier Prado',
      company: 'ECOGRIFO JAVIER PRADO S.A.C.',
      ruc: '20000000011',
      address: 'Av. Javier Prado Este 1450',
      district: 'San Isidro, Lima',
      prices: {
        FuelType.gnv: 1.69,
        FuelType.regular: 17.99,
        FuelType.premium: 21.49,
        FuelType.diesel: 22.42,
      },
      freePumps: 3,
      totalPumps: 8,
      assignedPump: '4 · Isla B',
      rating: 4.7,
      reviewCount: 318,
      driveMinutes: 5,
      distanceKm: 1.2,
      position: Offset(430, 450),
      route: [Offset(300, 710), Offset(300, 450), Offset(430, 450)],
      services: {
        StationService.store,
        StationService.air,
        StationService.atm,
        StationService.wash,
      },
    ),
    Station(
      name: 'Estación La Marina 24h',
      company: 'ESTACIÓN LA MARINA E.I.R.L.',
      ruc: '20000000022',
      address: 'Av. La Marina 2355',
      district: 'San Miguel, Lima',
      prices: {
        FuelType.gnv: 1.75,
        FuelType.regular: 18.39,
        FuelType.premium: 21.89,
        FuelType.diesel: 22.79,
      },
      freePumps: 5,
      totalPumps: 10,
      assignedPump: '2 · Isla A',
      rating: 4.5,
      reviewCount: 204,
      driveMinutes: 8,
      distanceKm: 2.3,
      position: Offset(170, 320),
      route: [
        Offset(300, 710),
        Offset(430, 710),
        Offset(430, 320),
        Offset(170, 320),
      ],
      services: {StationService.store, StationService.air, StationService.atm},
    ),
    Station(
      name: 'GasNorte Arequipa',
      company: 'GASNORTE AREQUIPA S.A.',
      ruc: '20000000033',
      address: 'Av. Arequipa 3120',
      district: 'San Isidro, Lima',
      prices: {
        FuelType.gnv: 1.72,
        FuelType.regular: 18.19,
        FuelType.premium: 21.69,
        FuelType.diesel: 22.59,
      },
      freePumps: 2,
      totalPumps: 6,
      assignedPump: '1 · Isla A',
      rating: 4.4,
      reviewCount: 156,
      driveMinutes: 11,
      distanceKm: 3.1,
      position: Offset(690, 450),
      route: [
        Offset(300, 710),
        Offset(300, 580),
        Offset(690, 580),
        Offset(690, 450),
      ],
      services: {StationService.air, StationService.wash},
    ),
    Station(
      name: 'Grifo Benavides Express',
      company: 'GRIFO BENAVIDES EXPRESS S.A.C.',
      ruc: '20000000044',
      address: 'Av. Alfredo Benavides 4890',
      district: 'Santiago de Surco, Lima',
      prices: {
        FuelType.gnv: 1.65,
        FuelType.regular: 18.59,
        FuelType.premium: 22.09,
        FuelType.diesel: 23.10,
      },
      freePumps: 0,
      totalPumps: 8,
      assignedPump: '6 · Isla C',
      rating: 4.8,
      reviewCount: 421,
      driveMinutes: 15,
      distanceKm: 4.6,
      position: Offset(690, 840),
      route: [
        Offset(300, 710),
        Offset(300, 970),
        Offset(690, 970),
        Offset(690, 840),
      ],
      services: {
        StationService.store,
        StationService.air,
        StationService.wash,
        StationService.atm,
      },
    ),
  ];
}
