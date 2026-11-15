import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'app_modal.dart';
import 'safety_checklist_dialog.dart' show DialogButton;

/// Cola en un grifo lleno: anillo de progreso con la posición (2 → 1 → ✓),
/// minutos de espera y los autos antes que tú.
class QueueDialog extends StatelessWidget {
  const QueueDialog({
    super.key,
    required this.visible,
    required this.progress,
    required this.position,
    required this.minutesLeft,
    required this.stationName,
    required this.pumpNumber,
    required this.isle,
    required this.onLeave,
    required this.onGo,
  });

  final bool visible;
  final double progress;
  final int position;
  final int minutesLeft;
  final String stationName;
  final String pumpNumber;
  final String isle;
  final VoidCallback onLeave;
  final VoidCallback onGo;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final ready = position == 0;
    return AppModal(
      visible: visible,
      child: DialogCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              margin: const EdgeInsets.fromLTRB(0, 4, 0, 12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(120, 120),
                    painter: _RingPainter(progress),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        ready ? '✓' : '$position',
                        style: AppText.ui(
                          34,
                          AppText.w8,
                          color: ready ? AppColors.success : AppColors.ink,
                          height: 1,
                        ),
                      ),
                      Text(
                        ready ? l.queueYourTurn : l.queueInQueue,
                        style: AppText.ui(
                          11.5,
                          AppText.w4,
                          color: AppColors.ink2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              ready ? l.queueTitleReady(pumpNumber) : l.queueTitleBusy,
              style: AppText.ui(19, AppText.w8),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 3),
            Text(
              ready ? l.queueSubReady(isle) : l.queueSubWait(minutesLeft),
              textAlign: TextAlign.center,
              style: AppText.ui(13.5, AppText.w4, color: AppColors.ink2),
            ),
            const SizedBox(height: 14),
            _Kv(l.queueAhead, '$position'),
            _Kv(l.queueStation, stationName),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: DialogButton(label: l.queueLeave, onTap: onLeave),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DialogButton(
                    label: ready ? l.queueGo : l.queueWaiting,
                    primary: true,
                    onTap: ready ? onGo : null,
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

class _RingPainter extends CustomPainter {
  _RingPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(center: size.center(Offset.zero), radius: 50);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(rect.center, 50, p..color = AppColors.progressTrack);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      p..color = progress >= 1 ? AppColors.success : AppColors.primary,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
