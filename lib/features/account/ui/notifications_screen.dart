import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/icons/icons.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/clock.dart';
import '../../../core/domain/fuel_type.dart';
import '../../../core/widgets/account_widgets.dart';
import '../../../core/widgets/app_card.dart';
import '../../stations/bloc/stations_bloc.dart';
import '../bloc/notifications_cubit.dart';
import '../domain/account_models.dart';

/// Avisos con ícono de color, título, texto, hora y punto de no leído.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final state = context.watch<NotificationsCubit>().state;
    final now = context.read<Clock>().now();
    return AccountScaffold(
      title: l.notificationsTitle,
      trailing: GestureDetector(
        onTap: state.unread == 0
            ? null
            : context.read<NotificationsCubit>().readAll,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            l.notificationsReadAll,
            style: AppText.ui(
              14,
              AppText.w7,
              color: state.unread == 0 ? AppColors.ink3 : AppColors.primary,
            ),
          ),
        ),
      ),
      body: state.items.isEmpty
          ? Padding(
              padding: const EdgeInsets.only(top: 80),
              child: Center(
                child: Text(
                  l.notificationsEmpty,
                  style: AppText.ui(15, AppText.w5, color: AppColors.ink2),
                ),
              ),
            )
          : Column(
              children: [
                for (final n in state.items)
                  _Tile(n: n, now: now, onTap: () => _open(context, n)),
              ],
            ),
    );
  }

  void _open(BuildContext context, AppNotification n) {
    context.read<NotificationsCubit>().markRead(n.id);
    switch (n.kind) {
      case NotificationKind.cert || NotificationKind.appointment:
        context.push('/certification');
      case NotificationKind.price:
        context.read<StationsBloc>().add(const FilterChanged(FuelType.gnv));
        context.push('/map');
      case NotificationKind.payment:
        context.push('/history');
      case NotificationKind.points:
        context.push('/points');
    }
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.n, required this.now, required this.onTap});

  final AppNotification n;
  final DateTime now;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final (icon, fg, bg, title, body) = switch (n.kind) {
      NotificationKind.cert => (
        AppIcon.shield,
        AppColors.warning,
        AppColors.warningSoft,
        l.notifCertTitle,
        l.notifCertBody(n.args[0]),
      ),
      NotificationKind.price => (
        AppIcon.tag,
        AppColors.gnv,
        AppColors.gnvSoft,
        l.notifPriceTitle,
        l.notifPriceBody(n.args[0], n.args[1]),
      ),
      NotificationKind.payment => (
        AppIcon.receipt,
        AppColors.success,
        AppColors.successSoft,
        l.notifPaymentTitle,
        l.notifPaymentBody(
          n.args[0],
          n.args[1],
          n.args[2] == 'boleta'
              ? l.documentBoletaLower
              : l.documentFacturaLower,
        ),
      ),
      NotificationKind.points => (
        AppIcon.gift,
        AppColors.primary,
        AppColors.primarySoft,
        l.notifPointsTitle(n.points),
        l.notifPointsBody(n.args[0]),
      ),
      NotificationKind.appointment => (
        AppIcon.calendar,
        AppColors.gnv,
        AppColors.gnvSoft,
        l.notifApptTitle,
        l.notifApptBody(n.args[0], n.args[1], n.args[2]),
      ),
    };
    final diff = now.difference(n.at);
    final ago = diff.inMinutes < 1
        ? l.timeNow
        : diff.inMinutes < 60
        ? l.timeMinutesAgo(diff.inMinutes)
        : diff.inHours < 24
        ? l.timeHoursAgo(diff.inHours)
        : l.timeDaysAgo(diff.inDays);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AppCard(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(child: AppIconView(icon, size: 20, color: fg)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(title, style: AppText.ui(15, AppText.w7)),
                      ),
                      if (!n.read)
                        Container(
                          width: 9,
                          height: 9,
                          margin: const EdgeInsets.only(left: 8),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    body,
                    style: AppText.ui(13, AppText.w4, color: AppColors.ink2),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    ago,
                    style: AppText.ui(12, AppText.w5, color: AppColors.ink3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
