import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/icons/icons.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/tankeo_tokens.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/receipt_paper.dart';
import '../../../core/widgets/account_widgets.dart' show goBack;
import '../../payment/bloc/payment_bloc.dart';
import '../../payment/domain/tax_document.dart';
import '../../payment/domain/tax_document_strategy.dart';
import '../bloc/receipt_cubit.dart';

/// Comprobante: sube desde abajo, el papel sale de la impresora, cae el sello
/// «PAGADO» y se habilitan «Compartir» y «Listo».
class ReceiptScreen extends StatefulWidget {
  const ReceiptScreen({super.key, this.document});

  /// Comprobante guardado (desde el historial); si es `null`, el recién pagado.
  final TaxDocument? document;

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _paper = AnimationController(
    vsync: this,
    duration: ReceiptCubit.paperDuration,
  );
  final _paperKey = GlobalKey();
  final _slotKey = GlobalKey();
  Timer? _delay;
  bool _started = false;
  double _paperH = 0;
  double _slotH = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final reduce = MediaQuery.disableAnimationsOf(context);
    context.read<ReceiptCubit>().startPrinting(reduceMotion: reduce);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _measure();
      if (reduce) {
        _paper.value = 1;
      } else {
        _delay = Timer(
          ReceiptCubit.paperDelay,
          () => mounted ? _paper.forward() : null,
        );
      }
    });
  }

  void _measure() {
    final p = _paperKey.currentContext?.size;
    final s = _slotKey.currentContext?.size;
    if (p != null && s != null) {
      setState(() {
        _paperH = p.height;
        _slotH = s.height;
      });
    }
  }

  @override
  void dispose() {
    _delay?.cancel();
    _paper.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final pay = context.watch<PaymentBloc>().state;
    final doc = widget.document ?? pay.document;
    final stamped = context.watch<ReceiptCubit>().state.canShare;
    final boleta = (doc?.type ?? pay.documentType) == TaxDocumentType.boleta;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.receiptC,
        body: DecoratedBox(
          decoration: const BoxDecoration(gradient: TankeoTokens.receipt),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 72,
                child: Column(
                  children: [
                    Text(
                      boleta ? l.receiptYourBoleta : l.receiptYourFactura,
                      style: AppText.ui(20, AppText.w7, color: AppColors.white),
                    ),
                    Text(
                      stamped && doc != null
                          ? l.receiptPaidWith(
                              Money.format(doc.amounts.total),
                              doc.method.shortName,
                            )
                          : l.receiptPrinting,
                      style: AppText.ui(
                        13.5,
                        AppText.w4,
                        color: AppColors.white.withValues(alpha: .55),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 30,
                right: 30,
                top: 176,
                bottom: 150,
                child: ClipRect(
                  key: _slotKey,
                  child: OverflowBox(
                    alignment: Alignment.topCenter,
                    minHeight: 0,
                    maxHeight: double.infinity,
                    child: AnimatedBuilder(
                      animation: _paper,
                      child: doc == null
                          ? const SizedBox.shrink()
                          : KeyedSubtree(
                              key: _paperKey,
                              child: DefaultTextStyle(
                                style: AppText.mono(11, AppText.w4),
                                child: ReceiptPaper(
                                  document: doc,
                                  stamped: stamped,
                                ),
                              ),
                            ),
                      builder: (context, child) {
                        final end = (_slotH - _paperH - 10).clamp(
                          double.negativeInfinity,
                          0.0,
                        );
                        final t = const Cubic(
                          .45,
                          .05,
                          .4,
                          1,
                        ).transform(_paper.value);
                        final y = _paperH == 0
                            ? -2000.0
                            : -_paperH + (end + _paperH) * t;
                        return Transform.translate(
                          offset: Offset(0, y),
                          child: child,
                        );
                      },
                    ),
                  ),
                ),
              ),
              const Positioned(
                left: 18,
                right: 18,
                top: 142,
                height: 36,
                child: _Printer(),
              ),
              Positioned(
                left: 18,
                right: 18,
                bottom: 46,
                child: Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        label: l.receiptShare,
                        icon: AppIcon.share,
                        enabled: stamped,
                        dark: true,
                        onTap: () {
                          if (doc != null) {
                            context.read<ReceiptCubit>().share(doc);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionButton(
                        label: l.receiptDone,
                        enabled: true,
                        dark: false,
                        onTap: () => widget.document != null
                            ? goBack(context, '/history')
                            : context.go('/home'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Printer extends StatelessWidget {
  const _Printer();

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      Positioned.fill(
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.printerTop, AppColors.printerBottom],
            ),
            boxShadow: AppShadows.printer,
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 4,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: const BoxDecoration(
                  color: AppColors.printerEdge,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(18),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        left: 14,
        right: 14,
        bottom: -4,
        height: 4,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.printerSlot,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
      const Positioned(
        right: 16,
        top: 12,
        width: 6,
        height: 6,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: AppColors.primaryLight, blurRadius: 6),
            ],
          ),
        ),
      ),
    ],
  );
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.enabled,
    required this.dark,
    required this.onTap,
    this.icon,
  });

  final String label;
  final AppIcon? icon;
  final bool enabled;
  final bool dark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = dark ? AppColors.white : context.tokens.ink;
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? onTap : null,
        child: Opacity(
          opacity: enabled ? 1 : .35,
          child: Container(
            height: 58,
            decoration: BoxDecoration(
              color: dark
                  ? AppColors.white.withValues(alpha: .08)
                  : AppColors.white,
              borderRadius: BorderRadius.circular(29),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  AppIconView(icon!, size: 20, color: fg),
                  const SizedBox(width: 8),
                ],
                Text(label, style: AppText.ui(16, AppText.w7, color: fg)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
