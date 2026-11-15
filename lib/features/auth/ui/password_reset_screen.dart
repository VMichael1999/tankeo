import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/icons/icons.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/account_widgets.dart';
import '../../../core/widgets/primary_button.dart';
import '../../account/domain/password_strength.dart';
import '../bloc/password_reset_bloc.dart';

/// Recuperar contraseña: correo → código → contraseña nueva.
class PasswordResetScreen extends StatelessWidget {
  const PasswordResetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return BlocConsumer<PasswordResetBloc, PasswordResetState>(
      listenWhen: (a, b) => !a.completed && b.completed,
      listener: (context, s) => context.go('/login'),
      builder: (context, s) {
        final bloc = context.read<PasswordResetBloc>();
        final (icon, title, body, label, action) = switch (s.step) {
          ResetStep.email => (
            AppIcon.mail,
            l.resetTitle,
            l.resetEmailBody,
            l.resetSend,
            () => bloc.add(const ResetCodeRequested()),
          ),
          ResetStep.code => (
            AppIcon.lock,
            l.resetCodeTitle,
            l.resetCodeBody(s.email.trim()),
            l.resetVerify,
            () => bloc.add(const ResetCodeSubmitted()),
          ),
          ResetStep.newPassword => (
            AppIcon.key,
            l.resetNewTitle,
            l.resetNewBody,
            l.resetUpdate,
            () => bloc.add(const ResetSubmitted()),
          ),
        };
        return AccountScaffold(
          title: '',
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
          bottom: BottomActionBar(
            child: PrimaryButton(
              label: label,
              color: AppColors.primary,
              onPressed: () {
                FocusScope.of(context).unfocus();
                action();
              },
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Center(
                  child: AppIconView(icon, size: 32, color: AppColors.white),
                ),
              ),
              const SizedBox(height: 18),
              Text(title, style: AppText.ui(24, AppText.w8)),
              const SizedBox(height: 6),
              Text(
                body,
                style: AppText.ui(14.5, AppText.w4, color: AppColors.ink2),
              ),
              const SizedBox(height: 24),
              switch (s.step) {
                ResetStep.email => _EmailField(s: s),
                ResetStep.code => _CodeStep(s: s),
                ResetStep.newPassword => _NewPassword(s: s),
              },
            ],
          ),
        );
      },
    );
  }
}

class _EmailField extends StatefulWidget {
  const _EmailField({required this.s});
  final PasswordResetState s;

  @override
  State<_EmailField> createState() => _EmailFieldState();
}

class _EmailFieldState extends State<_EmailField> {
  late final _c = TextEditingController(text: widget.s.email);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final s = widget.s;
    return LabeledField(
      label: l.signupEmail,
      controller: _c,
      keyboardType: TextInputType.emailAddress,
      autofocus: true,
      error: s.showErrors && !s.emailOk ? l.errEmail : null,
      onChanged: (v) =>
          context.read<PasswordResetBloc>().add(ResetEmailChanged(v)),
    );
  }
}

class _CodeStep extends StatefulWidget {
  const _CodeStep({required this.s});
  final PasswordResetState s;

  @override
  State<_CodeStep> createState() => _CodeStepState();
}

class _CodeStepState extends State<_CodeStep>
    with SingleTickerProviderStateMixin {
  static const n = PasswordResetBloc.codeLength;
  final _ctrls = List.generate(n, (_) => TextEditingController());
  final _nodes = List.generate(n, (_) => FocusNode());
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  @override
  void didUpdateWidget(_CodeStep old) {
    super.didUpdateWidget(old);
    if (widget.s.shake != old.s.shake) {
      for (final c in _ctrls) {
        c.clear();
      }
      _nodes.first.requestFocus();
      _shake.forward(from: 0);
      HapticFeedback.mediumImpact();
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls) {
      c.dispose();
    }
    for (final f in _nodes) {
      f.dispose();
    }
    _shake.dispose();
    super.dispose();
  }

  void _changed(int i, String v) {
    if (v.isNotEmpty && i < n - 1) _nodes[i + 1].requestFocus();
    if (v.isNotEmpty && i == n - 1) _nodes[i].unfocus();
    context.read<PasswordResetBloc>().add(
      ResetCodeChanged(_ctrls.map((c) => c.text).join()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final s = widget.s;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedBuilder(
          animation: _shake,
          builder: (context, child) => Transform.translate(
            offset: Offset(
              math.sin(_shake.value * math.pi * 6) * 10 * (1 - _shake.value),
              0,
            ),
            child: child,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < n; i++)
                SizedBox(
                  width: 64,
                  height: 70,
                  child: Focus(
                    onKeyEvent: (node, e) {
                      if (e is KeyDownEvent &&
                          e.logicalKey == LogicalKeyboardKey.backspace &&
                          _ctrls[i].text.isEmpty &&
                          i > 0) {
                        _ctrls[i - 1].clear();
                        _nodes[i - 1].requestFocus();
                        context.read<PasswordResetBloc>().add(
                          ResetCodeChanged(_ctrls.map((c) => c.text).join()),
                        );
                        return KeyEventResult.handled;
                      }
                      return KeyEventResult.ignored;
                    },
                    child: TextField(
                      controller: _ctrls[i],
                      focusNode: _nodes[i],
                      autofocus: i == 0,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(1),
                      ],
                      cursorColor: AppColors.primary,
                      style: AppText.ui(28, AppText.w8),
                      onChanged: (v) => _changed(i, v),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.white,
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(
                            color: s.wrongCode
                                ? AppColors.danger
                                : AppColors.chipBorder,
                            width: 1.6,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (s.wrongCode)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              s.attemptsLeft > 0
                  ? l.resetWrongCode(s.attemptsLeft)
                  : l.resetNoAttempts,
              style: AppText.ui(13, AppText.w6, color: AppColors.danger),
            ),
          ),
        const SizedBox(height: 18),
        Center(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => context.read<PasswordResetBloc>().add(
              const ResetResendPressed(),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                s.resendIn > 0 ? l.resetResendIn(s.resendIn) : l.resetResend,
                style: AppText.ui(
                  14.5,
                  AppText.w7,
                  color: s.resendIn > 0 ? AppColors.ink3 : AppColors.primary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NewPassword extends StatefulWidget {
  const _NewPassword({required this.s});
  final PasswordResetState s;

  @override
  State<_NewPassword> createState() => _NewPasswordState();
}

class _NewPasswordState extends State<_NewPassword> {
  final _a = TextEditingController();
  final _b = TextEditingController();

  @override
  void dispose() {
    _a.dispose();
    _b.dispose();
    super.dispose();
  }

  void _emit() => context.read<PasswordResetBloc>().add(
    ResetPasswordChanged(_a.text, _b.text),
  );

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final s = widget.s;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabeledField(
          label: l.resetNewPassword,
          controller: _a,
          obscure: true,
          autofocus: true,
          error: s.showErrors && !s.passwordOk ? l.errPassword : null,
          onChanged: (_) => _emit(),
        ),
        StrengthMeter(score: PasswordStrength.score(s.password)),
        LabeledField(
          label: l.resetRepeatPassword,
          controller: _b,
          obscure: true,
          error: s.showErrors && !s.matches ? l.resetMismatch : null,
          onChanged: (_) => _emit(),
        ),
      ],
    );
  }
}
