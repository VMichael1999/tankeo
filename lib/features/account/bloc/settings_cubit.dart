import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/domain/fuel_type.dart';

class SettingsState extends Equatable {
  const SettingsState({
    this.notifications = true,
    this.priceAlerts = true,
    this.certReminder = true,
    this.preferred = TankKind.gnv,
  });

  final bool notifications;
  final bool priceAlerts;
  final bool certReminder;
  final TankKind preferred;

  SettingsState copyWith({
    bool? notifications,
    bool? priceAlerts,
    bool? certReminder,
    TankKind? preferred,
  }) => SettingsState(
    notifications: notifications ?? this.notifications,
    priceAlerts: priceAlerts ?? this.priceAlerts,
    certReminder: certReminder ?? this.certReminder,
    preferred: preferred ?? this.preferred,
  );

  @override
  List<Object?> get props => [
    notifications,
    priceAlerts,
    certReminder,
    preferred,
  ];
}

/// Preferencias del usuario.
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState());

  void setNotifications(bool v) => emit(state.copyWith(notifications: v));
  void setPriceAlerts(bool v) => emit(state.copyWith(priceAlerts: v));
  void setCertReminder(bool v) => emit(state.copyWith(certReminder: v));
  void setPreferred(TankKind k) => emit(state.copyWith(preferred: k));
}
