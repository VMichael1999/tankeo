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
import '../../account/bloc/vehicles_cubit.dart';
import '../../account/domain/account_models.dart';
import '../../account/domain/password_strength.dart';
import '../../account/ui/vehicles_screen.dart';
import '../bloc/sign_up_bloc.dart';

/// Crear cuenta (3 o 4 pasos) y «Agregar vehículo» (empieza en el vehículo).
class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return BlocConsumer<SignUpBloc, SignUpState>(
      listenWhen: (a, b) => !a.finished && b.finished,
      listener: (context, s) => goBack(context, '/vehicles'),
      builder: (context, s) {
        final bloc = context.read<SignUpBloc>();
        final steps = s.steps;
        final isDone = s.step == SignUpStep.done;
        final last =
            steps.indexOf(s.step) == steps.length - (s.addMode ? 1 : 2);
        final label = isDone
            ? l.signupStart
            : last
            ? (s.addMode ? l.signupAddFinish : l.continueLabel)
            : l.signupNext;
        final title = switch (s.step) {
          SignUpStep.account => l.signupStepAccount,
          SignUpStep.vehicle =>
            s.addMode ? l.addVehicleTitle : l.signupStepVehicle,
          SignUpStep.gnv => l.signupStepGnv,
          SignUpStep.done => l.signupDoneTitle(s.name.trim().split(' ').first),
        };
        return PopScope(
          canPop: s.step == steps.first || isDone,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop && !isDone) bloc.add(const SignUpBackPressed());
          },
          child: AccountScaffold(
            title: isDone ? l.signupTitle : title,
            onBack: () => s.step == steps.first || isDone
                ? goBack(context, '/login')
                : bloc.add(const SignUpBackPressed()),
            trailing: Text(
              l.signupStepCounter(s.stepIndex, steps.length),
              style: AppText.ui(14, AppText.w7, color: AppColors.ink2),
            ),
            bottom: BottomActionBar(
              child: PrimaryButton(
                label: label,
                color: AppColors.primary,
                spinnerOnly: s.saving,
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  if (isDone) {
                    context.go('/home');
                  } else {
                    bloc.add(const SignUpNextPressed());
                  }
                },
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    for (var i = 0; i < steps.length; i++)
                      Expanded(
                        child: Container(
                          height: 5,
                          margin: EdgeInsets.only(
                            right: i < steps.length - 1 ? 6 : 0,
                          ),
                          decoration: BoxDecoration(
                            color: i < s.stepIndex
                                ? AppColors.primary
                                : AppColors.barTrack,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 22),
                switch (s.step) {
                  SignUpStep.account => _AccountStep(s: s),
                  SignUpStep.vehicle => _VehicleStep(s: s),
                  SignUpStep.gnv => _GnvStep(s: s),
                  SignUpStep.done => const _DoneStep(),
                },
              ],
            ),
          ),
        );
      },
    );
  }
}

void _set(BuildContext c, SignUpField f, Object v) =>
    c.read<SignUpBloc>().add(SignUpFieldChanged(f, v));

class _AccountStep extends StatefulWidget {
  const _AccountStep({required this.s});
  final SignUpState s;

  @override
  State<_AccountStep> createState() => _AccountStepState();
}

class _AccountStepState extends State<_AccountStep> {
  late final _name = TextEditingController(text: widget.s.name);
  late final _email = TextEditingController(text: widget.s.email);
  late final _phone = TextEditingController(text: widget.s.phone);
  late final _pass = TextEditingController(text: widget.s.password);
  bool _obscure = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final s = widget.s;
    final e = s.showErrors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabeledField(
          label: l.signupName,
          controller: _name,
          textCapitalization: TextCapitalization.words,
          error: e && !s.nameOk ? l.errName : null,
          onChanged: (v) => _set(context, SignUpField.name, v),
        ),
        LabeledField(
          label: l.signupEmail,
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          error: e && !s.emailOk ? l.errEmail : null,
          onChanged: (v) => _set(context, SignUpField.email, v),
        ),
        LabeledField(
          label: l.signupPhone,
          controller: _phone,
          keyboardType: TextInputType.phone,
          maxLength: 9,
          formatters: [FilteringTextInputFormatter.digitsOnly],
          error: e && !s.phoneOk ? l.errPhone : null,
          onChanged: (v) => _set(context, SignUpField.phone, v),
        ),
        LabeledField(
          label: l.signupPassword,
          controller: _pass,
          obscure: _obscure,
          error: e && !s.passwordOk ? l.errPassword : null,
          onChanged: (v) => _set(context, SignUpField.password, v),
          suffix: GestureDetector(
            onTap: () => setState(() => _obscure = !_obscure),
            child: Semantics(
              button: true,
              label: _obscure ? l.loginShowPassword : l.loginHidePassword,
              child: AppIconView(
                _obscure ? AppIcon.eye : AppIcon.eyeOff,
                size: 19,
                color: AppColors.ink3,
              ),
            ),
          ),
        ),
        StrengthMeter(score: PasswordStrength.score(s.password)),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _set(context, SignUpField.terms, !s.terms),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: s.terms ? AppColors.primary : AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: s.terms ? AppColors.primary : AppColors.checkBorder,
                    width: 1.6,
                  ),
                ),
                child: s.terms
                    ? const Center(
                        child: AppIconView(
                          AppIcon.check,
                          size: 15,
                          color: AppColors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l.signupTerms,
                  style: AppText.ui(13.5, AppText.w5, color: AppColors.inkBody),
                ),
              ),
            ],
          ),
        ),
        if (e && !s.terms)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 36),
            child: Text(
              l.errTerms,
              style: AppText.ui(12, AppText.w6, color: AppColors.danger),
            ),
          ),
      ],
    );
  }
}

class _VehicleStep extends StatefulWidget {
  const _VehicleStep({required this.s});
  final SignUpState s;

  @override
  State<_VehicleStep> createState() => _VehicleStepState();
}

class _VehicleStepState extends State<_VehicleStep> {
  late final _name = TextEditingController(text: widget.s.vehicleName);
  late final _year = TextEditingController(text: widget.s.year);
  late final _plate = TextEditingController(text: widget.s.plate);

  @override
  void dispose() {
    _name.dispose();
    _year.dispose();
    _plate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final s = widget.s;
    final e = s.showErrors;
    final fuels = <(VehicleFuel, String)>[
      (VehicleFuel.gasoline, l.fuelGasoline),
      (VehicleFuel.gnv, l.fuelGnv),
      (VehicleFuel.dual, l.vehicleFuelDualShort),
    ];
    final tank = s.fuel != VehicleFuel.gnv;
    final cyl = s.hasGnv;
    Widget chips<T>(
      List<T> values,
      T current,
      String Function(T) text,
      ValueChanged<T> on, {
      bool enabled = true,
    }) => Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final v in values)
          ChoiceChipItem<T>(
            label: text(v),
            selected: v == current,
            enabled: enabled,
            onTap: () => on(v),
          ),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabeledField(
          label: l.vehicleName,
          controller: _name,
          textCapitalization: TextCapitalization.words,
          error: e && !s.vehicleNameOk ? l.errVehicleName : null,
          onChanged: (v) => _set(context, SignUpField.vehicleName, v),
        ),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: LabeledField(
                label: l.vehiclePlate,
                controller: _plate,
                textCapitalization: TextCapitalization.characters,
                formatters: [_PlateFormatter()],
                error: e && !s.plateOk ? l.errPlate : null,
                onChanged: (v) => _set(context, SignUpField.plate, v),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LabeledField(
                label: l.vehicleYear,
                controller: _year,
                keyboardType: TextInputType.number,
                maxLength: 4,
                formatters: [FilteringTextInputFormatter.digitsOnly],
                error: e && !s.yearOk ? l.errYear : null,
                onChanged: (v) => _set(context, SignUpField.year, v),
              ),
            ),
          ],
        ),
        SectionLabel(l.vehicleFuelType),
        chips<VehicleFuel>(
          [for (final f in fuels) f.$1],
          s.fuel,
          (f) => fuels.firstWhere((x) => x.$1 == f).$2,
          (f) => _set(context, SignUpField.fuel, f),
        ),
        SectionLabel(l.vehicleTankCapacity),
        chips<int>(
          const [10, 13, 16],
          s.tankCapacity,
          (v) => '$v',
          (v) => _set(context, SignUpField.tankCapacity, v),
          enabled: tank,
        ),
        SectionLabel(l.vehicleCylinderCapacity),
        chips<int>(
          const [8, 12, 16],
          s.cylinderCapacity,
          (v) => '$v',
          (v) => _set(context, SignUpField.cylinderCapacity, v),
          enabled: cyl,
        ),
      ],
    );
  }
}

class _GnvStep extends StatefulWidget {
  const _GnvStep({required this.s});
  final SignUpState s;

  @override
  State<_GnvStep> createState() => _GnvStepState();
}

class _GnvStepState extends State<_GnvStep> {
  late final _chip = TextEditingController(text: widget.s.chip);
  late final _expiry = TextEditingController(text: widget.s.expiry);

  @override
  void dispose() {
    _chip.dispose();
    _expiry.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final s = widget.s;
    final e = s.showErrors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabeledField(
          label: l.gnvChip,
          controller: _chip,
          hint: l.gnvChipHint,
          keyboardType: TextInputType.number,
          formatters: [
            _PatternFormatter(const [4, 4, 2], '-'),
          ],
          error: e && !s.chipOk ? l.errChip : null,
          onChanged: (v) => _set(context, SignUpField.chip, v),
        ),
        LabeledField(
          label: l.gnvExpiry,
          controller: _expiry,
          hint: l.gnvExpiryHint,
          keyboardType: TextInputType.number,
          formatters: [
            _PatternFormatter(const [2, 2, 4], '/'),
          ],
          error: e && s.expiryDate == null ? l.errExpiry : null,
          onChanged: (v) => _set(context, SignUpField.expiry, v),
        ),
        SectionLabel(l.gnvCylinderType),
        Wrap(
          spacing: 8,
          children: [
            for (final c in const ['GNV-1', 'GNV-2', 'GNV-4'])
              ChoiceChipItem<String>(
                label: c,
                selected: s.cylinder == c,
                color: AppColors.gnv,
                onTap: () => _set(context, SignUpField.cylinder, c),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          l.gnvCylinderNote,
          style: AppText.ui(12.5, AppText.w4, color: AppColors.ink2),
        ),
      ],
    );
  }
}

class _DoneStep extends StatelessWidget {
  const _DoneStep();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final vehicles = context.read<VehiclesCubit>().state;
    final v = vehicles.last;
    return Column(
      children: [
        VehicleCard(vehicle: v, inUse: true, onUse: () {}),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const AppIconView(
                AppIcon.gift,
                size: 28,
                color: AppColors.primary,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.signupGift(SignUpBloc.welcomePoints),
                      style: AppText.ui(
                        16,
                        AppText.w8,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      l.signupDoneBody,
                      style: AppText.ui(
                        13,
                        AppText.w4,
                        color: AppColors.inkBody,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue o, TextEditingValue n) {
    final f = normalizePlate(n.text);
    return TextEditingValue(
      text: f,
      selection: TextSelection.collapsed(offset: f.length),
    );
  }
}

/// Inserta [sep] entre grupos de dígitos de tamaños fijos.
class _PatternFormatter extends TextInputFormatter {
  _PatternFormatter(this.groups, this.sep);

  final List<int> groups;
  final String sep;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue o, TextEditingValue n) {
    final d = n.text.replaceAll(RegExp(r'\D'), '');
    final out = <String>[];
    var i = 0;
    for (final g in groups) {
      if (i >= d.length) break;
      out.add(d.substring(i, (i + g).clamp(0, d.length)));
      i += g;
    }
    final f = out.join(sep);
    return TextEditingValue(
      text: f,
      selection: TextSelection.collapsed(offset: f.length),
    );
  }
}
