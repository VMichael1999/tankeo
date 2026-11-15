import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import 'app/app.dart';
import 'app/di.dart';
import 'features/stations/data/places_station_repository.dart';
import 'features/stations/data/station_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(); // clave de Google Maps (.env)
  Intl.defaultLocale = 'es_PE';
  await initializeDateFormatting('es');
  await initializeDateFormatting('es_PE');
  await LiquidGlassWidgets.initialize();
  configureDependencies();
  // Grifos reales de Google Places (con tiempo límite; si falla, los de ejemplo).
  await (getIt<StationRepository>() as PlacesStationRepository).refresh();
  runApp(
    LiquidGlassWidgets.wrap(
      brightnessResolver: Theme.maybeBrightnessOf,
      child: const TankeoApp(),
    ),
  );
}
