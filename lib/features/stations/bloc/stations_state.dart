part of 'stations_bloc.dart';

enum StationsEffectKind { openCharge, openSummary }

/// Efecto de una sola vez que la UI atiende (navegar).
class StationsEffect extends Equatable {
  const StationsEffect(this.kind, this.nonce);

  final StationsEffectKind kind;
  final int nonce;

  @override
  List<Object?> get props => [kind, nonce];
}

class StationsState extends Equatable {
  const StationsState({
    required this.stations,
    required this.cheapestByFuel,
    this.filter = FuelType.gnv,
    this.selectedIndex = 0,
    this.favorites = const {},
    this.filters = const StationFilter(),
    this.effect,
  });

  factory StationsState.initial(List<Station> stations) => StationsState(
    stations: stations,
    cheapestByFuel: {
      for (final f in FuelType.values) f: _cheapest(stations, f),
    },
  );

  final List<Station> stations;

  /// Índice del grifo más barato por combustible; se calcula una sola vez.
  final Map<FuelType, int> cheapestByFuel;
  final FuelType filter;
  final int selectedIndex;
  final Set<int> favorites;
  final StationsEffect? effect;
  final StationFilter filters;

  /// Índices de los grifos que cumplen los filtros.
  List<int> get visible => [
    for (var i = 0; i < stations.length; i++)
      if (filters.matches(stations[i])) i,
  ];

  Station get selected => stations[selectedIndex];
  int get cheapestIndex => cheapestByFuel[filter]!;
  bool isCheapest(int index) => cheapestIndex == index;
  bool isFavorite(int index) => favorites.contains(index);

  /// Combustible que se carga con este filtro (el diésel no entra al auto).
  FuelType get chargeFuel =>
      filter == FuelType.diesel ? FuelType.regular : filter;

  StationsState copyWith({
    FuelType? filter,
    int? selectedIndex,
    Set<int>? favorites,
    StationFilter? filters,
    StationsEffect? effect,
    bool clearEffect = false,
  }) => StationsState(
    stations: stations,
    cheapestByFuel: cheapestByFuel,
    filter: filter ?? this.filter,
    selectedIndex: selectedIndex ?? this.selectedIndex,
    favorites: favorites ?? this.favorites,
    effect: clearEffect ? null : (effect ?? this.effect),
  );

  static int _cheapest(List<Station> stations, FuelType fuel) {
    var best = 0;
    for (var i = 1; i < stations.length; i++) {
      if (stations[i].priceOf(fuel) < stations[best].priceOf(fuel)) best = i;
    }
    return best;
  }

  @override
  List<Object?> get props => [
    stations,
    cheapestByFuel,
    filter,
    selectedIndex,
    favorites,
    effect,
  ];
}
