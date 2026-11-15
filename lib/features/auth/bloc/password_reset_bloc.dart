import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/toast/toast_service.dart';
import '../../account/domain/password_strength.dart';

enum ResetStep { email, code, newPassword }

class PasswordResetState extends Equatable {
  const PasswordResetState({
    this.step = ResetStep.email,
    this.email = '',
    this.code = '',
    this.attemptsLeft = 3,
    this.shake = 0,
    this.wrongCode = false,
    this.resendIn = 0,
    this.password = '',
    this.repeat = '',
    this.showErrors = false,
    this.completed = false,
  });

  final ResetStep step;
  final String email;
  final String code;
  final int attemptsLeft;

  /// Contador que sube con cada código incorrecto (dispara el temblor).
  final int shake;
  final bool wrongCode;
  final int resendIn;
  final String password;
  final String repeat;
  final bool showErrors;
  final bool completed;

  bool get emailOk =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$').hasMatch(email.trim());
  bool get passwordOk => PasswordStrength.isAcceptable(password);
  bool get matches => password == repeat;

  PasswordResetState copyWith({
    ResetStep? step,
    String? email,
    String? code,
    int? attemptsLeft,
    int? shake,
    bool? wrongCode,
    int? resendIn,
    String? password,
    String? repeat,
    bool? showErrors,
    bool? completed,
  }) => PasswordResetState(
    step: step ?? this.step,
    email: email ?? this.email,
    code: code ?? this.code,
    attemptsLeft: attemptsLeft ?? this.attemptsLeft,
    shake: shake ?? this.shake,
    wrongCode: wrongCode ?? this.wrongCode,
    resendIn: resendIn ?? this.resendIn,
    password: password ?? this.password,
    repeat: repeat ?? this.repeat,
    showErrors: showErrors ?? this.showErrors,
    completed: completed ?? this.completed,
  );

  @override
  List<Object?> get props => [
    step,
    email,
    code,
    attemptsLeft,
    shake,
    wrongCode,
    resendIn,
    password,
    repeat,
    showErrors,
    completed,
  ];
}

sealed class PasswordResetEvent extends Equatable {
  const PasswordResetEvent();
  @override
  List<Object?> get props => [];
}

class ResetEmailChanged extends PasswordResetEvent {
  const ResetEmailChanged(this.value);
  final String value;
  @override
  List<Object?> get props => [value];
}

class ResetCodeRequested extends PasswordResetEvent {
  const ResetCodeRequested();
}

class ResetCodeChanged extends PasswordResetEvent {
  const ResetCodeChanged(this.value);
  final String value;
  @override
  List<Object?> get props => [value];
}

class ResetCodeSubmitted extends PasswordResetEvent {
  const ResetCodeSubmitted();
}

class ResetResendPressed extends PasswordResetEvent {
  const ResetResendPressed();
}

class ResetTicked extends PasswordResetEvent {
  const ResetTicked();
}

class ResetPasswordChanged extends PasswordResetEvent {
  const ResetPasswordChanged(this.password, this.repeat);
  final String password;
  final String repeat;
  @override
  List<Object?> get props => [password, repeat];
}

class ResetSubmitted extends PasswordResetEvent {
  const ResetSubmitted();
}

/// Recuperar contraseña: correo → código de 4 dígitos → contraseña nueva.
/// En la demo el código `0000` siempre falla.
class PasswordResetBloc extends Bloc<PasswordResetEvent, PasswordResetState> {
  PasswordResetBloc({required ToastService toast})
    : _toast = toast,
      super(const PasswordResetState()) {
    on<ResetEmailChanged>((e, emit) => emit(state.copyWith(email: e.value)));
    on<ResetCodeRequested>(_onRequested);
    on<ResetCodeChanged>(
      (e, emit) => emit(state.copyWith(code: e.value, wrongCode: false)),
    );
    on<ResetCodeSubmitted>(_onSubmitCode);
    on<ResetResendPressed>(_onResend);
    on<ResetTicked>(_onTick);
    on<ResetPasswordChanged>(
      (e, emit) => emit(state.copyWith(password: e.password, repeat: e.repeat)),
    );
    on<ResetSubmitted>(_onSubmit);
  }

  static const resendSeconds = 30;
  static const codeLength = 4;

  final ToastService _toast;
  Timer? _timer;

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => add(const ResetTicked()),
    );
  }

  void _onRequested(ResetCodeRequested e, Emitter<PasswordResetState> emit) {
    if (!state.emailOk) {
      emit(state.copyWith(showErrors: true));
      return;
    }
    emit(
      state.copyWith(
        step: ResetStep.code,
        resendIn: resendSeconds,
        showErrors: false,
        code: '',
        attemptsLeft: 3,
      ),
    );
    _startTimer();
  }

  void _onSubmitCode(ResetCodeSubmitted e, Emitter<PasswordResetState> emit) {
    if (state.code.length < codeLength || state.attemptsLeft <= 0) return;
    if (state.code == '0000') {
      emit(
        state.copyWith(
          attemptsLeft: state.attemptsLeft - 1,
          shake: state.shake + 1,
          wrongCode: true,
          code: '',
        ),
      );
      return;
    }
    _timer?.cancel();
    emit(state.copyWith(step: ResetStep.newPassword, showErrors: false));
  }

  void _onResend(ResetResendPressed e, Emitter<PasswordResetState> emit) {
    if (state.resendIn > 0) return;
    _toast.show(AppToast.codeSent);
    emit(
      state.copyWith(
        resendIn: resendSeconds,
        attemptsLeft: 3,
        code: '',
        wrongCode: false,
      ),
    );
    _startTimer();
  }

  void _onTick(ResetTicked e, Emitter<PasswordResetState> emit) {
    if (state.resendIn <= 1) _timer?.cancel();
    emit(state.copyWith(resendIn: (state.resendIn - 1).clamp(0, 99)));
  }

  void _onSubmit(ResetSubmitted e, Emitter<PasswordResetState> emit) {
    if (!state.passwordOk || !state.matches) {
      emit(state.copyWith(showErrors: true));
      return;
    }
    _toast.show(AppToast.passwordUpdated);
    emit(state.copyWith(completed: true));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
