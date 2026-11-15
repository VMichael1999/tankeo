import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../features/payment/domain/tax_document_strategy.dart';
import '../icons/icons.dart';
import '../l10n/l10n.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'app_card.dart';

/// Selector Boleta / Factura.
class TaxDocumentSegment extends StatelessWidget {
  const TaxDocumentSegment({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final TaxDocumentType selected;
  final ValueChanged<TaxDocumentType> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    Widget item(TaxDocumentType t, String label) {
      final on = selected == t;
      return Expanded(
        child: Semantics(
          button: true,
          selected: on,
          label: label,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onChanged(t),
            child: Container(
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: on
                    ? AppColors.ink
                    : AppColors.white.withValues(alpha: 0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                label,
                style: AppText.ui(
                  14,
                  AppText.w6,
                  color: on ? AppColors.white : AppColors.ink2,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          item(TaxDocumentType.boleta, l.documentBoleta),
          const SizedBox(width: 6),
          item(TaxDocumentType.factura, l.documentFactura),
        ],
      ),
    );
  }
}

/// Campos del comprobante: DNI y Nombre, o RUC y Razón social.
class TaxDocumentForm extends StatefulWidget {
  const TaxDocumentForm({
    super.key,
    required this.type,
    required this.id,
    required this.name,
    required this.onIdChanged,
    required this.onNameChanged,
  });

  final TaxDocumentType type;
  final String id;
  final String name;
  final ValueChanged<String> onIdChanged;
  final ValueChanged<String> onNameChanged;

  @override
  State<TaxDocumentForm> createState() => _TaxDocumentFormState();
}

class _TaxDocumentFormState extends State<TaxDocumentForm> {
  late final _id = TextEditingController(text: widget.id);
  late final _name = TextEditingController(text: widget.name);

  @override
  void didUpdateWidget(TaxDocumentForm old) {
    super.didUpdateWidget(old);
    if (old.type != widget.type) {
      _id.text = widget.id;
      _name.text = widget.name;
    }
  }

  @override
  void dispose() {
    _id.dispose();
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final boleta = widget.type == TaxDocumentType.boleta;
    return AppCard(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          _FieldRow(
            icon: boleta ? AppIcon.user : AppIcon.building,
            label: boleta ? l.fieldDni : l.fieldRuc,
            controller: _id,
            keyboardType: TextInputType.number,
            formatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(boleta ? 8 : 11),
            ],
            onChanged: widget.onIdChanged,
          ),
          _FieldRow(
            icon: boleta ? AppIcon.user : AppIcon.building,
            label: boleta ? l.fieldName : l.fieldBusinessName,
            controller: _name,
            border: true,
            onChanged: widget.onNameChanged,
          ),
        ],
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({
    required this.icon,
    required this.label,
    required this.controller,
    required this.onChanged,
    this.keyboardType,
    this.formatters,
    this.border = false,
  });

  final AppIcon icon;
  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? formatters;
  final bool border;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(
      border: border
          ? const Border(top: BorderSide(color: AppColors.line))
          : null,
    ),
    child: Row(
      children: [
        AppIconView(icon, size: 19, color: AppColors.ink2),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppText.ui(12, AppText.w4, color: AppColors.ink2),
              ),
              TextField(
                controller: controller,
                keyboardType: keyboardType,
                inputFormatters: formatters,
                onChanged: onChanged,
                cursorColor: AppColors.primary,
                style: AppText.ui(15, AppText.w6),
                decoration: const InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
