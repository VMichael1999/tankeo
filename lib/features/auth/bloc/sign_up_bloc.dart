import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../account/bloc/points_cubit.dart';
import '../../account/bloc/vehicles_cubit.dart';
import '../../account/domain/account_models.dart';
import '../../account/domain/password_strength.dart';
import '../auth_repository.dart';
import '../user_profile.dart';

enum SignUpStep { account, vehicle, gnv, done }

enum SignUpField {
  name,
  email,
  phone,
  password,
  terms,
  vehicleName,
  year,
  plate,
  fuel,
  tankCapacity,
  cylinderCapacity,
  chip,
  expiry,
  cylinder,
}

/// Normaliza la placa a `ABC-123`.
String normalizePlate(String raw) {
  final d = raw.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
  if (d.length <= 3) return d;
  return '${d.substring(0, 3)}-${d.substring(3, d.length.clamp(3, 6))}';
}

class SignUpState extends Equatable {
  const SignUpState({
    required this.step,
    this.addMode = false,
    this.name = '',
    this.email = '',
    this.phone = '',
    this.password = '',
    this.terms = false,
    this.vehicleName = '',
    this.year = '',
    this.plate = '',
    this.fuel = VehicleFuel.dual,
    this.tankCapacity = 13,
    this.cylinderCapacity = 12,
    this.chip = '',
    this.expiry = '',
    this.cylinder = 'GNV-2',
    this.showErrors = false,
    this.saving = false,
    this.finished = false,
  });

  final SignUpStep step;
  final bool addMode;
  final String name;
  final String email;
  final String phone;
  final String password;
  final bool terms;
  final String vehicleName;
  final String year;
  final String plate;
  final VehicleFuel fuel;
  final int tankCapacity;
  final int cylinderCapacity;
  final String chip;
  final String expiry;
  final String cylinder;
  final bool showErrors;
  final bool saving;

  /// El flujo terminó (agregar vehículo: vuelve a la lista).
  final bool finished;

  bool get hasGnv => fuel != VehicleFuel.gasoline;

  // Validaciones.
  bool get nameOk =>
      name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length >= 2;
  bool get emailOk =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$').hasMatch(email.trim());
  bool get phoneOk => RegExp(r'^9\d{8}$').hasMatch(phone);
  bool get passwordOk => PasswordStrength.isAcceptable(password);
  bool get accountOk => nameOk && emailOk && phoneOk && passwordOk && terms;

  bool get vehicleNameOk => vehicleName.trim().length >= 3;
  bool get yearOk {
    final y = int.tryParse(year);
    return y != null && y >= 1990 && y <= 2027;
  }

  bool get plateOk => RegExp(r'^[A-Z0-9]{3}-\d{3}$').hasMatch(plate);
  bool get vehicleOk => vehicleNameOk && yearOk && plateOk;

  bool get chipOk => RegExp(r'^\d{4}-\d{4}-\d{2}$').hasMatch(chip);
  DateTime? get expiryDate {
    final m = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(expiry);
    if (m == null) return null;
    final d = int.parse(m.group(1)!);
    final mo = int.parse(m.group(2)!);
    final y = int.parse(m.group(3)!);
    final date = DateTime(y, mo, d);
    return date.day == d && date.month == mo && y >= 2000 ? date : null;
  }

  bool get gnvOk => chipOk && expiryDate != null;

  bool stepOk(SignUpStep s) => switch (s) {
    SignUpStep.account => accountOk,
    SignUpStep.vehicle => vehicleOk,
    SignUpStep.gnv => gnvOk,
    SignUpStep.done => true,
  };

  /// Pasos del recorrido (la barra tiene tantos segmentos como pasos).
  List<SignUpStep> get steps => [
    if (!addMode) SignUpStep.account,
    SignUpStep.vehicle,
    if (hasGnv) SignUpStep.gnv,
    if (!addMode) SignUpStep.done,
  ];

  int get stepIndex => steps.indexOf(step) + 1;

  SignUpState copyWith({
    SignUpStep? step,
    String? name,
    String? email,
    String? phone,
    String? password,
    bool? terms,
    String? vehicleName,
    String? year,
    String? plate,
    VehicleFuel? fuel,
    int? tankCapacity,
    int? cylinderCapacity,
    String? chip,
    String? expiry,
    String? cylinder,
    bool? showErrors,
    bool? saving,
    bool? finished,
  }) => SignUpState(
    step: step ?? this.step,
    addMode: addMode,
    name: name ?? this.name,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    password: password ?? this.password,
    terms: terms ?? this.terms,
    vehicleName: vehicleName ?? this.vehicleName,
    year: year ?? this.year,
    plate: plate ?? this.plate,
    fuel: fuel ?? this.fuel,
    tankCapacity: tankCapacity ?? this.tankCapacity,
    cylinderCapacity: cylinderCapacity ?? this.cylinderCapacity,
    chip: chip ?? this.chip,
    expiry: expiry ?? this.expiry,
    cylinder: cylinder ?? this.cylinder,
    showErrors: showErrors ?? this.showErrors,
    saving: saving ?? this.saving,
    finished: finished ?? this.finished,
  );

  AccountVehicle toVehicle() => AccountVehicle(
    name: vehicleName.trim(),
    year: int.parse(year),
    plate: plate,
    fuel: fuel,
    gasLevel: 50,
    gnvLevel: 50,
    cylinder: hasGnv ? cylinder : null,
    certified: hasGnv,
  );

  @override
  List<Object?> get props => [
    step,
    addMode,
    name,
    email,
    phone,
    password,
    terms,
    vehicleName,
    year,
    plate,
    fuel,
    tankCapacity,
    cylinderCapacity,
    chip,
    expiry,
    cylinder,
    showErrors,
    saving,
    finished,
  ];
}

sealed class SignUpEvent extends Equatable {
  const SignUpEvent();
  @override
  List<Object?> get props => [];
}

class SignUpFieldChanged extends SignUpEvent {
  const SignUpFieldChanged(this.field, this.value);
  final SignUpField field;
  final Object value;
  @override
  List<Object?> get props => [field, value];
}

class SignUpNextPressed extends SignUpEvent {
  const SignUpNextPressed();
}

class SignUpBackPressed extends SignUpEvent {
  const SignUpBackPressed();
}

/// Registro de cuenta y, en «Agregar vehículo», de un auto nuevo.
class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  SignUpBloc({
    required AuthRepository auth,
    required VehiclesCubit vehicles,
    required PointsCubit points,
    bool addMode = false,
  }) : _auth = auth,
       _vehicles = vehicles,
       _points = points,
       super(
         SignUpState(
           step: addMode ? SignUpStep.vehicle : SignUpStep.account,
           addMode: addMode,
         ),
       ) {
    on<SignUpFieldChanged>(_onField);
    on<SignUpNextPressed>(_onNext);
    on<SignUpBackPressed>(_onBack);
  }

  static const welcomePoints = 200;

  final AuthRepository _auth;
  final VehiclesCubit _vehicles;
  final PointsCubit _points;

  void _onField(SignUpFieldChanged e, Emitter<SignUpState> emit) {
    final v = e.value;
    emit(switch (e.field) {
      SignUpField.name => state.copyWith(name: v as String),
      SignUpField.email => state.copyWith(email: v as String),
      SignUpField.phone => state.copyWith(phone: v as String),
      SignUpField.password => state.copyWith(password: v as String),
      SignUpField.terms => state.copyWith(terms: v as bool),
      SignUpField.vehicleName => state.copyWith(vehicleName: v as String),
      SignUpField.year => state.copyWith(year: v as String),
      SignUpField.plate => state.copyWith(plate: normalizePlate(v as String)),
      SignUpField.fuel => state.copyWith(fuel: v as VehicleFuel),
      SignUpField.tankCapacity => state.copyWith(tankCapacity: v as int),
      SignUpField.cylinderCapacity => state.copyWith(
        cylinderCapacity: v as int,
      ),
      SignUpField.chip => state.copyWith(chip: v as String),
      SignUpField.expiry => state.copyWith(expiry: v as String),
      SignUpField.cylinder => state.copyWith(cylinder: v as String),
    });
  }

  Future<void> _onNext(SignUpNextPressed e, Emitter<SignUpState> emit) async {
    if (state.saving) return;
    if (!state.stepOk(state.step)) {
      emit(state.copyWith(showErrors: true));
      return;
    }
    final steps = state.steps;
    final next = steps.indexOf(state.step) + 1;
    if (state.step == SignUpStep.done) return;
    if (next < steps.length && steps[next] != SignUpStep.done) {
      emit(state.copyWith(step: steps[next], showErrors: false));
      return;
    }
    // Último paso de datos: crear cuenta (o solo agregar el vehículo).
    emit(state.copyWith(saving: true));
    if (state.addMode) {
      _vehicles.add(state.toVehicle());
      emit(state.copyWith(saving: false, finished: true));
      return;
    }
    await _auth.register(
      UserProfile(name: state.name.trim(), email: state.email.trim()),
    );
    _vehicles
      ..add(state.toVehicle())
      ..use(_vehicles.state.length);
    _points.welcome(welcomePoints);
    emit(state.copyWith(saving: false, step: SignUpStep.done));
  }

  void _onBack(SignUpBackPressed e, Emitter<SignUpState> emit) {
    final steps = state.steps;
    final i = steps.indexOf(state.step);
    if (i > 0 && state.step != SignUpStep.done) {
      emit(state.copyWith(step: steps[i - 1], showErrors: false));
    }
  }
}
