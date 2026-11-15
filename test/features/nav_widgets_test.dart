import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tankeo/core/theme/app_theme.dart';
import 'package:tankeo/core/toast/toast_service.dart';
import 'package:tankeo/core/utils/clock.dart';
import 'package:tankeo/features/navigation/bloc/navigation_bloc.dart';
import 'package:tankeo/features/navigation/data/route_simulator.dart';
import 'package:tankeo/features/navigation/domain/turn_instruction.dart';
import 'package:tankeo/features/navigation/ui/nav_widgets.dart';
import 'package:tankeo/features/stations/data/station_repository.dart';
import 'package:tankeo/l10n/app_localizations.dart';

Widget host(Widget child) => MaterialApp(
  theme: AppTheme.light(),
  locale: const Locale('es'),
  supportedLocales: AppL10n.supportedLocales,
  localizationsDelegates: const [
    AppL10n.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  home: MediaQuery(
    data: const MediaQueryData(disableAnimations: true, size: Size(440, 956)),
    child: Scaffold(
      body: Align(alignment: Alignment.bottomCenter, child: child),
    ),
  ),
);

const card = NavCardData(
  minutes: 7,
  distance: '1.3 km',
  arrival: '4:45 p. m.',
  progress: .5,
  stationName: 'PRIMAX Av. Arequipa GNV',
  pumpLine: 'Surtidor 5 · Isla A',
  fuelLabel: 'GNV',
  price: 'S/ 1.69',
);

void main() {
  testWidgets('la ✕ abre la confirmación y «Salir» sale', (t) async {
    var exits = 0;
    await t.pumpWidget(
      host(
        Builder(
          builder: (c) => NavBottomCard(
            data: card,
            onExit: () => confirmNavExit(c, () => exits++),
            onDestination: () {},
          ),
        ),
      ),
    );
    await t.tap(find.bySemanticsLabel('Salir'));
    await t.pumpAndSettle();
    expect(find.text('¿Salir de la navegación?'), findsOneWidget);
    await t.tap(find.text('Seguir'));
    await t.pumpAndSettle();
    expect(exits, 0);
    await t.tap(find.bySemanticsLabel('Salir'));
    await t.pumpAndSettle();
    await t.tap(find.widgetWithText(GestureDetector, 'Salir').last);
    await t.pumpAndSettle();
    expect(exits, 1);
  });

  testWidgets('a menos de 50 m dice «Gira ahora»', (t) async {
    await t.pumpWidget(
      host(
        const NavBanner(
          data: NavBannerData(
            overview: false,
            type: TurnType.right,
            distanceM: 30,
            road: 'Av. Arequipa',
            turnText: 'A la derecha en Av. Arequipa',
          ),
        ),
      ),
    );
    expect(find.text('Gira ahora'), findsOneWidget);
  });

  testWidgets('el velocímetro se pone rojo sobre el límite', (t) async {
    await t.pumpWidget(host(const SpeedCluster(speed: 46, limit: 40)));
    expect(find.text('40'), findsOneWidget);
    final speed = t.widget<Text>(find.text('46'));
    expect(speed.style!.color, isNot(equals(const Color(0xFF0F1115))));
  });

  test('recentrar aparece solo después de mover el mapa', () async {
    final station = const InMemoryStationRepository().getStations().first;
    final bloc = NavigationBloc(
      clock: FixedClock(DateTime.utc(2026, 11, 15, 16, 20)),
      toast: ToastService(),
      overviewDelay: const Duration(milliseconds: 5),
      simulatorFor: (p) => RouteSimulator(
        p,
        duration: const Duration(seconds: 30),
        tick: const Duration(milliseconds: 50),
      ),
    )..add(NavigationStarted(station));
    await Future<void>.delayed(const Duration(milliseconds: 80));
    expect((bloc.state! as NavDriving).followPaused, isFalse);
    bloc.add(const MapMovedByUser());
    await Future<void>.delayed(const Duration(milliseconds: 60));
    expect((bloc.state! as NavDriving).followPaused, isTrue);
    bloc.add(const RecenterPressed());
    await Future<void>.delayed(Duration.zero);
    expect((bloc.state! as NavDriving).followPaused, isFalse);
    await bloc.close();
  });
}
