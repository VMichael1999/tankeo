import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:tankeo/core/theme/app_colors.dart';
import 'package:tankeo/core/theme/app_theme.dart';
import 'package:tankeo/core/widgets/tankeo_tab_bar.dart';

const _labels = ['Auto', 'Carga', 'Grifos', 'Ajustes'];

Widget _bar(
  int i, {
  bool dark = false,
  bool charging = false,
  bool compact = false,
}) => SizedBox(
  width: 440,
  height: 130,
  child: MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: dark ? ThemeData.dark() : AppTheme.light(),
    home: MediaQuery(
      data: const MediaQueryData(disableAnimations: true, size: Size(440, 130)),
      child: Material(
        color: dark ? AppColors.ink : AppColors.bg,
        child: Stack(
          children: [
            // Algo de color debajo para ver el vidrio.
            Positioned(
              left: 40,
              top: 20,
              width: 120,
              height: 70,
              child: ColoredBox(color: AppColors.primary),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: TankeoTabBar(
                selectedIndex: i,
                onSelected: (_) {},
                labels: _labels,
                charging: charging,
                compact: compact,
              ),
            ),
          ],
        ),
      ),
    ),
  ),
);

void main() {
  goldenTest(
    'Barra de pestañas',
    fileName: 'tab_bar',
    builder: () => GoldenTestGroup(
      columns: 2,
      children: [
        for (var i = 0; i < 4; i++)
          GoldenTestScenario(name: '${_labels[i]} claro', child: _bar(i)),
        for (var i = 0; i < 4; i++)
          GoldenTestScenario(
            name: '${_labels[i]} oscuro',
            child: _bar(i, dark: true),
          ),
        GoldenTestScenario(
          name: 'carga en curso',
          child: _bar(1, charging: true),
        ),
        GoldenTestScenario(
          name: 'carga en curso oscuro',
          child: _bar(0, dark: true, charging: true),
        ),
        GoldenTestScenario(name: 'compacta', child: _bar(0, compact: true)),
      ],
    ),
  );
}
