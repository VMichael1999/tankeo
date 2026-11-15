import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tankeo/core/icons/icons.dart';
import 'package:tankeo/core/theme/app_colors.dart';
import 'package:tankeo/core/theme/app_theme.dart';
import 'package:tankeo/core/widgets/account_widgets.dart';
import 'package:tankeo/l10n/app_localizations.dart';

Widget _host(Widget child) => MaterialApp(
  theme: AppTheme.light(),
  locale: const Locale('es'),
  supportedLocales: AppL10n.supportedLocales,
  localizationsDelegates: const [
    AppL10n.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  home: Material(
    color: AppColors.bg,
    child: Padding(padding: const EdgeInsets.all(16), child: child),
  ),
);

void main() {
  goldenTest(
    'Cuenta: chips, medidor, campo y filas de ajustes',
    fileName: 'account_widgets',
    builder: () => GoldenTestGroup(
      children: [
        GoldenTestScenario(
          name: 'chips',
          child: _host(
            Wrap(
              spacing: 8,
              children: [
                ChoiceChipItem<int>(
                  label: 'GNV-2',
                  selected: true,
                  onTap: () {},
                ),
                ChoiceChipItem<int>(
                  label: 'GNV-4',
                  selected: false,
                  onTap: () {},
                ),
                ChoiceChipItem<int>(
                  label: '12',
                  selected: false,
                  enabled: false,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
        GoldenTestScenario(
          name: 'medidor',
          child: SizedBox(
            width: 300,
            child: _host(
              const Column(
                children: [
                  StrengthMeter(score: 1),
                  StrengthMeter(score: 2),
                  StrengthMeter(score: 3),
                ],
              ),
            ),
          ),
        ),
        GoldenTestScenario(
          name: 'campo con error',
          child: SizedBox(
            width: 300,
            child: _host(
              LabeledField(
                label: 'Correo electrónico',
                controller: TextEditingController(text: 'ana@'),
                error: 'Correo no válido.',
              ),
            ),
          ),
        ),
        GoldenTestScenario(
          name: 'filas',
          child: SizedBox(
            width: 340,
            child: _host(
              SettingsGroup(
                children: [
                  SettingsRow(
                    icon: AppIcon.car,
                    title: 'Mis vehículos',
                    onTap: () {},
                  ),
                  SettingsRow(
                    icon: AppIcon.bell,
                    title: 'Notificaciones',
                    switchValue: true,
                    onSwitch: (_) {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
