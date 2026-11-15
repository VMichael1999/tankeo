import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/account_models.dart';

class PaymentMethodsState extends Equatable {
  const PaymentMethodsState({required this.methods, required this.defaultId});

  final List<SavedPaymentMethod> methods;
  final String defaultId;

  SavedPaymentMethod get defaultMethod =>
      methods.firstWhere((m) => m.id == defaultId, orElse: () => methods.first);

  @override
  List<Object?> get props => [methods, defaultId];
}

enum RemoveResult { removed, last }

/// Métodos de pago: Yape, Plin y tarjetas. Solo se guarda el token y los
/// últimos 4 dígitos (en producción, tokeniza la pasarela).
class PaymentMethodsCubit extends Cubit<PaymentMethodsState> {
  PaymentMethodsCubit()
    : super(
        const PaymentMethodsState(
          defaultId: 'yape',
          methods: [
            SavedPaymentMethod(id: 'yape', kind: SavedKind.yape, last: '789'),
            SavedPaymentMethod(id: 'plin', kind: SavedKind.plin, last: '789'),
            SavedPaymentMethod(
              id: 'card-4821',
              kind: SavedKind.card,
              last: '4821',
              expiry: '08/28',
              holder: 'MICHAEL DEV',
            ),
          ],
        ),
      );

  void setDefault(String id) =>
      emit(PaymentMethodsState(methods: state.methods, defaultId: id));

  RemoveResult remove(String id) {
    if (state.methods.length <= 1) return RemoveResult.last;
    final left = state.methods.where((m) => m.id != id).toList();
    emit(
      PaymentMethodsState(
        methods: left,
        defaultId: state.defaultId == id ? left.first.id : state.defaultId,
      ),
    );
    return RemoveResult.removed;
  }

  void addCard({
    required String last,
    required String brand,
    required String expiry,
    required String holder,
  }) => emit(
    PaymentMethodsState(
      defaultId: state.defaultId,
      methods: [
        ...state.methods,
        SavedPaymentMethod(
          id: 'card-$last-${state.methods.length}',
          kind: SavedKind.card,
          last: last,
          brand: brand,
          expiry: expiry,
          holder: holder.toUpperCase(),
        ),
      ],
    ),
  );
}
