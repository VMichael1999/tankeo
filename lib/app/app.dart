import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import '../core/l10n/l10n.dart';
import '../core/theme/app_theme.dart';
import '../core/toast/toast_service.dart';
import '../core/utils/clock.dart';
import '../core/widgets/design_canvas.dart';
import '../core/widgets/drop_shadow_image.dart';
import '../core/widgets/toast_host.dart';
import '../features/account/bloc/billing_cubit.dart';
import '../features/account/bloc/certification_cubit.dart';
import '../features/account/bloc/history_cubit.dart';
import '../features/account/bloc/notifications_cubit.dart';
import '../features/account/bloc/payment_methods_cubit.dart';
import '../features/account/bloc/points_cubit.dart';
import '../features/account/bloc/settings_cubit.dart';
import '../features/account/bloc/vehicles_cubit.dart';
import '../features/auth/auth_repository.dart';
import '../features/auth/bloc/login_bloc.dart';
import '../features/fueling/bloc/fueling_bloc.dart';
import '../features/fueling/data/fueling_session_repository.dart';
import '../features/payment/bloc/payment_bloc.dart';
import '../features/queue/queue_cubit.dart';
import '../features/receipt/bloc/receipt_cubit.dart';
import '../features/stations/bloc/stations_bloc.dart';
import '../features/stations/data/station_repository.dart';
import '../features/vehicle/bloc/vehicle_cubit.dart';
import 'di.dart';
import 'router.dart';

class TankeoApp extends StatefulWidget {
  const TankeoApp({super.key});

  @override
  State<TankeoApp> createState() => _TankeoAppState();
}

class _TankeoAppState extends State<TankeoApp> {
  late final GoRouter _router = createRouter();
  bool _precached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_precached) return;
    _precached = true;
    // Precarga las fotos del auto para que no parpadeen al entrar.
    for (final a in [
      AppImages.carSide,
      AppImages.carTop,
      AppImages.carTopVertical,
    ]) {
      precacheImage(AssetImage(a), context);
    }
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<Clock>.value(value: getIt<Clock>()),
        RepositoryProvider<ToastService>.value(value: getIt<ToastService>()),
        RepositoryProvider<AuthRepository>.value(
          value: getIt<AuthRepository>(),
        ),
        RepositoryProvider<StationRepository>.value(
          value: getIt<StationRepository>(),
        ),
        RepositoryProvider<FuelingSessionRepository>.value(
          value: getIt<FuelingSessionRepository>(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: getIt<LoginBloc>()),
          BlocProvider.value(value: getIt<VehicleCubit>()),
          BlocProvider.value(value: getIt<StationsBloc>()),
          BlocProvider.value(value: getIt<FuelingBloc>()),
          BlocProvider.value(value: getIt<PaymentBloc>()),
          BlocProvider.value(value: getIt<ReceiptCubit>()),
          BlocProvider.value(value: getIt<QueueCubit>()),
          BlocProvider.value(value: getIt<HistoryCubit>()),
          BlocProvider.value(value: getIt<NotificationsCubit>()),
          BlocProvider.value(value: getIt<PointsCubit>()),
          BlocProvider.value(value: getIt<PaymentMethodsCubit>()),
          BlocProvider.value(value: getIt<BillingProfileCubit>()),
          BlocProvider.value(value: getIt<SettingsCubit>()),
          BlocProvider.value(value: getIt<VehiclesCubit>()),
          BlocProvider.value(value: getIt<CertificationCubit>()),
        ],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (context) => context.l10n.appName,
          theme: AppTheme.light(),
          locale: const Locale('es', 'PE'),
          supportedLocales: AppL10n.supportedLocales,
          localizationsDelegates: const [
            AppL10n.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: _router,
          builder: (context, child) => DesignCanvas(
            child: ToastHost(
              service: getIt<ToastService>(),
              child: Stack(
                children: [
                  Positioned.fill(child: child ?? const SizedBox.shrink()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
