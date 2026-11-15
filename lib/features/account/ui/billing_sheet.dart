import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/toast/toast_service.dart';
import '../../../core/widgets/account_widgets.dart';
import '../../../core/widgets/primary_button.dart';
import '../bloc/billing_cubit.dart';
import '../domain/account_models.dart';

/// Hoja «Datos de facturación»: DNI y nombre; RUC y razón social.
Future<void> showBillingSheet(BuildContext context) {
  final cubit = context.read<BillingProfileCubit>();
  final toast = context.read<ToastService>();
  return showAppSheet<void>(
    context,
    builder: (_) => _BillingSheet(cubit: cubit, toast: toast),
  );
}

class _BillingSheet extends StatefulWidget {
  const _BillingSheet({required this.cubit, required this.toast});

  final BillingProfileCubit cubit;
  final ToastService toast;

  @override
  State<_BillingSheet> createState() => _BillingSheetState();
}

class _BillingSheetState extends State<_BillingSheet> {
  late final _dni = TextEditingController(text: widget.cubit.state.dni);
  late final _name = TextEditingController(text: widget.cubit.state.name);
  late final _ruc = TextEditingController(text: widget.cubit.state.ruc);
  late final _biz = TextEditingController(
    text: widget.cubit.state.businessName,
  );

  @override
  void dispose() {
    _dni.dispose();
    _name.dispose();
    _ruc.dispose();
    _biz.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final digits = [FilteringTextInputFormatter.digitsOnly];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.billingTitle, style: AppText.ui(22, AppText.w8)),
        const SizedBox(height: 4),
        Text(
          l.billingNote,
          style: AppText.ui(13, AppText.w4, color: AppColors.ink2),
        ),
        SectionLabel(l.billingBoleta),
        LabeledField(
          label: l.fieldDni,
          controller: _dni,
          keyboardType: TextInputType.number,
          formatters: digits,
          maxLength: 8,
        ),
        LabeledField(
          label: l.fieldName,
          controller: _name,
          textCapitalization: TextCapitalization.words,
        ),
        SectionLabel(l.billingFactura),
        LabeledField(
          label: l.fieldRuc,
          controller: _ruc,
          keyboardType: TextInputType.number,
          formatters: digits,
          maxLength: 11,
        ),
        LabeledField(
          label: l.fieldBusinessName,
          controller: _biz,
          textCapitalization: TextCapitalization.characters,
        ),
        const SizedBox(height: 10),
        PrimaryButton(
          label: l.save,
          color: AppColors.primary,
          onPressed: _save,
        ),
      ],
    );
  }

  void _save() {
    final r = widget.cubit.save(
      BillingProfile(
        dni: _dni.text.trim(),
        name: _name.text.trim(),
        ruc: _ruc.text.trim(),
        businessName: _biz.text.trim(),
      ),
    );
    switch (r) {
      case BillingResult.saved:
        widget.toast.show(AppToast.billingSaved);
        Navigator.of(context).pop();
      case BillingResult.invalidDni:
        widget.toast.show(AppToast.invalidDni);
      case BillingResult.invalidRuc:
        widget.toast.show(AppToast.invalidRuc);
    }
  }
}
