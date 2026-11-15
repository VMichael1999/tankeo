import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/account_models.dart';

/// Lista de vehículos del usuario (el primero está «En uso»).
class VehiclesCubit extends Cubit<List<AccountVehicle>> {
  VehiclesCubit()
    : super(const [
        AccountVehicle(
          name: 'McLaren F1',
          year: 1993,
          plate: 'D7K-418',
          fuel: VehicleFuel.dual,
          gasLevel: 38,
          gnvLevel: 25,
          cylinder: 'GNV-2',
          certified: true,
        ),
      ]);

  int inUse = 0;

  void add(AccountVehicle v) => emit([...state, v]);

  void use(int index) {
    inUse = index;
    emit([...state]);
  }
}
