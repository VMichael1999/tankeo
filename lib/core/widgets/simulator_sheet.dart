import 'package:flutter/material.dart';

import '../../features/fueling/data/fault_simulator.dart';
import '../l10n/l10n.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'app_switch.dart';

/// Hoja «Simular errores»: certificación vencida, surtidor sin conexión y
/// pago rechazado, para probar los casos de falla.
Future<void> showSimulatorSheet(BuildContext context, FaultSimulator faults) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    backgroundColor: AppColors.loginSheet,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    builder: (_) => ListenableBuilder(
      listenable: faults,
      builder: (context, _) {
        final l = context.l10n;
        Widget row(String t, String sub, bool v, ValueChanged<bool> on) =>
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t, style: AppText.ui(15, AppText.w7)),
                        Text(
                          sub,
                          style: AppText.ui(
                            12.5,
                            AppText.w4,
                            color: AppColors.ink2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSwitch(value: v, onChanged: on),
                ],
              ),
            );
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: AppColors.checkBorder,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(l.simTitle, style: AppText.ui(20, AppText.w8)),
                  ),
                ),
                row(
                  l.simCert,
                  l.simCertSub,
                  faults.certExpired,
                  faults.setCertExpired,
                ),
                row(
                  l.simPump,
                  l.simPumpSub,
                  faults.pumpOffline,
                  faults.setPumpOffline,
                ),
                row(
                  l.simPay,
                  l.simPaySub,
                  faults.paymentDeclined,
                  faults.setPaymentDeclined,
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
