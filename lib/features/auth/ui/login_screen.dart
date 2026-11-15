import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/icons/icons.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/tankeo_tokens.dart';
import '../../../core/widgets/drop_shadow_image.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/station_illustration.dart';
import '../bloc/login_bloc.dart';

/// Inicio de sesión: cabecera cálida con el surtidor y el McLaren F1, y la hoja
/// con correo, contraseña y accesos sociales.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: BlocListener<LoginBloc, LoginState>(
        listenWhen: (a, b) => a.status != b.status,
        listener: (context, state) {
          if (state.status == LoginStatus.success) context.go('/home');
        },
        child: Scaffold(
          backgroundColor: AppColors.loginBg,
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              const Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: 300,
                child: _Hero(),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 252,
                bottom: 0,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    color: AppColors.loginSheet,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        26,
                        34,
                        26,
                        MediaQuery.viewInsetsOf(context).bottom,
                      ),
                      child: const _LoginForm(),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 46,
                child: IgnorePointer(
                  ignoring: MediaQuery.viewInsetsOf(context).bottom > 0,
                  child: Opacity(
                    opacity: MediaQuery.viewInsetsOf(context).bottom > 0
                        ? 0
                        : 1,
                    child: Center(
                      child: Text.rich(
                        TextSpan(
                          text: '${l.loginNoAccount} ',
                          style: AppText.ui(
                            13.5,
                            AppText.w4,
                            color: AppColors.ink2,
                          ),
                          children: [
                            TextSpan(
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => context.push('/signup'),
                              text: l.loginRegister,
                              style: AppText.ui(
                                13.5,
                                AppText.w7,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: TankeoTokens.loginHero),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 28,
            top: 72,
            child: Row(
              children: [
                const AppIconView(
                  AppIcon.pump,
                  size: 18,
                  color: AppColors.primaryLight,
                  strokeWidth: 2.2,
                ),
                const SizedBox(width: 10),
                Text(
                  context.l10n.appName,
                  style: AppText.ui(
                    18,
                    AppText.w6,
                    color: AppColors.white,
                    letterSpacing: 18 * .3,
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            right: -10,
            top: 92,
            width: 300,
            height: 190,
            child: LoginPumpIllustration(),
          ),
          Positioned(
            right: -34,
            top: 150,
            width: 290,
            height: 128,
            child: Semantics(
              label: context.l10n.carSemantic,
              image: true,
              child: DropShadowImage(
                asset: AppImages.carSide,
                shadowColor: AppColors.black.withValues(alpha: .5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm();

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  late final TextEditingController _email;
  late final TextEditingController _pass;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController(text: context.read<LoginBloc>().state.email);
    _pass = TextEditingController();
  }

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final bloc = context.read<LoginBloc>();
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.loginTitle,
              style: AppText.ui(23, AppText.w8, letterSpacing: -.23),
            ),
            const SizedBox(height: 6),
            Text(
              l.loginSubtitle,
              style: AppText.ui(14.5, AppText.w4, color: AppColors.ink2),
            ),
            const SizedBox(height: 22),
            _Field(
              icon: AppIcon.mail,
              controller: _email,
              hint: l.loginEmailHint,
              keyboardType: TextInputType.emailAddress,
              onChanged: (v) => bloc.add(LoginEmailChanged(v)),
            ),
            _Field(
              icon: AppIcon.lock,
              controller: _pass,
              hint: l.loginPasswordHint,
              obscure: state.obscure,
              onChanged: (v) => bloc.add(LoginPasswordChanged(v)),
              trailing: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => bloc.add(const LoginObscureToggled()),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Semantics(
                    label: state.obscure
                        ? l.loginShowPassword
                        : l.loginHidePassword,
                    child: AppIconView(
                      state.obscure ? AppIcon.eyeOff : AppIcon.eye,
                      size: 20,
                      color: AppColors.ink3,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => context.push('/reset-password'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    l.loginForgot,
                    style: AppText.ui(
                      13.5,
                      AppText.w6,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            PrimaryButton(
              label: l.loginSubmit,
              color: AppColors.primary,
              spinnerOnly: state.status == LoginStatus.loading,
              onPressed: () {
                FocusScope.of(context).unfocus();
                bloc.add(const LoginSubmitted());
              },
            ),
            const SizedBox(height: 26),
            Row(
              children: [
                const Expanded(
                  child: ColoredBox(
                    color: AppColors.grab,
                    child: SizedBox(height: 1),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  l.loginOr,
                  style: AppText.ui(13, AppText.w4, color: AppColors.ink3),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: ColoredBox(
                    color: AppColors.grab,
                    child: SizedBox(height: 1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _Social(
                    label: 'Google',
                    child: Text(
                      'G',
                      style: AppText.ui(
                        17,
                        AppText.w8,
                        color: AppColors.google,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _Social(
                    label: 'Apple',
                    child: SvgPicture.string(_appleSvg, width: 16, height: 19),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _Social(
                    label: 'Facebook',
                    child: Text(
                      'f',
                      style:
                          AppText.ui(
                            17,
                            AppText.w8,
                            color: AppColors.facebook,
                          ).copyWith(
                            fontFamily: 'Georgia',
                            fontFamilyFallback: const ['serif'],
                          ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 90),
          ],
        );
      },
    );
  }

  static const _appleSvg =
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 11 13"><path d="M5.5 3c1-1.6 2.4-1.8 2.4-1.8M2.2 4.4c1.6-1 2.4 0 3.3 0s1.7-1 3.3 0c.9.5 1.3 1.4 1.4 2.1c-1.2.5-1.7 2.6-.1 3.6c-.6 1.4-1.6 2.9-2.6 2.9s-1.2-.6-2-.6s-1.2.6-2 .6c-1.4 0-3.3-3-3.1-5.6c.1-1.5.8-2.6 1.8-3z" fill="#111" stroke="#111" stroke-width=".6"/></svg>';
}

class _Field extends StatefulWidget {
  const _Field({
    required this.icon,
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.obscure = false,
    this.trailing,
    this.keyboardType,
  });

  final AppIcon icon;
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final bool obscure;
  final Widget? trailing;
  final TextInputType? keyboardType;

  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      margin: const EdgeInsets.only(bottom: 14),
      padding: EdgeInsets.only(
        left: 18,
        right: widget.trailing == null ? 18 : 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.field,
        border: Border.all(
          color: _focus.hasFocus
              ? AppColors.primaryBorder
              : AppColors.white.withValues(alpha: 0),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          AppIconView(widget.icon, size: 21, color: AppColors.inkField),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focus,
              obscureText: widget.obscure,
              keyboardType: widget.keyboardType,
              autocorrect: false,
              enableSuggestions: false,
              onChanged: widget.onChanged,
              cursorColor: AppColors.primary,
              style: AppText.ui(15.5, AppText.w5),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: widget.hint,
                hintStyle: AppText.ui(15.5, AppText.w5, color: AppColors.ink3),
              ),
            ),
          ),
          if (widget.trailing != null) widget.trailing!,
        ],
      ),
    );
  }
}

class _Social extends StatelessWidget {
  const _Social({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    child: Container(
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.field,
      ),
      child: child,
    ),
  );
}
