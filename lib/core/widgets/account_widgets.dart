import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../icons/icons.dart';
import '../l10n/l10n.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../theme/app_text.dart';
import 'app_card.dart';
import 'app_switch.dart';
import 'circle_icon_button.dart';

/// Vuelve a la pantalla de origen (`pop`) o, si no hay, a [fallback].
void goBack(BuildContext context, [String fallback = '/home']) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(fallback);
  }
}

/// Marco de las pantallas de cuenta: barra superior con flecha y título.
class AccountScaffold extends StatelessWidget {
  const AccountScaffold({
    super.key,
    required this.title,
    required this.body,
    this.onBack,
    this.trailing,
    this.bottom,
    this.padding = const EdgeInsets.fromLTRB(20, 8, 20, 40),
    this.background = AppColors.bg,
  });

  final String title;
  final Widget body;
  final VoidCallback? onBack;
  final Widget? trailing;
  final Widget? bottom;
  final EdgeInsetsGeometry padding;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
              child: Row(
                children: [
                  CircleIconButton(
                    icon: AppIcon.back,
                    semanticLabel: context.l10n.back,
                    onPressed: onBack ?? () => goBack(context),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.ui(21, AppText.w8),
                    ),
                  ),
                  ?trailing,
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(padding: padding, child: body),
          ),
          ?bottom,
        ],
      ),
    );
  }
}

/// Hoja inferior estándar (fondo `#F6F7F9`, radio 30, agarre 42 × 5).
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: AppColors.loginSheet,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    builder: (c) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(c).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.grab,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            builder(c),
          ],
        ),
      ),
    ),
  );
}

/// Título de sección (12.5/700, gris).
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
    child: Text(
      text.toUpperCase(),
      style: AppText.ui(
        12,
        AppText.w7,
        color: AppColors.ink2,
        letterSpacing: .6,
      ),
    ),
  );
}

/// Tarjeta con filas separadas por una línea.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.symmetric(horizontal: 14),
    child: Column(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const Divider(height: 1, color: AppColors.line),
          children[i],
        ],
      ],
    ),
  );
}

/// Fila de 40 px con ícono en cuadro suave, título y acción (flecha o interruptor).
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.value,
    this.onTap,
    this.switchValue,
    this.onSwitch,
    this.tint = AppColors.primary,
    this.tintBg = AppColors.primarySoft,
    this.titleColor = AppColors.ink,
    this.showChevron = true,
  });

  final AppIcon icon;
  final String title;
  final String? subtitle;
  final String? value;
  final VoidCallback? onTap;
  final bool? switchValue;
  final ValueChanged<bool>? onSwitch;
  final Color tint;
  final Color tintBg;
  final Color titleColor;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: title,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap:
            onTap ?? (onSwitch == null ? null : () => onSwitch!(!switchValue!)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: tintBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: AppIconView(icon, size: 19, color: tint)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppText.ui(15, AppText.w6, color: titleColor),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: AppText.ui(
                          12.5,
                          AppText.w4,
                          color: AppColors.ink2,
                        ),
                      ),
                  ],
                ),
              ),
              if (value != null)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Text(
                    value!,
                    style: AppText.ui(13, AppText.w6, color: AppColors.ink2),
                  ),
                ),
              if (switchValue != null)
                AppSwitch(value: switchValue!, onChanged: onSwitch ?? (_) {})
              else if (showChevron && onTap != null)
                const AppIconView(
                  AppIcon.chev,
                  size: 18,
                  color: AppColors.ink3,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Campo de texto con etiqueta y mensaje de error.
class LabeledField extends StatelessWidget {
  const LabeledField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.error,
    this.obscure = false,
    this.keyboardType,
    this.formatters,
    this.onChanged,
    this.suffix,
    this.textCapitalization = TextCapitalization.none,
    this.enabled = true,
    this.maxLength,
    this.autofocus = false,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? error;
  final bool obscure;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? formatters;
  final ValueChanged<String>? onChanged;
  final Widget? suffix;
  final TextCapitalization textCapitalization;
  final bool enabled;
  final int? maxLength;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              label,
              style: AppText.ui(12.5, AppText.w6, color: AppColors.ink2),
            ),
          ),
          Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: error != null ? AppColors.danger : AppColors.white,
                width: 1.4,
              ),
              boxShadow: AppShadows.field,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    enabled: enabled,
                    obscureText: obscure,
                    keyboardType: keyboardType,
                    inputFormatters: [
                      ...?formatters,
                      if (maxLength != null)
                        LengthLimitingTextInputFormatter(maxLength),
                    ],
                    textCapitalization: textCapitalization,
                    autofocus: autofocus,
                    onChanged: onChanged,
                    cursorColor: AppColors.primary,
                    style: AppText.ui(15.5, AppText.w6),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: hint,
                      hintStyle: AppText.ui(
                        15.5,
                        AppText.w4,
                        color: AppColors.ink3,
                      ),
                    ),
                  ),
                ),
                ?suffix,
              ],
            ),
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 5),
              child: Text(
                error!,
                style: AppText.ui(12, AppText.w6, color: AppColors.danger),
              ),
            ),
        ],
      ),
    );
  }
}

/// Opción de una fila de chips (combustible, cilindro, hora…).
class ChoiceChipItem<T> extends StatelessWidget {
  const ChoiceChipItem({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.enabled = true,
    this.color = AppColors.ink,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool enabled;
  final Color color;

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: enabled ? 1 : .35,
    child: Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? color : AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selected ? color : AppColors.chipBorder),
          ),
          child: Text(
            label,
            style: AppText.ui(
              14,
              AppText.w6,
              color: selected ? AppColors.white : AppColors.ink,
            ),
          ),
        ),
      ),
    ),
  );
}

/// Medidor de seguridad de la contraseña: rojo, ámbar o verde.
class StrengthMeter extends StatelessWidget {
  const StrengthMeter({super.key, required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final color = switch (score) {
      <= 1 => AppColors.danger,
      2 => AppColors.warning,
      _ => AppColors.success,
    };
    final label = switch (score) {
      0 => '',
      1 => l.strengthWeak,
      2 => l.strengthMedium,
      _ => l.strengthStrong,
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          for (var i = 0; i < 3; i++)
            Expanded(
              child: Container(
                height: 5,
                margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                decoration: BoxDecoration(
                  color: i < score ? color : AppColors.barTrack,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          SizedBox(
            width: 56,
            child: Text(
              label,
              textAlign: TextAlign.right,
              style: AppText.ui(12, AppText.w7, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

/// Botón fijo inferior con degradado hacia el fondo.
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.bg.withValues(alpha: 0), AppColors.bg],
        stops: const [0, .35],
      ),
    ),
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        18,
        20,
        MediaQuery.paddingOf(context).bottom + 18,
      ),
      child: child,
    ),
  );
}
