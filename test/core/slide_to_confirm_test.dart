import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tankeo/core/widgets/slide_to_confirm.dart';

void main() {
  Widget host(VoidCallback onOk) => MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 320,
          child: SlideToConfirm(label: 'Desliza', onConfirmed: onOk),
        ),
      ),
    ),
  );

  // El destello de «›››» corre en bucle: se avanza el reloj a mano.
  Future<void> settle(WidgetTester t) async {
    for (var i = 0; i < 10; i++) {
      await t.pump(const Duration(milliseconds: 50));
    }
  }

  Offset thumb(WidgetTester t) =>
      t.getTopLeft(find.byType(SlideToConfirm)) + const Offset(31, 31);

  testWidgets('soltar antes del 85 % vuelve al inicio sin confirmar', (
    t,
  ) async {
    var n = 0;
    await t.pumpWidget(host(() => n++));
    final g = await t.startGesture(thumb(t));
    await g.moveBy(const Offset(120, 0));
    await g.up();
    await settle(t);
    expect(n, 0);
  });

  testWidgets('deslizar pasado el 85 % confirma una sola vez', (t) async {
    var n = 0;
    await t.pumpWidget(host(() => n++));
    final g = await t.startGesture(thumb(t));
    await g.moveBy(const Offset(280, 0));
    await g.up();
    await settle(t);
    expect(n, 1);
    final g2 = await t.startGesture(thumb(t));
    await g2.moveBy(const Offset(280, 0));
    await g2.up();
    await settle(t);
    expect(n, 1);
  });

  testWidgets('es un botón accesible que se completa con un toque doble', (
    t,
  ) async {
    var n = 0;
    final h = t.ensureSemantics();
    await t.pumpWidget(host(() => n++));
    expect(find.bySemanticsLabel('Desliza'), findsOneWidget);
    t.semantics.tap(find.semantics.byLabel('Desliza'));
    await settle(t);
    expect(n, 1);
    h.dispose();
  });
}
