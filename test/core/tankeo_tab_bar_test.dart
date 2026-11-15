import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
      body: Center(
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
  testWidgets('mantiene 316 de ancho en todas las pestañas', (t) async {
    for (var i = 0; i < 4; i++) {
      await t.pumpWidget(host(selected: i, onSelected: (_) {}));
      expect(t.getSize(find.byType(TankeoTabBar)).width, 316);
    }
  });

  testWidgets('tocar una pestaña la elige', (t) async {
    int? picked;
    await t.pumpWidget(host(selected: 0, onSelected: (i) => picked = i));
    await t.tap(find.text('Ajustes'));
    await t.pump();
    expect(picked, 3);
  });

  testWidgets('arrastrar y soltar elige la pestaña más cercana', (t) async {
    int? picked;
    await t.pumpWidget(host(selected: 0, onSelected: (i) => picked = i));
    final left = t.getTopLeft(find.byType(TankeoTabBar));
    // De Auto (centro x=44) hasta cerca de Grifos (centro x=196).
    final g = await t.startGesture(left + const Offset(44, 32));
    await g.moveBy(const Offset(60, 0));
    await g.moveBy(const Offset(85, 0));
    await g.up();
    await t.pump();
    expect(picked, 2);
    expect(TankeoTabBar.nearest(TankeoTabBar.lensLeft(1) + 30), 1);
    expect(TankeoTabBar.nearest(TankeoTabBar.lensLeft(1) + 40), 2);
  });

  testWidgets('el punto de carga aparece solo con una sesión activa', (
    t,
  ) async {
    final h = t.ensureSemantics();
    await t.pumpWidget(host(selected: 0, onSelected: (_) {}));
    expect(find.bySemanticsLabel('Carga'), findsOneWidget);
    expect(t.getSemantics(find.bySemanticsLabel('Carga')).hint, isEmpty);
    await t.pumpWidget(host(selected: 0, onSelected: (_) {}, charging: true));
    expect(
      t.getSemantics(find.bySemanticsLabel('Carga')).hint,
      'Carga en curso',
    );
    h.dispose();
  });
}
