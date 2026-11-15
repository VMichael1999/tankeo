import 'package:flutter/material.dart';

import '../../features/payment/domain/payment_method_strategy.dart';
import '../l10n/l10n.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'app_card.dart';

/// Medio de pago: Yape, Plin o tarjeta Visa. Usa texto sobre fondo suave en
/// lugar de logos de marca, que solo van con permiso de cada marca.
class PaymentMethodPicker extends StatelessWidget {
  const PaymentMethodPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final PaymentMethod selected;
  final ValueChanged<PaymentMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          for (final (i, m) in PaymentMethod.values.indexed)
            _Row(
              first: i == 0,
              method: m,
              title: m == PaymentMethod.visa
                  ? l.paymentVisaCard
                  : PaymentMethodStrategy.of(m).shortName,
              on: selected == m,
              onTap: () => onChanged(m),
            ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.first,
    required this.method,
    required this.title,
    required this.on,
    required this.onTap,
  });

  final bool first;
  final PaymentMethod method;
  final String title;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final strategy = PaymentMethodStrategy.of(method);
    final (bg, fg) = switch (method) {
      PaymentMethod.yape => (AppColors.yapeBg, AppColors.yapeFg),
      PaymentMethod.plin => (AppColors.gnvSoft, AppColors.gnv),
      PaymentMethod.visa => (AppColors.grayChip, AppColors.visaFg),
    };
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: on,
      label: title,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: first
                ? null
                : const Border(top: BorderSide(color: AppColors.line)),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  method == PaymentMethod.visa ? 'VISA' : strategy.shortName,
                  style: AppText.ui(
                    12,
                    AppText.w8,
                    color: fg,
                    fontStyle: method == PaymentMethod.visa
                        ? FontStyle.italic
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppText.ui(15.5, AppText.w7)),
                    Text(
                      strategy.detail,
                      style: AppText.ui(
                        12.5,
                        AppText.w4,
                        color: AppColors.ink2,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: on ? AppColors.primary : AppColors.grab,
                  shape: BoxShape.circle,
                ),
                child: on
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
