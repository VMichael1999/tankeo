part of 'stations_bloc.dart';

sealed class StationsEvent extends Equatable {
  const StationsEvent();

  @override
  List<Object?> get props => [];
}

/// Cambia el filtro del mapa. Con diésel solo muestra precios.
class FilterChanged extends StationsEvent {
  const FilterChanged(this.fuel);
  final FuelType fuel;

  @override
  List<Object?> get props => [fuel];
}

/// Grifo elegido desde el carrusel o desde un pin.
class StationSelected extends StationsEvent {
  const StationSelected(this.index);
  final int index;

  @override
  List<Object?> get props => [index];
}

class FavoriteToggled extends StationsEvent {
  const FavoriteToggled([this.index]);
  final int? index;

  @override
  List<Object?> get props => [index];
}

/// «Ir a cargar».
class GoToFuel extends StationsEvent {
  const GoToFuel(this.index);
  final int index;

  @override
  List<Object?> get props => [index];
}

class StationsEffectHandled extends StationsEvent {
  const StationsEffectHandled();
}

/// «Mostrar N grifos» en la hoja de filtros.
class FiltersApplied extends StationsEvent {
  const FiltersApplied(this.filters);
  final StationFilter filters;

  @override
  List<Object?> get props => [filters];
}
