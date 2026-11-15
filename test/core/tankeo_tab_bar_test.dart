import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:tankeo/core/widgets/tankeo_tab_bar.dart';

const labels = ['Auto', 'Carga', 'Grifos', 'Ajustes'];

Widget host({
  required int selected,
  required ValueChanged<int> onSelected,
  bool charging = false,
}) => MaterialApp(
  home: MediaQuery(
    data: const MediaQueryData(disableAnimations: true, size: Size(440, 956)),
    child: Scaffold(
      body: Align(
        alignment: Alignment.bottomCenter,
        child: TankeoTabBar(
          selectedIndex: selected,
          onSelected: onSelected,
          labels: labels,
          charging: charging,
          chargingLabel: 'Carga en curso',
        ),
      ),
    ),
  ),
);

void main() {
  test('el margen lateral deja la barra en 316 de ancho', () {
    expect(440 - 2 * TankeoTabBar.horizontalPaddingFor(440), 316);
    expect(TankeoTabBar.horizontalPaddingFor(320), 8);
  });

  testWidgets('usa GlassTabBar con las 4 pestañas y sus nombres', (t) async {
    await t.pumpWidget(host(selected: 0, onSelected: (_) {}));
    expect(find.byType(GlassTabBar), findsOneWidget);
    for (final l in labels) {
      expect(find.text(l), findsWidgets);
    }
  });

  testWidgets('tocar una pestaña la elige', (t) async {
    int? picked;
    await t.pumpWidget(host(selected: 0, onSelected: (i) => picked = i));
    await t.tap(find.text('Ajustes').last);
    await t.pump(const Duration(milliseconds: 400));
    expect(picked, 3);
  });

  testWidgets('el punto de carga aparece solo con una sesión activa', (
    t,
  ) async {
    await t.pumpWidget(host(selected: 0, onSelected: (_) {}));
    expect(find.byType(ChargingDot), findsNothing);
    await t.pumpWidget(host(selected: 0, onSelected: (_) {}, charging: true));
    expect(find.byType(ChargingDot), findsWidgets);
  });
}
