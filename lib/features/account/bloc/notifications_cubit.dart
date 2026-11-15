import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/clock.dart';
import '../domain/account_models.dart';

class NotificationsState extends Equatable {
  const NotificationsState(this.items);

  final List<AppNotification> items;

  int get unread => items.where((n) => !n.read).length;

  @override
  List<Object?> get props => [items];
}

/// Avisos de la app. Cada uno sin leer lleva un punto naranja.
class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(
    this._clock, {
    String priceStation = 'Grifo Benavides Express',
    String paymentStation = 'EcoGrifo Javier Prado',
  }) : super(NotificationsState(_seed(_clock, priceStation, paymentStation)));

  final Clock _clock;
  int _nextId = 100;

  static List<AppNotification> _seed(
    Clock c,
    String priceStation,
    String paymentStation,
  ) {
    final now = c.now();
    return [
      AppNotification(
        id: 1,
        kind: NotificationKind.cert,
        at: now.subtract(const Duration(hours: 2)),
        args: const ['18 ENE 2027'],
      ),
      AppNotification(
        id: 2,
        kind: NotificationKind.price,
        at: now.subtract(const Duration(hours: 5)),
        args: ['S/ 1.65', priceStation],
      ),
      AppNotification(
        id: 3,
        kind: NotificationKind.payment,
        at: now.subtract(const Duration(days: 3)),
        read: true,
        args: ['S/ 19.01', paymentStation, 'boleta'],
      ),
      AppNotification(
        id: 4,
        kind: NotificationKind.points,
        at: now.subtract(const Duration(days: 3)),
        read: true,
        points: 19,
        args: const ['1,240'],
      ),
    ];
  }

  void markRead(int id) => emit(
    NotificationsState([
      for (final n in state.items) n.id == id ? n.asRead() : n,
    ]),
  );

  void readAll() =>
      emit(NotificationsState([for (final n in state.items) n.asRead()]));

  void add(NotificationKind kind, List<String> args, {int points = 0}) => emit(
    NotificationsState([
      AppNotification(
        id: _nextId++,
        kind: kind,
        at: _clock.now(),
        args: args,
        points: points,
      ),
      ...state.items,
    ]),
  );
}
