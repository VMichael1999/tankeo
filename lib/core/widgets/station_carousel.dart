import 'package:flutter/material.dart';

import '../domain/fuel_type.dart';
import '../../features/stations/domain/station.dart';
import 'station_card.dart';

/// Carrusel horizontal de tarjetas de grifo que se ajusta al centro.
class StationCarousel extends StatelessWidget {
  const StationCarousel({
    super.key,
    required this.controller,
    required this.stations,
    required this.fuel,
    required this.cheapestIndex,
    required this.onSettled,
    required this.onCardTap,
    required this.onShare,
    required this.onGo,
  });

  /// Cada página mide 362 de ancho (tarjeta de 350 + 12 de separación) sobre 440.
  static const pageFraction = 362 / 440;
  static const height = 205.0;

  final PageController controller;
  final List<Station> stations;
  final FuelType fuel;
  final int cheapestIndex;

  /// Página en la que quedó el carrusel al dejar de moverse.
  final ValueChanged<int> onSettled;
  final ValueChanged<int> onCardTap;
  final ValueChanged<int> onShare;
  final ValueChanged<int> onGo;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: NotificationListener<ScrollEndNotification>(
        onNotification: (n) {
          final page = controller.page?.round();
          if (page != null) onSettled(page);
          return false;
        },
        child: PageView.builder(
          controller: controller,
          clipBehavior: Clip.none,
          itemCount: stations.length,
          itemBuilder: (context, i) => Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: SizedBox(
                height: 185,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: StationCard(
                    station: stations[i],
                    fuel: fuel,
                    cheapest: cheapestIndex == i,
                    onTap: () => onCardTap(i),
                    onShare: () => onShare(i),
                    onGo: () => onGo(i),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
