import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/toast/toast_service.dart';
import '../../fueling/data/fault_simulator.dart';
import '../domain/account_models.dart';
import 'notifications_cubit.dart';

class CertificationState extends Equatable {
  const CertificationState({
    required this.expired,
    required this.inspections,
    this.appointment,
  });

  final bool expired;
  final List<Inspection> inspections;
  final Appointment? appointment;

  CertificationState copyWith({bool? expired, Appointment? appointment}) =>
      CertificationState(
        expired: expired ?? this.expired,
        inspections: inspections,
        appointment: appointment ?? this.appointment,
      );

  @override
  List<Object?> get props => [expired, inspections, appointment];
}

/// Certificación del cilindro: estado, inspecciones y cita de renovación.
class CertificationCubit extends Cubit<CertificationState> {
  CertificationCubit({
    required FaultSimulator faults,
    required NotificationsCubit notifications,
    required ToastService toast,
  }) : _faults = faults,
       _notifications = notifications,
       _toast = toast,
       super(
         CertificationState(
           expired: faults.certExpired,
           inspections: [
             Inspection(date: DateTime(2026, 1, 18), annual: true),
             Inspection(date: DateTime(2025, 1, 20), annual: true),
             Inspection(date: DateTime(2024, 3, 12), annual: false),
           ],
         ),
       ) {
    faults.addListener(_sync);
  }

  final FaultSimulator _faults;
  final NotificationsCubit _notifications;
  final ToastService _toast;

  void _sync() => emit(state.copyWith(expired: _faults.certExpired));

  /// Guarda la cita; [shopName] y [dayLabel] ya vienen traducidos para el aviso.
  void schedule({
    required Appointment appointment,
    required String shopName,
    required String dayLabel,
  }) {
    emit(state.copyWith(appointment: appointment));
    _notifications.add(NotificationKind.appointment, [
      shopName,
      dayLabel,
      appointment.time,
    ]);
    _toast.show(AppToast.apptConfirmed, args: [shopName]);
  }

  @override
  Future<void> close() {
    _faults.removeListener(_sync);
    return super.close();
  }
}
