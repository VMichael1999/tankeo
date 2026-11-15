import 'package:flutter/material.dart';

import '../icons/icons.dart';
import '../l10n/l10n.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'app_modal.dart';

/// «Antes de cargar GNV»: escudo, tres casillas y los botones Cancelar e
/// Iniciar carga (teal, solo con las tres marcadas).
class SafetyChecklistDialog extends StatelessWidget {
  const SafetyChecklistDialog({
    super.key,
    required this.visible,
    required this.checked,
    required this.onToggle,
    required this.onCancel,
    required this.onConfirm,
  });

  final bool visible;
  final List<bool> checked;
  final ValueChanged<int> onToggle;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final items = <(AppIcon, String)>[
      (AppIcon.exit, l.safetyPassengersOut),
      (AppIcon.key, l.safetyEngineOff),
      (AppIcon.noSmoke, l.safetyNoSmoking),
    ];
    final all = checked.every((c) => c);
    return AppModal(
      visible: visible,
      child: DialogCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.gnvSoft,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: AppIconView(
                  AppIcon.shield,
                  size: 28,
                  color: AppColors.gnv,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(l.safetyTitle, style: AppText.ui(19, AppText.w8)),
            const SizedBox(height: 3),
            Text(
              l.safetySubtitle,
              style: AppText.ui(13.5, AppText.w4, color: AppColors.ink2),
            ),
            const SizedBox(height: 14),
            for (final (i, it) in items.indexed)
              Semantics(
                inMutuallyExclusiveGroup: false,
                checked: checked[i],
                label: it.$2,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onToggle(i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 11,
                      horizontal: 4,
                    ),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: AppColors.line)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.gnvSoft,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Center(
                            child: AppIconView(
                              it.$1,
                              size: 18,
                              color: AppColors.gnv,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            it.$2,
                            textAlign: TextAlign.left,
                            style: AppText.ui(14, AppText.w5),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: checked[i]
                                ? AppColors.gnv
                                : AppColors.white.withValues(alpha: 0),
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(
                              color: checked[i]
                                  ? AppColors.gnv
                                  : AppColors.checkBorder,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Opacity(
                              opacity: checked[i] ? 1 : 0,
                              child: const AppIconView(
                                AppIcon.check,
                                size: 14,
                                color: AppColors.white,
                                strokeWidth: 3.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: DialogButton(label: l.cancel, onTap: onCancel),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DialogButton(
                    label: l.safetyStart,
                    onTap: all ? onConfirm : null,
                    primary: true,
                    color: AppColors.gnv,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Botón de 52 de alto de los diálogos: gris (secundario) o de color.
class DialogButton extends StatelessWidget {
  const DialogButton({
    super.key,
    required this.label,
    required this.onTap,
    this.primary = false,
    this.color,
  });

  final String label;
  final VoidCallback? onTap;
  final bool primary;
  final Color? color;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: onTap != null,
    label: label,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? .4 : 1,
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: primary ? (color ?? AppColors.primary) : AppColors.grayChip,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            label,
            style: AppText.ui(
              15.5,
              AppText.w7,
              color: primary ? AppColors.white : AppColors.ink,
            ),
          ),
        ),
      ),
    ),
  );
}
