import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/clock.dart';
import '../domain/account_models.dart';

class PointsState extends Equatable {
  const PointsState({
    required this.balance,
    required this.lifetime,
    required this.movements,
  });

  final int balance;
  final int lifetime;
  final List<PointsMovement> movements;

  static const goldFrom = 2000;
  bool get isGold => lifetime >= goldFrom;
  double get progress => (lifetime / goldFrom).clamp(0, 1).toDouble();
  int get toGold => (goldFrom - lifetime).clamp(0, goldFrom);

  @override
  List<Object?> get props => [balance, lifetime, movements];
}

/// Puntos Tankeo: 1 punto por S/ 1 cargado; canjes con código `TQ-xxxx`.
class PointsCubit extends Cubit<PointsState> {
  PointsCubit(this._clock, {String seedStation = 'EcoGrifo Javier Prado'})
    : super(
        PointsState(
          balance: 1240,
          lifetime: 1540,
          movements: [
            PointsMovement(
              kind: MovementKind.charge,
              arg: seedStation,
              delta: 19,
              at: _clock.now().subtract(const Duration(days: 3)),
            ),
            PointsMovement(
              kind: MovementKind.redeem,
              arg: 'Café en tienda',
              delta: -300,
              at: _clock.now().subtract(const Duration(days: 9)),
            ),
            PointsMovement(
              kind: MovementKind.welcome,
              arg: '',
              delta: 200,
              at: _clock.now().subtract(const Duration(days: 120)),
            ),
          ],
        ),
      );

  final Clock _clock;
  final _rng = Random(7);

  bool canRedeem(Reward r) => state.balance >= r.cost;

  void earn(int points, String station) => emit(
    PointsState(
      balance: state.balance + points,
      lifetime: state.lifetime + points,
      movements: [
        PointsMovement(
          kind: MovementKind.charge,
          arg: station,
          delta: points,
          at: _clock.now(),
        ),
        ...state.movements,
      ],
    ),
  );

  void welcome(int points) => emit(
    PointsState(
      balance: state.balance + points,
      lifetime: state.lifetime + points,
      movements: [
        PointsMovement(
          kind: MovementKind.welcome,
          arg: '',
          delta: points,
          at: _clock.now(),
        ),
        ...state.movements,
      ],
    ),
  );

  /// Descuenta los puntos y devuelve el código del canje, o `null` si no alcanza.
  String? redeem(Reward r, String label) {
    if (!canRedeem(r)) return null;
    final code = 'TQ-${1000 + _rng.nextInt(9000)}';
    emit(
      PointsState(
        balance: state.balance - r.cost,
        lifetime: state.lifetime,
        movements: [
          PointsMovement(
            kind: MovementKind.redeem,
            arg: label,
            delta: -r.cost,
            at: _clock.now(),
          ),
          ...state.movements,
        ],
      ),
    );
    return code;
  }
}
