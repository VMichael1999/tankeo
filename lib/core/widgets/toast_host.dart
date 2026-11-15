import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../theme/tankeo_tokens.dart';
import '../toast/toast_service.dart';

/// Muestra los avisos de [ToastService] arriba de la pantalla durante 2.4 s.
class ToastHost extends StatefulWidget {
  const ToastHost({super.key, required this.service, required this.child});

  final ToastService service;
  final Widget child;

  @override
  State<ToastHost> createState() => _ToastHostState();
}

class _ToastHostState extends State<ToastHost> {
  StreamSubscription<ToastEvent>? _sub;
  Timer? _timer;
  ToastEvent? _event;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _sub = widget.service.events.listen(_show);
  }

  void _show(ToastEvent e) {
    _timer?.cancel();
    setState(() {
      _event = e;
      _visible = true;
    });
    _timer = Timer(const Duration(milliseconds: 2400), () {
      if (mounted) setState(() => _visible = false);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  String _text(BuildContext context, ToastEvent e) {
    final l = context.l10n;
    final a = e.args;
    return switch (e.kind) {
      AppToast.dieselInfo => l.toastDieselInfo,
      AppToast.finishCurrentCharge => l.toastFinishCurrentCharge,
      AppToast.payPreviousFirst => l.toastPayPreviousFirst,
      AppToast.arrived => l.toastArrived(a[0], a[1]),
      AppToast.gridBusy => l.toastGridBusy,
      AppToast.chipValidated => l.toastChipValidated,
      AppToast.chargeComplete => l.toastChargeComplete,
      AppToast.gnvPreferred => l.toastGnvPreferred,
      AppToast.gasolineOnly => l.toastGasolineOnly,
      AppToast.stationShared => l.toastStationShared(a[0]),
      AppToast.favoriteAdded => l.toastFavoriteAdded,
      AppToast.favoriteRemoved => l.toastFavoriteRemoved,
      AppToast.filtersInfo => l.toastFiltersInfo,
      AppToast.settingsUnavailable => l.toastSettingsUnavailable,
      AppToast.invalidDni => l.toastInvalidDni,
      AppToast.invalidRuc => l.toastInvalidRuc,
      AppToast.receiptShared => l.toastReceiptShared,
      AppToast.newPumpAssigned => l.toastNewPump(a[0]),
      AppToast.leftQueue => l.toastLeftQueue,
      AppToast.pickAnotherMethod => l.toastPickAnotherMethod,
      AppToast.filtersApplied => l.toastFiltersCount(
        int.parse(a[0]),
        a[0] == '1' ? l.toastFiltersMatchOne : l.toastFiltersMatchMany,
      ),
      AppToast.hiddenByFilters => l.toastHiddenByFilters,
      AppToast.apptConfirmed => l.toastApptConfirmed(a[0]),
      AppToast.redeemed => l.toastRedeemed(a[0]),
      AppToast.paymentDefault => l.toastPaymentDefault(a[0]),
      AppToast.paymentRemoved => l.toastPaymentRemoved,
      AppToast.paymentLast => l.toastPaymentLast,
      AppToast.cardAdded => l.toastCardAdded,
      AppToast.billingSaved => l.toastBillingSaved,
      AppToast.help => l.toastHelp,
      AppToast.passwordUpdated => l.toastPasswordUpdated,
      AppToast.codeSent => l.toastCodeSent,
      AppToast.near3d => l.toastNear3d,
      AppToast.paidByEmail => l.toastPaidByEmail(
        a[0],
        a[1] == 'boleta' ? l.documentBoletaLower : l.documentFacturaLower,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final e = _event;
    return Stack(
      children: [
        widget.child,
        if (e != null)
          Positioned(
            left: 22,
            right: 22,
            top: 62,
            child: IgnorePointer(
              child: AnimatedSlide(
                offset: _visible ? Offset.zero : const Offset(0, -8 / 44),
                duration: const Duration(milliseconds: 200),
                child: AnimatedOpacity(
                  opacity: _visible ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: context.tokens.navPill,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _text(context, e),
                      style: AppText.ui(
                        13.5,
                        AppText.w6,
                        color: AppColors.white,
                      ).copyWith(decoration: TextDecoration.none),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
