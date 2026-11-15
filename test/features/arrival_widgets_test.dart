import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tankeo/core/theme/app_theme.dart';
import 'package:tankeo/features/navigation/ui/arrival_widgets.dart';
import 'package:tankeo/l10n/app_localizations.dart';

const gnvInfo = ArrivalInfo(
  stationName: 'PRIMAX Av. Arequipa GNV',
  address: 'Av. Arequipa 3120, San Isidro',
  island: 'A',
  pump: 5,
  rightSide: true,
  distance: '1.3 km',
  minutes: 7,
  arrivalTime: '3:50 p. m.',
  fuelLabel: 'GNV',
  price: 'S/ 1.69',
  pumpFree: true,
);

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

void main() {
  testWidgets('el banner dice isla, surtidor y lado', (t) async {
    await t.pumpWidget(host(const ArrivalBanner(info: gnvInfo)));
    expect(find.text('Llegaste a tu grifo'), findsOneWidget);
    expect(find.text('Entra a la isla A'), findsOneWidget);
    expect(find.text('Surtidor 5 · a tu derecha'), findsOneWidget);
  });

  testWidgets('la hoja muestra los datos y «Salir» dispara la salida', (
    t,
  ) async {
    var exit = 0, go = 0;
    await t.pumpWidget(
      host(
        ArrivalSheet(
          info: gnvInfo,
          onContinue: () => go++,
          onExit: () => exit++,
        ),
      ),
    );
    await t.pump();
    expect(find.text('1.3 km'), findsOneWidget);
    expect(find.text('7 min'), findsOneWidget);
    expect(find.text('3:50 p. m.'), findsOneWidget);
    expect(find.text('Isla A · GNV y gasolina'), findsOneWidget);
    expect(find.text('Libre ahora'), findsOneWidget);
    expect(find.text('S/ 1.69'), findsOneWidget);
    await t.tap(find.text('Salir de la navegación'));
    expect(exit, 1);
    expect(go, 0);
  });

  testWidgets('deslizar al 85 % en la hoja continúa a la carga', (t) async {
    var go = 0;
    await t.pumpWidget(
      host(ArrivalSheet(info: gnvInfo, onContinue: () => go++, onExit: () {})),
    );
    await t.pump();
    final slider = find.ancestor(
      of: find.text('Desliza para empezar la carga'),
      matching: find.byType(GestureDetector),
    );
    final box = t.getRect(slider.first);
    final g = await t.startGesture(Offset(box.left + 31, box.center.dy));
    await g.moveBy(Offset(box.width, 0));
    await g.up();
    await t.pump();
    expect(go, 1);
  });
}
