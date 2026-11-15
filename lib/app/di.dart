import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../core/utils/money.dart';
import '../features/payment/domain/tax_document.dart';

import '../core/toast/toast_service.dart';
import '../core/utils/clock.dart';
import '../features/account/bloc/billing_cubit.dart';
import '../features/account/bloc/certification_cubit.dart';
import '../features/account/bloc/history_cubit.dart';
import '../features/account/bloc/notifications_cubit.dart';
import '../features/account/bloc/payment_methods_cubit.dart';
import '../features/account/bloc/points_cubit.dart';
import '../features/account/bloc/settings_cubit.dart';
import '../features/account/bloc/vehicles_cubit.dart';
import '../features/account/domain/account_models.dart';
import '../features/auth/auth_repository.dart';
import '../features/auth/bloc/login_bloc.dart';
import '../features/fueling/bloc/fueling_bloc.dart';
import '../features/fueling/data/fault_simulator.dart';
import '../features/fueling/data/fueling_session_repository.dart';
import '../features/fueling/data/infogas_service.dart';
import '../features/fueling/data/live_activity_service.dart';
import '../features/fueling/data/pump_session_repository.dart';
import '../features/fueling/domain/fueling_result.dart';
import '../features/payment/bloc/payment_bloc.dart';
import '../features/payment/data/payment_use_cases.dart';
import '../features/queue/queue_cubit.dart';
import '../features/receipt/bloc/receipt_cubit.dart';
import '../features/stations/bloc/stations_bloc.dart';
import '../features/stations/data/places_station_repository.dart';
import '../features/stations/data/road_route_repository.dart';
import '../features/stations/data/station_repository.dart';
import '../features/vehicle/bloc/vehicle_cubit.dart';
import '../features/vehicle/data/vehicle_repository.dart';

final getIt = GetIt.instance;

/// Registra repositorios, servicios y BLoCs. Los BLoCs no se conocen entre
/// sí: se coordinan por los repositorios y el router.
void configureDependencies() {
  if (getIt.isRegistered<ToastService>()) return;
  getIt
    ..registerLazySingleton<Clock>(() => const SystemClock())
    ..registerLazySingleton<ToastService>(
      ToastService.new,
      dispose: (s) => s.dispose(),
    )
    ..registerLazySingleton<AuthRepository>(FakeAuthRepository.new)
    ..registerLazySingleton<VehicleRepository>(InMemoryVehicleRepository.new)
    ..registerLazySingleton<StationRepository>(
      () => PlacesStationRepository(
        apiKey: dotenv.maybeGet('EXPO_PUBLIC_GOOGLE_MAPS_API_KEY'),
      ),
    )
    ..registerLazySingleton<RoadRouteRepository>(
      () => RoadRouteRepository(
        apiKey: dotenv.maybeGet('EXPO_PUBLIC_GOOGLE_MAPS_API_KEY'),
      ),
    )
    ..registerLazySingleton<FaultSimulator>(FaultSimulator.new)
    ..registerLazySingleton<PumpSessionRepository>(
      () => SimulatedPumpSessionRepository(faults: getIt<FaultSimulator>()),
    )
    ..registerLazySingleton<InfogasService>(
      () => SimulatedInfogasService(faults: getIt<FaultSimulator>()),
    )
    ..registerLazySingleton<FuelingSessionRepository>(
      () => FuelingSessionRepository(
        seed: FuelingResult.sample(at: getIt<Clock>().now()),
      ),
    )
    ..registerLazySingleton(() => PayUseCase(faults: getIt<FaultSimulator>()))
    ..registerLazySingleton(() => const IssueTaxDocumentUseCase())
    ..registerLazySingleton(() => ShareReceiptUseCase(getIt<ToastService>()))
    ..registerLazySingleton(
      LiveActivityService.new,
      dispose: (s) => s.dispose(),
    )
    ..registerLazySingleton(() => LoginBloc(getIt<AuthRepository>()))
    ..registerLazySingleton(() => VehicleCubit(getIt<VehicleRepository>()))
    ..registerLazySingleton(
      () => StationsBloc(
        repository: getIt<StationRepository>(),
        session: getIt<FuelingSessionRepository>(),
        toast: getIt<ToastService>(),
      ),
    )
    ..registerLazySingleton(
      () => FuelingBloc(
        stations: getIt<StationRepository>(),
        vehicle: getIt<VehicleRepository>(),
        session: getIt<FuelingSessionRepository>(),
        pump: getIt<PumpSessionRepository>(),
        infogas: getIt<InfogasService>(),
        toast: getIt<ToastService>(),
        clock: getIt<Clock>(),
      ),
    )
    ..registerLazySingleton(
      () => PaymentBloc(
        session: getIt<FuelingSessionRepository>(),
        stations: getIt<StationRepository>(),
        auth: getIt<AuthRepository>(),
        toast: getIt<ToastService>(),
        pay: getIt<PayUseCase>(),
        issue: getIt<IssueTaxDocumentUseCase>(),
        billing: (type) => getIt<BillingProfileCubit>().customerFor(type),
        onPaid: _recordPayment,
      ),
    )
    ..registerLazySingleton(() => QueueCubit(getIt<ToastService>()))
    ..registerLazySingleton(() => HistoryCubit(getIt<StationRepository>()))
    ..registerLazySingleton(
      () => NotificationsCubit(
        getIt<Clock>(),
        priceStation: getIt<StationRepository>().getStations().last.name,
        paymentStation: getIt<StationRepository>().getStations().first.name,
      ),
    )
    ..registerLazySingleton(
      () => PointsCubit(
        getIt<Clock>(),
        seedStation: getIt<StationRepository>().getStations().first.name,
      ),
    )
    ..registerLazySingleton(PaymentMethodsCubit.new)
    ..registerLazySingleton(BillingProfileCubit.new)
    ..registerLazySingleton(SettingsCubit.new)
    ..registerLazySingleton(VehiclesCubit.new)
    ..registerLazySingleton(
      () => CertificationCubit(
        faults: getIt<FaultSimulator>(),
        notifications: getIt<NotificationsCubit>(),
        toast: getIt<ToastService>(),
      ),
    )
    ..registerLazySingleton(() => ReceiptCubit(getIt<ShareReceiptUseCase>()));

  // Observer: la Live Activity escucha al FuelingBloc.
  getIt<LiveActivityService>().observe(getIt<FuelingBloc>());
}

/// Tras un pago aprobado: historial, puntos y avisos.
void _recordPayment(TaxDocument doc, int points) {
  final station = doc.issuer.name;
  final amount = Money.format(doc.amounts.total);
  getIt<HistoryCubit>().add(doc);
  final pts = getIt<PointsCubit>()..earn(points, station);
  getIt<NotificationsCubit>()
    ..add(NotificationKind.payment, [amount, station, doc.type.name])
    ..add(NotificationKind.points, [
      NumberFormat('#,##0', 'en_US').format(pts.state.balance),
    ], points: points);
}
