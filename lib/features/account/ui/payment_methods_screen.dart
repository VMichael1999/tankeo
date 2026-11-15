import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/icons/icons.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/toast/toast_service.dart';
import '../../../core/utils/clock.dart';
import '../../../core/widgets/account_widgets.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../payment/bloc/payment_bloc.dart';
import '../bloc/payment_methods_cubit.dart';
import '../domain/account_models.dart';
import '../domain/card_validator.dart';

String methodTitle(BuildContext context, SavedPaymentMethod m) {
  final l = context.l10n;
  return switch (m.kind) {
    SavedKind.yape => l.paymentYapeLabel,
    SavedKind.plin => l.paymentPlinLabel,
    SavedKind.card => '${_brand(context, m.brand)} •••• ${m.last}',
  };
}

String _brand(BuildContext context, String id) {
  final l = context.l10n;
  return switch (id) {
    'visa' => l.cardBrandVisa,
    'mastercard' => l.cardBrandMastercard,
    'amex' => l.cardBrandAmex,
    _ => l.cardBrandCard,
  };
}

/// Métodos de pago: predeterminado, usar, quitar y agregar tarjeta.
class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final s = context.watch<PaymentMethodsCubit>().state;
    return AccountScaffold(
      title: l.paymentsTitle,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final m in s.methods)
            _MethodTile(method: m, isDefault: m.id == s.defaultId),
          const SizedBox(height: 4),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _addCard(context),
            child: Container(
              height: 58,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AppIconView(
                    AppIcon.plus,
                    size: 19,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l.paymentAddCard,
                    style: AppText.ui(15, AppText.w7, color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppIconView(AppIcon.lock, size: 16, color: AppColors.ink3),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l.paymentSecurityNote,
                  style: AppText.ui(12.5, AppText.w4, color: AppColors.ink2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _addCard(BuildContext context) {
    final cubit = context.read<PaymentMethodsCubit>();
    final toast = context.read<ToastService>();
    final now = context.read<Clock>().now();
    return showAppSheet<void>(
      context,
      builder: (_) => _CardSheet(cubit: cubit, toast: toast, now: now),
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({required this.method, required this.isDefault});

  final SavedPaymentMethod method;
  final bool isDefault;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final m = method;
    final (fg, bg, icon) = switch (m.kind) {
      SavedKind.yape => (AppColors.yapeFg, AppColors.yapeBg, AppIcon.phone),
      SavedKind.plin => (AppColors.gnv, AppColors.gnvSoft, AppIcon.phone),
      SavedKind.card => (AppColors.visaFg, AppColors.thumbBg, AppIcon.card),
    };
    final detail = m.kind == SavedKind.card
        ? l.paymentCardDetail(m.expiry)
        : l.paymentPhoneDetail(m.last);
    final cubit = context.read<PaymentMethodsCubit>();
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(child: AppIconView(icon, size: 21, color: fg)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      methodTitle(context, m),
                      style: AppText.ui(16, AppText.w7),
                    ),
                    Text(
                      detail,
                      style: AppText.ui(
                        12.5,
                        AppText.w4,
                        color: AppColors.ink2,
                      ),
                    ),
                  ],
                ),
              ),
              if (isDefault)
                Container(
                  height: 26,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.successSoft,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Text(
                    l.paymentDefault,
                    style: AppText.ui(12, AppText.w7, color: AppColors.success),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (!isDefault)
                Expanded(
                  child: _SmallButton(
                    l.paymentUse,
                    primary: true,
                    onTap: () {
                      cubit.setDefault(m.id);
                      context.read<PaymentBloc>().add(
                        PaymentMethodChanged(m.method),
                      );
                      context.read<ToastService>().show(
                        AppToast.paymentDefault,
                        args: [methodTitle(context, m)],
                      );
                    },
                  ),
                ),
              if (!isDefault) const SizedBox(width: 10),
              Expanded(
                child: _SmallButton(
                  l.paymentRemove,
                  onTap: () {
                    final r = cubit.remove(m.id);
                    context.read<ToastService>().show(
                      r == RemoveResult.last
                          ? AppToast.paymentLast
                          : AppToast.paymentRemoved,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallButton extends StatelessWidget {
  const _SmallButton(this.label, {required this.onTap, this.primary = false});

  final String label;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onTap,
    child: Container(
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: primary ? AppColors.ink : AppColors.grayChip,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: AppText.ui(
          14,
          AppText.w7,
          color: primary ? AppColors.white : AppColors.ink,
        ),
      ),
    ),
  );
}

class _CardSheet extends StatefulWidget {
  const _CardSheet({
    required this.cubit,
    required this.toast,
    required this.now,
  });

  final PaymentMethodsCubit cubit;
  final ToastService toast;
  final DateTime now;

  @override
  State<_CardSheet> createState() => _CardSheetState();
}

class _CardSheetState extends State<_CardSheet> {
  final _number = TextEditingController();
  final _expiry = TextEditingController();
  final _cvv = TextEditingController();
  final _holder = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _number.dispose();
    _expiry.dispose();
    _cvv.dispose();
    _holder.dispose();
    super.dispose();
  }

  bool get _numberOk => CardValidator.luhn(_number.text);
  bool get _expiryOk => CardValidator.expiryValid(_expiry.text, widget.now);
  bool get _cvvOk => CardValidator.cvvValid(_cvv.text);
  bool get _holderOk => CardValidator.holderValid(_holder.text);

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final brand = CardValidator.brand(_number.text);
    final brandId = switch (brand) {
      CardBrand.visa => 'visa',
      CardBrand.mastercard => 'mastercard',
      CardBrand.amex => 'amex',
      CardBrand.other => 'card',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.cardTitle, style: AppText.ui(22, AppText.w8)),
        const SizedBox(height: 14),
        _Preview(
          brand: _brand(context, brandId),
          number: _number.text.isEmpty
              ? '•••• •••• •••• ••••'
              : CardValidator.format(_number.text),
          holder: _holder.text.isEmpty
              ? l.cardHolderPreview
              : _holder.text.toUpperCase(),
          expiry: _expiry.text.isEmpty ? l.cardExpiry : _expiry.text,
        ),
        const SizedBox(height: 18),
        LabeledField(
          label: l.cardNumber,
          controller: _number,
          keyboardType: TextInputType.number,
          formatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(19),
            _GroupFormatter(),
          ],
          error: _submitted && !_numberOk ? l.errCardNumber : null,
          onChanged: (_) => setState(() {}),
        ),
        Row(
          children: [
            Expanded(
              child: LabeledField(
                label: l.cardExpiry,
                controller: _expiry,
                keyboardType: TextInputType.number,
                formatters: [_ExpiryFormatter()],
                error: _submitted && !_expiryOk ? l.errCardExpiry : null,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LabeledField(
                label: l.cardCvv,
                controller: _cvv,
                keyboardType: TextInputType.number,
                obscure: true,
                maxLength: 4,
                formatters: [FilteringTextInputFormatter.digitsOnly],
                error: _submitted && !_cvvOk ? l.errCardCvv : null,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        LabeledField(
          label: l.cardHolder,
          controller: _holder,
          textCapitalization: TextCapitalization.characters,
          error: _submitted && !_holderOk ? l.errCardHolder : null,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 8),
        PrimaryButton(
          label: l.cardSave,
          color: AppColors.primary,
          onPressed: () {
            setState(() => _submitted = true);
            if (!(_numberOk && _expiryOk && _cvvOk && _holderOk)) return;
            final d = CardValidator.digits(_number.text);
            widget.cubit.addCard(
              last: d.substring(d.length - 4),
              brand: brandId,
              expiry: _expiry.text,
              holder: _holder.text.trim(),
            );
            widget.toast.show(AppToast.cardAdded);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({
    required this.brand,
    required this.number,
    required this.holder,
    required this.expiry,
  });

  final String brand;
  final String number;
  final String holder;
  final String expiry;

  @override
  Widget build(BuildContext context) => Container(
    height: 176,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.homeHdrB, AppColors.detailDark],
      ),
      borderRadius: BorderRadius.circular(22),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const AppIconView(
              AppIcon.chip,
              size: 26,
              color: AppColors.lcdAmber,
            ),
            const Spacer(),
            Text(
              brand,
              style: AppText.ui(17, AppText.w8, color: AppColors.white),
            ),
          ],
        ),
        const Spacer(),
        Text(
          number,
          style: AppText.mono(
            19,
            FontWeight.w500,
            color: AppColors.white,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Text(
                holder,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.ui(
                  12.5,
                  AppText.w6,
                  color: AppColors.white.withValues(alpha: .8),
                ),
              ),
            ),
            Text(
              expiry,
              style: AppText.ui(
                12.5,
                AppText.w6,
                color: AppColors.white.withValues(alpha: .8),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _GroupFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue o, TextEditingValue n) {
    final f = CardValidator.format(n.text);
    return TextEditingValue(
      text: f,
      selection: TextSelection.collapsed(offset: f.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue o, TextEditingValue n) {
    var d = n.text.replaceAll(RegExp(r'\D'), '');
    if (d.length > 4) d = d.substring(0, 4);
    final f = d.length > 2 ? '${d.substring(0, 2)}/${d.substring(2)}' : d;
    return TextEditingValue(
      text: f,
      selection: TextSelection.collapsed(offset: f.length),
    );
  }
}
