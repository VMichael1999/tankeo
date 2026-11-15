import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/icons/icons.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/tankeo_tokens.dart';
import '../../../core/toast/toast_service.dart';
import '../../../core/widgets/account_widgets.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../bloc/points_cubit.dart';
import '../domain/account_models.dart';

String _n(int v) => NumberFormat('#,##0', 'en_US').format(v);

/// Puntos Tankeo: saldo, nivel, canjes y movimientos.
class PointsScreen extends StatelessWidget {
  const PointsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final s = context.watch<PointsCubit>().state;
    final rewards = <(Reward, AppIcon, String)>[
      (Reward.gnv5, AppIcon.cylinder, l.pointsRewardGnv),
      (Reward.coffee, AppIcon.store, l.pointsRewardCoffee),
      (Reward.wash, AppIcon.drop, l.pointsRewardWash),
      (Reward.gasoline20, AppIcon.pump, l.pointsRewardGasoline),
    ];
    return AccountScaffold(
      title: l.pointsTitle,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryLight, AppColors.primary],
              ),
              borderRadius: BorderRadius.circular(TankeoTokens.rCard),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.pointsBalance,
                  style: AppText.ui(
                    13,
                    AppText.w6,
                    color: AppColors.white.withValues(alpha: .8),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _n(s.balance),
                      style: AppText.ui(40, AppText.w8, color: AppColors.white),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        l.pointsUnit,
                        style: AppText.ui(
                          14,
                          AppText.w6,
                          color: AppColors.white.withValues(alpha: .85),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      s.isGold ? l.pointsTierGold : l.pointsTierSilver,
                      style: AppText.ui(
                        13.5,
                        AppText.w7,
                        color: AppColors.white,
                      ),
                    ),
                    const Spacer(),
                    if (!s.isGold)
                      Text(
                        l.pointsToGold(_n(s.toGold)),
                        style: AppText.ui(
                          12.5,
                          AppText.w5,
                          color: AppColors.white.withValues(alpha: .85),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: s.progress,
                    minHeight: 8,
                    color: AppColors.white,
                    backgroundColor: AppColors.white.withValues(alpha: .28),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l.pointsRule,
                  style: AppText.ui(
                    12.5,
                    AppText.w5,
                    color: AppColors.white.withValues(alpha: .85),
                  ),
                ),
              ],
            ),
          ),
          SectionLabel(l.pointsRedeem),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              children: [
                for (var i = 0; i < rewards.length; i++) ...[
                  if (i > 0) const Divider(height: 1, color: AppColors.line),
                  _RewardRow(
                    reward: rewards[i].$1,
                    icon: rewards[i].$2,
                    label: rewards[i].$3,
                    balance: s.balance,
                  ),
                ],
              ],
            ),
          ),
          SectionLabel(l.pointsMovements),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              children: [
                for (var i = 0; i < s.movements.length; i++) ...[
                  if (i > 0) const Divider(height: 1, color: AppColors.line),
                  _MovementRow(m: s.movements[i]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardRow extends StatelessWidget {
  const _RewardRow({
    required this.reward,
    required this.icon,
    required this.label,
    required this.balance,
  });

  final Reward reward;
  final AppIcon icon;
  final String label;
  final int balance;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final ok = balance >= reward.cost;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: AppIconView(icon, size: 19, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppText.ui(15, AppText.w6)),
                Text(
                  l.pointsCost(_n(reward.cost)),
                  style: AppText.ui(12.5, AppText.w4, color: AppColors.ink2),
                ),
              ],
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: ok ? () => _redeem(context) : null,
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: ok ? AppColors.primary : AppColors.grayChip,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                ok
                    ? l.pointsRedeem
                    : l.pointsMissing(_n(reward.cost - balance)),
                style: AppText.ui(
                  13,
                  AppText.w7,
                  color: ok ? AppColors.white : AppColors.ink2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _redeem(BuildContext context) async {
    final l = context.l10n;
    final cubit = context.read<PointsCubit>();
    final toast = context.read<ToastService>();
    final ok = await showConfirmDialog(
      context,
      icon: AppIcon.gift,
      title: l.redeemTitle(label),
      body: l.redeemBody(_n(reward.cost), _n(balance - reward.cost)),
      cancelLabel: l.cancel,
      confirmLabel: l.redeemConfirm,
    );
    if (!ok) return;
    final code = cubit.redeem(reward, label);
    if (code != null) toast.show(AppToast.redeemed, args: [code]);
  }
}

class _MovementRow extends StatelessWidget {
  const _MovementRow({required this.m});

  final PointsMovement m;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final title = switch (m.kind) {
      MovementKind.charge => l.movementCharge(m.arg),
      MovementKind.welcome => l.movementWelcome,
      MovementKind.redeem => l.movementRedeem(m.arg),
    };
    final plus = m.delta > 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.ui(14.5, AppText.w6)),
                Text(
                  DateFormat('d MMM yyyy', 'es').format(m.at),
                  style: AppText.ui(12.5, AppText.w4, color: AppColors.ink2),
                ),
              ],
            ),
          ),
          Text(
            '${plus ? '+' : '−'}${_n(m.delta.abs())}',
            style: AppText.ui(
              15.5,
              AppText.w8,
              color: plus ? AppColors.success : AppColors.danger,
            ),
          ),
        ],
      ),
    );
  }
}
