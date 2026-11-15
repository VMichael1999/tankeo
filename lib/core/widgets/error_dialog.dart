import 'package:flutter/material.dart';

import '../icons/icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'app_modal.dart';
import 'safety_checklist_dialog.dart' show DialogButton;

/// Diálogo único de error: ícono de alerta (rojo o ámbar), título, texto con
/// partes en negrita y dos botones. Se coloca dentro de un [Stack].
class ErrorDialog extends StatelessWidget {
  const ErrorDialog({
    super.key,
    required this.visible,
    required this.title,
    required this.body,
    required this.secondaryLabel,
    required this.primaryLabel,
    required this.onSecondary,
    required this.onPrimary,
    this.warning = false,
  });

  final bool visible;
  final String title;

  /// Texto del cuerpo; usa [TextSpan] para poner el monto o la fecha en negrita.
  final List<InlineSpan> body;
  final String secondaryLabel;
  final String primaryLabel;
  final VoidCallback onSecondary;
  final VoidCallback onPrimary;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final fg = warning ? AppColors.warning : AppColors.danger;
    final bg = warning ? AppColors.warningSoft : AppColors.dangerSoft;
    return AppModal(
      visible: visible,
      child: DialogCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: AppIconView(AppIcon.alert, size: 30, color: fg),
              ),
            ),
            Text(
              title,
              style: AppText.ui(19, AppText.w8),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 3),
            Text.rich(
              TextSpan(
                children: body,
                style: AppText.ui(13.5, AppText.w4, color: AppColors.ink2),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: DialogButton(
                    label: secondaryLabel,
                    onTap: onSecondary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DialogButton(
                    label: primaryLabel,
                    primary: true,
                    onTap: onPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Fragmento en negrita para el cuerpo.
  static TextSpan bold(String text) => TextSpan(
    text: text,
    style: AppText.ui(13.5, AppText.w7, color: AppColors.ink),
  );
}
