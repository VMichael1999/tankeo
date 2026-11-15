import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tankeo/core/theme/app_colors.dart';
import 'package:tankeo/core/theme/app_theme.dart';
import 'package:tankeo/features/navigation/ui/arrival_widgets.dart';
import 'package:tankeo/l10n/app_localizations.dart';

Widget _host(Widget child, {double height = 130}) => SizedBox(
  width: 440,
  height: height,
  child: MaterialApp(
    debugShowCheckedModeBanner: false,
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
      data: const MediaQueryData(disableAnimations: true),
      child: Material(
        color: AppColors.mapBase,
        child: Align(alignment: Alignment.bottomCenter, child: child),
      ),
    ),
  ),
);

ArrivalInfo _info({
  String name = 'PRIMAX Av. Arequipa GNV',
  String fuel = 'GNV',
  String price = 'S/ 1.69',
  bool right = true,
}) => ArrivalInfo(
  stationName: name,
  address: 'Av. Arequipa 3120, San Isidro',
  island: 'A',
  pump: 5,
  rightSide: right,
  distance: '1.3 km',
  minutes: 7,
  arrivalTime: '3:50 p. m.',
  fuelLabel: fuel,
  price: price,
  pumpFree: true,
);

void main() {
  goldenTest(
    'Llegada: banner',
    fileName: 'arrival_banner',
    builder: () => GoldenTestGroup(
      children: [
        GoldenTestScenario(
          name: 'derecha',
          child: _host(ArrivalBanner(info: _info())),
        ),
        GoldenTestScenario(
          name: 'izquierda',
          child: _host(ArrivalBanner(info: _info(right: false))),
        ),
      ],
    ),
  );

  goldenTest(
    'Llegada: hoja',
    fileName: 'arrival_sheet',
    pumpBeforeTest: (t) async {
      for (var i = 0; i < 20; i++) {
        await t.pump(const Duration(milliseconds: 50));
      }
    },
    builder: () => GoldenTestGroup(
      children: [
        GoldenTestScenario(
          name: 'GNV',
          child: _host(
            ArrivalSheet(info: _info(), onContinue: () {}, onExit: () {}),
            height: 470,
          ),
        ),
        GoldenTestScenario(
          name: 'gasolina',
          child: _host(
            ArrivalSheet(
              info: _info(fuel: 'Regular', price: 'S/ 17.99'),
              onContinue: () {},
              onExit: () {},
            ),
            height: 470,
          ),
        ),
        GoldenTestScenario(
          name: 'nombre largo',
          child: _host(
            ArrivalSheet(
              info: _info(
                name: 'Estación de Servicio Repsol Avenida Paseo Parodi',
              ),
              onContinue: () {},
              onExit: () {},
            ),
            height: 470,
          ),
        ),
      ],
    ),
  );
}
