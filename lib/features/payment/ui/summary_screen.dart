import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/icons/icons.dart';
import '../../../core/l10n/fuel_l10n.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/money.dart';
import '../../../core/utils/volume_format.dart';
import '../../../core/toast/toast_service.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/error_dialog.dart';
import '../../../core/widgets/app_modal.dart';
import '../../../core/widgets/app_spinner.dart';
import '../../../core/widgets/payment_method_picker.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/safety_checklist_dialog.dart' show DialogButton;
import '../../../core/widgets/tax_document_form.dart';
import '../../fueling/data/fueling_session_repository.dart';
import '../../fueling/domain/fueling_result.dart';
import '../../stations/data/station_repository.dart';
import '../bloc/payment_bloc.dart';
import '../domain/invoice_calculator.dart';
import '../domain/payment_method_strategy.dart';
import '../domain/tax_document_strategy.dart';

/// Resumen de la carga: avance del nivel, detalle con IGV, tipo de
/// comprobante, medio de pago y la barra «Total · Pagar».
class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  final _pmKey = GlobalKey();
  PaymentDeclinedInfo? _lastDeclined;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final result =
        context.read<FuelingSessionRepository>().lastResult ??
        FuelingResult.sample();
    final station = context
        .read<StationRepository>()
        .getStations()[result.stationIndex];
    final amounts = InvoiceCalculator.fromTotal(result.total);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: BlocConsumer<PaymentBloc, PaymentState>(
        listenWhen: (a, b) => b.effect != null && a.effect != b.effect,
        listener: (context, state) {
          final bloc = context.read<PaymentBloc>();
          switch (state.effect!.kind) {
            case PaymentEffectKind.goHome:
              context.go('/home');
            case PaymentEffectKind.openReceipt:
              context.go('/receipt');
          }
          bloc.add(const PaymentEffectHandled());
        },
        builder: (context, pay) {
          final bloc = context.read<PaymentBloc>();
          final strategy = PaymentMethodStrategy.of(pay.method);
          final gnv = result.fuel.isGnv;
          final accent = gnv ? AppColors.gnv : AppColors.primary;
          final docName = pay.documentType == TaxDocumentType.boleta
              ? l.documentBoletaLower
              : l.documentFacturaLower;
          final product = result.fuel.longLabel(context);
          return Scaffold(
            backgroundColor: AppColors.bg,
            body: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: 56,
                  height: 52,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => context.go('/charge'),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Semantics(
                              label: l.back,
                              button: true,
                              child: const AppIconView(
                                AppIcon.back,
                                size: 20,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 40),
                            child: Text(
                              l.summaryTitle,
                              textAlign: TextAlign.center,
                              style: AppText.ui(18, AppText.w8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned.fill(
                  top: 108,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 130),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DoneCard(
                          result: result,
                          gnv: gnv,
                          accent: accent,
                          product: product,
                        ),
                        AppCard(
                          margin: const EdgeInsets.only(top: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 6,
                          ),
                          child: Column(
                            children: [
                              _Det(l.summaryStation, station.name),
                              _Det(
                                l.summaryDate,
                                DateFormat('d MMM yyyy HH:mm', 'es')
                                    .format(result.createdAt)
                                    .replaceAll('.', '')
                                    .toUpperCase(),
                              ),
                              _Det(l.summaryPump, station.assignedPump),
                              _Det(
                                '$product · ${VolumeFormat.d3(result.volume)} ${result.fuel.unit} × ${Money.format(result.price)}',
                                Money.format(amounts.total),
                                separated: true,
                              ),
                              _Det(
                                l.receiptTaxable,
                                Money.format(amounts.opGravada),
                              ),
                              _Det(l.summaryIgv, Money.format(amounts.igv)),
                              _Det(
                                l.receiptTotalWord,
                                Money.format(amounts.total),
                                total: true,
                              ),
                            ],
                          ),
                        ),
                        _Heading(l.summaryDocument),
                        TaxDocumentSegment(
                          selected: pay.documentType,
                          onChanged: (t) => bloc.add(DocumentTypeChanged(t)),
                        ),
                        TaxDocumentForm(
                          type: pay.documentType,
                          id: pay.customerId,
                          name: pay.customerName,
                          onIdChanged: (v) => bloc.add(CustomerIdChanged(v)),
                          onNameChanged: (v) =>
                              bloc.add(CustomerNameChanged(v)),
                        ),
                        _Heading(l.summaryPaymentMethod),
                        KeyedSubtree(
                          key: _pmKey,
                          child: PaymentMethodPicker(
                            selected: pay.method,
                            onChanged: (m) => bloc.add(PaymentMethodChanged(m)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 120,
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                      boxShadow: AppShadows.bottomBar,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 24, 18, 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l.receiptTotalWord,
                                style: AppText.ui(
                                  13,
                                  AppText.w4,
                                  color: AppColors.ink2,
                                ),
                              ),
                              Text(
                                Money.format(amounts.total),
                                style: AppText.ui(26, AppText.w8),
                              ),
                            ],
                          ),
                          const Spacer(),
                          SizedBox(
                            width: 178,
                            child: PrimaryButton(
                              label: l.summaryPay,
                              color: AppColors.primary,
                              onPressed: () => bloc.add(const PayPressed()),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Pago rechazado.
                Builder(
                  builder: (context) {
                    final d = pay.declined;
                    if (d != null) _lastDeclined = d;
                    final shown = _lastDeclined;
                    final name = shown == null
                        ? ''
                        : PaymentMethodStrategy.of(shown.method).shortName;
                    return ErrorDialog(
                      visible: d != null,
                      title: l.errPayTitle,
                      body: [
                        TextSpan(text: l.errPayBodyA(name)),
                        ErrorDialog.bold(Money.format(shown?.amount ?? 0)),
                        TextSpan(text: l.errPayBodyC),
                      ],
                      secondaryLabel: l.errPayChange,
                      primaryLabel: l.errRetry,
                      onSecondary: () {
                        bloc.add(const PaymentErrorDismissed());
                        final ctx = _pmKey.currentContext;
                        if (ctx != null) {
                          Scrollable.ensureVisible(
                            ctx,
                            duration: const Duration(milliseconds: 400),
                            alignment: .5,
                          );
                        }
                        context.read<ToastService>().show(
                          AppToast.pickAnotherMethod,
                        );
                      },
                      onPrimary: () {
                        bloc.add(const PaymentErrorDismissed());
                        bloc.add(const PayPressed());
                      },
                    );
                  },
                ),
                // Confirmar pago.
                AppModal(
                  visible: pay.step == PaymentStep.confirming,
                  child: DialogCard(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(l.confirmTitle, style: AppText.ui(19, AppText.w8)),
                        const SizedBox(height: 3),
                        Text(
                          station.name,
                          style: AppText.ui(
                            13.5,
                            AppText.w4,
                            color: AppColors.ink2,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 12, 0, 14),
                          child: Text(
                            Money.format(amounts.total),
                            style: AppText.ui(
                              42,
                              AppText.w8,
                              letterSpacing: -.84,
                            ),
                          ),
                        ),
                        _Kv(l.confirmPayWith, strategy.dialogLabel),
                        _Kv(
                          l.confirmDocument,
                          pay.documentType == TaxDocumentType.boleta
                              ? l.confirmBoleta(pay.customerId.trim())
                              : l.confirmFactura(pay.customerId.trim()),
                        ),
                        _Kv(
                          l.confirmProduct,
                          '${gnv ? l.fuelGnv : result.fuel.label(context)} · ${VolumeFormat.d3(result.volume)} ${result.fuel.unit}',
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: DialogButton(
                                label: l.cancel,
                                onTap: () => bloc.add(const PaymentCancelled()),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: DialogButton(
                                label: l.confirmYes,
                                primary: true,
                                onTap: () => bloc.add(const PaymentConfirmed()),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Procesando.
                AppModal(
                  visible: pay.step == PaymentStep.processing,
                  child: DialogCard(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(0, 16, 0, 18),
                          child: AppSpinner(
                            size: 56,
                            stroke: 5,
                            color: AppColors.primary,
                            track: AppColors.primaryTrack,
                            period: Duration(milliseconds: 900),
                          ),
                        ),
                        Text(
                          l.processingTitle,
                          style: AppText.ui(19, AppText.w8),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          l.processingSubtitle(
                            Money.format(amounts.total),
                            strategy.shortName,
                          ),
                          style: AppText.ui(
                            13.5,
                            AppText.w4,
                            color: AppColors.ink2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Éxito.
                AppModal(
                  visible: pay.step == PaymentStep.success,
                  child: DialogCard(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          margin: const EdgeInsets.fromLTRB(0, 4, 0, 16),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: AppIconView(
                              AppIcon.check,
                              size: 34,
                              color: AppColors.white,
                              strokeWidth: 3,
                            ),
                          ),
                        ),
                        Text(l.successTitle, style: AppText.ui(19, AppText.w8)),
                        const SizedBox(height: 3),
                        Text(
                          l.successSubtitle(
                            Money.format(amounts.total),
                            strategy.shortName,
                          ),
                          style: AppText.ui(
                            13.5,
                            AppText.w4,
                            color: AppColors.ink2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 28,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                l.successPoints(pay.points),
                                style: AppText.ui(
                                  12.5,
                                  AppText.w7,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(top: 16),
                          padding: const EdgeInsets.only(top: 16),
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(color: AppColors.line),
                            ),
                          ),
                          child: Text(
                            l.successAsk(docName),
                            textAlign: TextAlign.center,
                            style: AppText.ui(15, AppText.w7),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: DialogButton(
                                label: l.successNo,
                                onTap: () => bloc.add(const ReceiptDeclined()),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: DialogButton(
                                label: l.successView(docName),
                                primary: true,
                                onTap: () => bloc.add(const ReceiptRequested()),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 22, 4, 12),
    child: Text(text, style: AppText.ui(17, AppText.w8)),
  );
}

class _DoneCard extends StatelessWidget {
  const _DoneCard({
    required this.result,
    required this.gnv,
    required this.accent,
    required this.product,
  });

  final FuelingResult result;
  final bool gnv;
  final Color accent;
  final String product;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final from = result.levelBefore, to = result.levelAfter;
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: gnv ? AppColors.gnvSoft : AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: AppIconView(
                        AppIcon.check,
                        size: 13,
                        color: AppColors.white,
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.summaryDone, style: AppText.ui(17, AppText.w8)),
                  Text(
                    l.summaryDoneSub,
                    style: AppText.ui(13, AppText.w4, color: AppColors.ink2),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                product,
                style: AppText.ui(14, AppText.w4, color: AppColors.ink2),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '+${(to - from).round()}%',
                      style: AppText.ui(14, AppText.w8, color: accent),
                    ),
                    TextSpan(
                      text: ' ${l.summaryLoaded}',
                      style: AppText.ui(14, AppText.w4, color: AppColors.ink2),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: SizedBox(
              height: 10,
              child: LayoutBuilder(
                builder: (context, c) {
                  final w = c.maxWidth;
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: ColoredBox(
                          color: gnv
                              ? AppColors.gnvSoft
                              : AppColors.primaryTrack,
                        ),
                      ),
                      Positioned(
                        left: 0,
                        width: w * from / 100,
                        top: 0,
                        bottom: 0,
                        child: ColoredBox(
                          color: gnv
                              ? AppColors.gnvTrack
                              : AppColors.primaryTrack2,
                        ),
                      ),
                      Positioned(
                        left: w * from / 100,
                        width: w * (to - from) / 100,
                        top: 0,
                        bottom: 0,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text.rich(
                TextSpan(
                  text: '${l.summaryBefore} ',
                  style: AppText.ui(13.5, AppText.w4, color: AppColors.ink2),
                  children: [
                    TextSpan(
                      text: '${from.round()}%',
                      style: AppText.ui(13.5, AppText.w8, color: AppColors.ink),
                    ),
                  ],
                ),
              ),
              Text.rich(
                TextSpan(
                  text: '${l.summaryNow} ',
                  style: AppText.ui(13.5, AppText.w4, color: AppColors.ink2),
                  children: [
                    TextSpan(
                      text: '${to.round()}%',
                      style: AppText.ui(13.5, AppText.w8, color: accent),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.only(top: 14),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.line)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _S3(
                    value: VolumeFormat.d2(result.volume),
                    unit: result.fuel.unit,
                    label: l.summaryVolume,
                  ),
                ),
                Expanded(
                  child: _S3(
                    value: '${result.minutes}',
                    unit: 'min',
                    label: l.timeWord,
                  ),
                ),
                Expanded(
                  child: _S3(
                    value: '+${result.kmAdded}',
                    unit: 'km',
                    label: l.rangeWord,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _S3 extends StatelessWidget {
  const _S3({required this.value, required this.unit, required this.label});

  final String value;
  final String unit;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text.rich(
        TextSpan(
          text: value,
          style: AppText.ui(18, AppText.w8),
          children: [
            const WidgetSpan(child: SizedBox(width: 2)),
            TextSpan(
              text: unit,
              style: AppText.ui(12, AppText.w5, color: AppColors.ink2),
            ),
          ],
        ),
      ),
      Text(label, style: AppText.ui(12, AppText.w4, color: AppColors.ink2)),
    ],
  );
}

class _Det extends StatelessWidget {
  const _Det(this.k, this.v, {this.separated = false, this.total = false});

  final String k;
  final String v;
  final bool separated;
  final bool total;

  @override
  Widget build(BuildContext context) {
    final border = separated || total;
    return Container(
      margin: EdgeInsets.only(top: border ? 6 : 0),
      padding: EdgeInsets.fromLTRB(0, border ? 15 : 9, 0, total ? 12 : 9),
      decoration: BoxDecoration(
        border: border
            ? const Border(top: BorderSide(color: AppColors.line))
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Text(
              k,
              style: AppText.ui(
                total ? 16 : 14.5,
                total ? AppText.w8 : AppText.w4,
                color: total ? AppColors.ink : AppColors.ink2,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            v,
            style: AppText.ui(
              total ? 18 : 14.5,
              total ? AppText.w8 : AppText.w7,
              color: total ? AppColors.primary : AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _Kv extends StatelessWidget {
  const _Kv(this.k, this.v);

  final String k;
  final String v;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: const BoxDecoration(
      border: Border(top: BorderSide(color: AppColors.line)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(k, style: AppText.ui(14, AppText.w4, color: AppColors.ink2)),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            v,
            textAlign: TextAlign.right,
            style: AppText.ui(14, AppText.w7),
          ),
        ),
      ],
    ),
  );
}
