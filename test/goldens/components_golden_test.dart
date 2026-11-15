import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tankeo/core/domain/fuel_type.dart';
import 'package:tankeo/core/theme/app_colors.dart';
import 'package:tankeo/core/theme/app_theme.dart';
import 'package:tankeo/core/widgets/fuel_filter_chips.dart';
import 'package:tankeo/core/widgets/fuel_vessel.dart';
import 'package:tankeo/core/widgets/primary_button.dart';
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
    'PrimaryButton: gasolina, GNV, deshabilitado y cargando',
    fileName: 'primary_button',
    builder: () => GoldenTestGroup(
      children: [
        GoldenTestScenario(
          name: 'gasolina',
          child: SizedBox(
            width: 300,
            child: PrimaryButton(
              label: 'Autorizar surtidor 4',
              color: AppColors.primary,
              onPressed: () {},
            ),
          ),
        ),
        GoldenTestScenario(
          name: 'gnv',
          child: SizedBox(
            width: 300,
            child: PrimaryButton(
              label: 'Autorizar surtidor 4',
              color: AppColors.gnv,
              onPressed: () {},
            ),
          ),
        ),
        GoldenTestScenario(
          name: 'deshabilitado',
          child: const SizedBox(
            width: 300,
            child: PrimaryButton(
              label: 'Pagar',
              color: AppColors.primary,
              onPressed: null,
            ),
          ),
        ),
      ],
    ),
  );

  goldenTest(
    'FuelVessel y FuelFilterChips',
    fileName: 'fuel_widgets',
    builder: () => GoldenTestGroup(
      children: [
        GoldenTestScenario(
          name: 'recipientes',
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FuelVessel(percent: 38, gnv: false),
              SizedBox(width: 16),
              FuelVessel(percent: 25, gnv: true),
            ],
          ),
        ),
        GoldenTestScenario(
          name: 'filtros',
          child: SizedBox(
            width: 440,
            child: Builder(
              builder: (c) => _host(
                FuelFilterChips(selected: FuelType.gnv, onSelected: (_) {}),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
