import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tankeo/core/theme/app_colors.dart';
import 'package:tankeo/core/theme/app_theme.dart';
import 'package:tankeo/features/navigation/domain/turn_instruction.dart';
import 'package:tankeo/features/navigation/ui/nav_widgets.dart';
import 'package:tankeo/l10n/app_localizations.dart';

Widget _host(
  Widget child, {
  double height = 170,
  double width = 440,
  double pad = 14,
}) => SizedBox(
  width: width,
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
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: pad),
          child: Align(alignment: Alignment.bottomCenter, child: child),
        ),
      ),
    ),
  ),
);

NavBannerData _b({
  bool overview = false,
  double m = 350,
  TurnType? next = TurnType.right,
}) => NavBannerData(
  overview: overview,
  type: TurnType.left,
  distanceM: m,
  road: 'Av. Santo Toribio',
  turnText: 'A la izquierda en Av. Javier Prado',
  nextType: next,
  nextLabel: next == null ? null : 'Luego a la derecha en',
  nextStreet: next == null ? null : 'Av. Arequipa',
);

NavCardData _c(double p) => NavCardData(
  minutes: 7,
  distance: '1.3 km',
  arrival: '4:45 p. m.',
  progress: p,
  stationName: 'PRIMAX Av. Arequipa GNV',
  pumpLine: 'Surtidor 5 · Isla A',
  fuelLabel: 'GNV',
  price: 'S/ 1.69',
);

void main() {
  goldenTest(
    'Navegación: banner',
    fileName: 'nav_banner',
    builder: () => GoldenTestGroup(
      children: [
        GoldenTestScenario(
          name: 'vista general',
          child: _host(NavBanner(data: _b(overview: true))),
        ),
        GoldenTestScenario(
          name: 'en marcha',
          child: _host(NavBanner(data: _b())),
        ),
        GoldenTestScenario(
          name: 'gira ahora',
          child: _host(NavBanner(data: _b(m: 30))),
        ),
        GoldenTestScenario(
          name: 'último tramo',
          child: _host(NavBanner(data: _b(next: null)), height: 120),
        ),
      ],
    ),
  );

  goldenTest(
    'Navegación: hoja',
    fileName: 'nav_bottom_card',
    builder: () => GoldenTestGroup(
      children: [
        for (final p in [0.0, .5, .95])
          GoldenTestScenario(
            name: '${(p * 100).round()} %',
            child: _host(
              NavBottomCard(data: _c(p), onExit: () {}, onDestination: () {}),
              height: 300,
              pad: 0,
            ),
          ),
      ],
    ),
  );

  goldenTest(
    'Navegación: velocímetro sobre el límite',
    fileName: 'nav_speed',
    builder: () => GoldenTestGroup(
      children: [
        GoldenTestScenario(
          name: '46 en 40',
          child: _host(
            const SpeedCluster(speed: 46, limit: 40),
            height: 90,
            width: 160,
          ),
        ),
      ],
    ),
  );
}
