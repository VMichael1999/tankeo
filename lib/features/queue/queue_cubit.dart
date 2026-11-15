import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/toast/toast_service.dart';

enum QueueStatus { hidden, waiting, ready }

class QueueState extends Equatable {
  const QueueState({
    this.status = QueueStatus.hidden,
    this.progress = 0,
    this.stationIndex,
    this.served = const {},
  });

  final QueueStatus status;

  /// Avance de la espera, de 0 a 1.
  final double progress;
  final int? stationIndex;

  /// Grifos donde ya te tocó el turno.
  final Set<int> served;

  bool get visible => status != QueueStatus.hidden;

  /// Posición: 2 → 1 → 0 (te toca).
  int get position => progress < .5 ? 2 : (progress < 1 ? 1 : 0);

  /// Minutos estimados que faltan.
  int get minutesLeft => (6 * (1 - progress)).ceil().clamp(1, 6);

  bool isServed(int station) => served.contains(station);

  QueueState copyWith({
    QueueStatus? status,
    double? progress,
    int? stationIndex,
    Set<int>? served,
  }) => QueueState(
    status: status ?? this.status,
    progress: progress ?? this.progress,
    stationIndex: stationIndex ?? this.stationIndex,
    served: served ?? this.served,
  );

  @override
  List<Object?> get props => [status, progress, stationIndex, served];
}

/// Turno en un grifo lleno: 2 autos antes, luego 1, y «te toca» (6.5 s en la
/// simulación, 1.5 s con menos animaciones).
class QueueCubit extends Cubit<QueueState> {
  QueueCubit(this._toast) : super(const QueueState());

  final ToastService _toast;
  Timer? _timer;

  void join(int stationIndex, {bool reduceMotion = false}) {
    _timer?.cancel();
    final total = reduceMotion ? 1500 : 6500;
    final watch = Stopwatch()..start();
    emit(
      state.copyWith(
        status: QueueStatus.waiting,
        progress: 0,
        stationIndex: stationIndex,
      ),
    );
    _timer = Timer.periodic(const Duration(milliseconds: 33), (t) {
      final k = (watch.elapsedMilliseconds / total).clamp(0.0, 1.0);
      if (k >= 1) {
        t.cancel();
        emit(state.copyWith(status: QueueStatus.ready, progress: 1));
      } else {
        emit(state.copyWith(progress: k));
      }
    });
  }

  /// «Salir de la cola».
  void leave() {
    _timer?.cancel();
    emit(state.copyWith(status: QueueStatus.hidden, progress: 0));
    _toast.show(AppToast.leftQueue);
  }

  /// «Ir al surtidor»: marca el grifo como atendido y cierra el diálogo.
  void serve() {
    final i = state.stationIndex;
    if (i == null) return;
    emit(
      state.copyWith(status: QueueStatus.hidden, served: {...state.served, i}),
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
