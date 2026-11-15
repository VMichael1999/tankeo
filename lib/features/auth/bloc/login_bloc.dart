import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../auth_repository.dart';

enum LoginStatus { idle, loading, success }

class LoginState extends Equatable {
  const LoginState({
    this.email = '',
    this.password = '',
    this.obscure = true,
    this.status = LoginStatus.idle,
  });

  final String email;
  final String password;
  final bool obscure;
  final LoginStatus status;

  LoginState copyWith({
    String? email,
    String? password,
    bool? obscure,
    LoginStatus? status,
  }) => LoginState(
    email: email ?? this.email,
    password: password ?? this.password,
    obscure: obscure ?? this.obscure,
    status: status ?? this.status,
  );

  @override
  List<Object?> get props => [email, password, obscure, status];
}

sealed class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

class LoginEmailChanged extends LoginEvent {
  const LoginEmailChanged(this.email);
  final String email;

  @override
  List<Object?> get props => [email];
}

class LoginPasswordChanged extends LoginEvent {
  const LoginPasswordChanged(this.password);
  final String password;

  @override
  List<Object?> get props => [password];
}

class LoginObscureToggled extends LoginEvent {
  const LoginObscureToggled();
}

class LoginSubmitted extends LoginEvent {
  const LoginSubmitted();
}

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc(this._auth) : super(LoginState(email: _auth.currentUser.email)) {
    on<LoginEmailChanged>((e, emit) => emit(state.copyWith(email: e.email)));
    on<LoginPasswordChanged>(
      (e, emit) => emit(state.copyWith(password: e.password)),
    );
    on<LoginObscureToggled>(
      (e, emit) => emit(state.copyWith(obscure: !state.obscure)),
    );
    on<LoginSubmitted>(_onSubmitted);
  }

  final AuthRepository _auth;

  Future<void> _onSubmitted(LoginSubmitted e, Emitter<LoginState> emit) async {
    if (state.status == LoginStatus.loading) return;
    emit(state.copyWith(status: LoginStatus.loading));
    await _auth.signIn(email: state.email, password: state.password);
    emit(state.copyWith(status: LoginStatus.success));
    emit(state.copyWith(status: LoginStatus.idle));
  }
}
