import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../features/account/ui/history_screen.dart';
import '../features/account/ui/notifications_screen.dart';
import '../features/account/ui/payment_methods_screen.dart';
import '../features/account/ui/points_screen.dart';
import '../features/account/ui/settings_screen.dart';
import '../features/account/ui/vehicles_screen.dart';
import '../features/payment/domain/tax_document.dart';
import '../core/toast/toast_service.dart';
import '../features/account/bloc/points_cubit.dart';
import '../features/account/bloc/vehicles_cubit.dart';
import '../features/auth/auth_repository.dart';
import '../features/auth/bloc/password_reset_bloc.dart';
import '../features/auth/bloc/sign_up_bloc.dart';
import '../features/auth/ui/password_reset_screen.dart';
import '../features/auth/ui/sign_up_screen.dart';
import '../features/auth/ui/login_screen.dart';
import '../core/utils/clock.dart';
import '../features/navigation/bloc/navigation_bloc.dart';
import '../features/navigation/ui/navigation_screen.dart';
import '../features/stations/bloc/stations_bloc.dart';
import '../features/stations/data/road_route_repository.dart';
import 'di.dart';
import '../features/certification/certification_screen.dart';
import '../features/fueling/ui/charge_screen.dart';
import '../features/payment/ui/summary_screen.dart';
import '../features/receipt/ui/receipt_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/stations/ui/detail_screen.dart';
import '../features/stations/ui/map_screen.dart';
import '../features/vehicle/ui/home_screen.dart';
import 'app_shell.dart';

/// Rutas de la app. Inicio y Carga viven dentro de un `ShellRoute` que
/// muestra la barra de navegación flotante.
abstract final class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const home = '/home';
  static const charge = '/charge';
  static const map = '/map';
  static const details = '/details';
  static const summary = '/summary';
  static const receipt = '/receipt';
  static const certification = '/certification';
  static const settings = '/settings';
  static const history = '/history';
  static const points = '/points';
  static const notifications = '/notifications';
  static const vehicles = '/vehicles';
  static const addVehicle = '/vehicles/add';
  static const paymentMethods = '/payment-methods';
  static const signUp = '/signup';
  static const resetPassword = '/reset-password';
  static const navigation = '/navigation';
}

/// Fundido de 350 ms entre pantallas.
CustomTransitionPage<void> _fade(GoRouterState state, Widget child) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: const Duration(milliseconds: 350),
      transitionsBuilder: (context, animation, _, child) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.ease),
        child: child,
      ),
    );

/// El comprobante sube desde abajo en 500 ms.
CustomTransitionPage<void> _slideUp(GoRouterState state, Widget child) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 500),
      reverseTransitionDuration: const Duration(milliseconds: 350),
      transitionsBuilder: (context, animation, _, child) => SlideTransition(
        position: Tween(begin: const Offset(0, 1), end: Offset.zero).animate(
          CurvedAnimation(parent: animation, curve: const Cubic(.2, .8, .2, 1)),
        ),
        child: child,
      ),
    );

GoRouter createRouter() => GoRouter(
  // `--dart-define=INITIAL_ROUTE=/summary` abre directo una pantalla (útil para probar).
  initialLocation: const String.fromEnvironment(
    'INITIAL_ROUTE',
    defaultValue: AppRoutes.splash,
  ),
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      pageBuilder: (c, s) => _fade(s, const SplashScreen()),
    ),
    GoRoute(
      path: AppRoutes.login,
      pageBuilder: (c, s) => _fade(s, const LoginScreen()),
    ),
    ShellRoute(
      builder: (context, state, child) =>
          AppShell(location: state.uri.path, child: child),
      routes: [
        GoRoute(
          path: AppRoutes.home,
          pageBuilder: (c, s) => _fade(s, const HomeScreen()),
        ),
        GoRoute(
          path: AppRoutes.charge,
          pageBuilder: (c, s) => _fade(s, const ChargeScreen()),
        ),
        GoRoute(
          path: AppRoutes.settings,
          pageBuilder: (c, s) => _fade(s, const SettingsScreen()),
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.map,
      pageBuilder: (c, s) => _fade(s, const MapScreen()),
    ),
    GoRoute(
      path: AppRoutes.details,
      pageBuilder: (c, s) => _fade(s, const DetailScreen()),
    ),
    GoRoute(
      path: AppRoutes.summary,
      pageBuilder: (c, s) => _fade(s, const SummaryScreen()),
    ),
    GoRoute(
      path: AppRoutes.certification,
      pageBuilder: (c, s) => _fade(s, const CertificationScreen()),
    ),
    GoRoute(
      path: AppRoutes.receipt,
      pageBuilder: (c, s) =>
          _slideUp(s, ReceiptScreen(document: s.extra as TaxDocument?)),
    ),
    GoRoute(
      path: AppRoutes.signUp,
      pageBuilder: (c, s) => _fade(
        s,
        BlocProvider(
          create: (_) => SignUpBloc(
            auth: getIt<AuthRepository>(),
            vehicles: getIt<VehiclesCubit>(),
            points: getIt<PointsCubit>(),
          ),
          child: const SignUpScreen(),
        ),
      ),
    ),
    GoRoute(
      path: AppRoutes.addVehicle,
      pageBuilder: (c, s) => _fade(
        s,
        BlocProvider(
          create: (_) => SignUpBloc(
            auth: getIt<AuthRepository>(),
            vehicles: getIt<VehiclesCubit>(),
            points: getIt<PointsCubit>(),
            addMode: true,
          ),
          child: const SignUpScreen(),
        ),
      ),
    ),
    GoRoute(
      path: AppRoutes.resetPassword,
      pageBuilder: (c, s) => _fade(
        s,
        BlocProvider(
          create: (_) => PasswordResetBloc(toast: getIt<ToastService>()),
          child: const PasswordResetScreen(),
        ),
      ),
    ),
    GoRoute(
      path: AppRoutes.navigation,
      pageBuilder: (c, s) => _fade(
        s,
        BlocProvider(
          create: (c) => NavigationBloc(
            clock: getIt<Clock>(),
            toast: getIt<ToastService>(),
            roadRoute: getIt<RoadRouteRepository>().load,
          )..add(NavigationStarted(c.read<StationsBloc>().state.selected)),
          child: const NavigationScreen(),
        ),
      ),
    ),
    GoRoute(
      path: AppRoutes.history,
      pageBuilder: (c, s) => _fade(s, const HistoryScreen()),
    ),
    GoRoute(
      path: AppRoutes.points,
      pageBuilder: (c, s) => _fade(s, const PointsScreen()),
    ),
    GoRoute(
      path: AppRoutes.notifications,
      pageBuilder: (c, s) => _fade(s, const NotificationsScreen()),
    ),
    GoRoute(
      path: AppRoutes.vehicles,
      pageBuilder: (c, s) => _fade(s, const VehiclesScreen()),
    ),
    GoRoute(
      path: AppRoutes.paymentMethods,
      pageBuilder: (c, s) => _fade(s, const PaymentMethodsScreen()),
    ),
  ],
);
