import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/domain/fuel_type.dart';
import '../../../core/toast/toast_service.dart';
import '../../fueling/data/fueling_session_repository.dart';
import '../data/station_repository.dart';
import '../domain/station.dart';
import '../domain/station_filter.dart';

part 'stations_event.dart';
part 'stations_state.dart';

/// Grifos cercanos: filtro por combustible, grifo elegido, favoritos y el
/// salto a la pantalla de carga.
class StationsBloc extends Bloc<StationsEvent, StationsState> {
  StationsBloc({
    required StationRepository repository,
    required FuelingSessionRepository session,
    required ToastService toast,
  }) : _session = session,
       _toast = toast,
       super(StationsState.initial(repository.getStations())) {
    on<FilterChanged>(_onFilterChanged);
    on<StationSelected>(_onSelected);
    on<FavoriteToggled>(_onFavorite);
    on<GoToFuel>(_onGoToFuel);
    on<FiltersApplied>(_onFilters);
    on<StationsEffectHandled>(
      (e, emit) => emit(state.copyWith(clearEffect: true)),
    );
  }

  final FuelingSessionRepository _session;
  final ToastService _toast;
  int _nonce = 0;

  void _onFilterChanged(FilterChanged e, Emitter<StationsState> emit) {
    emit(state.copyWith(filter: e.fuel));
    if (e.fuel == FuelType.diesel) {
      _toast.show(AppToast.dieselInfo);
    } else if (_session.status == SessionStatus.idle) {
      _session.selectFuel(e.fuel);
    }
  }

  void _onSelected(StationSelected e, Emitter<StationsState> emit) {
    if (e.index == state.selectedIndex) return;
    emit(state.copyWith(selectedIndex: e.index));
  }

  void _onFavorite(FavoriteToggled e, Emitter<StationsState> emit) {
    final index = e.index ?? state.selectedIndex;
    final favs = {...state.favorites};
    final added = favs.add(index);
    if (!added) favs.remove(index);
    emit(state.copyWith(favorites: favs));
    _toast.show(added ? AppToast.favoriteAdded : AppToast.favoriteRemoved);
  }

  void _onFilters(FiltersApplied e, Emitter<StationsState> emit) {
    final next = state.copyWith(filters: e.filters);
    final visible = next.visible;
    final keep = visible.contains(state.selectedIndex);
    emit(
      next.copyWith(
        selectedIndex: keep || visible.isEmpty
            ? state.selectedIndex
            : visible.first,
      ),
    );
    _toast.show(AppToast.filtersApplied, args: ['${visible.length}']);
  }

  void _onGoToFuel(GoToFuel e, Emitter<StationsState> emit) {
    final status = _session.status;
    final active = status == SessionStatus.active;
    if (active && _session.activeStation != e.index) {
      _toast.show(AppToast.finishCurrentCharge);
      return;
    }
    if (status == SessionStatus.awaitingPayment) {
      _toast.show(AppToast.payPreviousFirst);
      emit(
        state.copyWith(
          effect: StationsEffect(StationsEffectKind.openSummary, ++_nonce),
        ),
      );
      return;
    }
    final station = state.stations[e.index];
    if (!active) {
      // El diésel no entra al McLaren F1: se carga Regular.
      final fuel = state.filter == FuelType.diesel
          ? FuelType.regular
          : state.filter;
      _session.selectFuel(fuel, stationIndex: e.index);
      _toast.show(
        AppToast.arrived,
        args: [station.name, station.assignedPumpNumber],
      );
    }
    emit(
      state.copyWith(
        selectedIndex: e.index,
        effect: StationsEffect(StationsEffectKind.openCharge, ++_nonce),
      ),
    );
  }
}
