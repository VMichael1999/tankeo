import 'package:flutter/material.dart';

import '../icons/icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'app_modal.dart';
import 'safety_checklist_dialog.dart' show DialogButton;

/// Diálogo de confirmación (canje, cerrar sesión): ícono, título, texto y
/// dos botones. Devuelve `true` si el usuario confirma.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required AppIcon icon,
  required String title,
  required String body,
  required String cancelLabel,
  required String confirmLabel,
  Color tint = AppColors.primary,
  Color tintBg = AppColors.primarySoft,
}) async {
  final r = await showDialog<bool>(
    context: context,
    useRootNavigator: true,
    barrierColor: AppColors.scrim.withValues(alpha: .45),
    builder: (c) => Dialog(
      backgroundColor: AppColors.white.withValues(alpha: 0),
      elevation: 0,
      insetPadding: EdgeInsets.zero,
      child: DialogCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: tintBg,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(child: AppIconView(icon, size: 28, color: tint)),
            ),
            Text(title, style: AppText.ui(19, AppText.w8)),
            const SizedBox(height: 4),
            Text(
              body,
              style: AppText.ui(13.5, AppText.w4, color: AppColors.ink2),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DialogButton(
                    label: cancelLabel,
                    onTap: () => Navigator.of(c).pop(false),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DialogButton(
                    label: confirmLabel,
                    primary: true,
                    color: tint,
                    onTap: () => Navigator.of(c).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  return r ?? false;
}
