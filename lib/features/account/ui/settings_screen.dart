import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/domain/fuel_type.dart';
import '../../../core/icons/icons.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/toast/toast_service.dart';
import '../../../core/widgets/account_widgets.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../auth/auth_repository.dart';
import '../../fueling/bloc/fueling_bloc.dart';
import '../bloc/points_cubit.dart';
import '../bloc/settings_cubit.dart';
import 'billing_sheet.dart';

/// Ajustes (pestaña de la barra): perfil, accesos, preferencias y soporte.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final user = context.read<AuthRepository>().currentUser;
    final points = context.watch<PointsCubit>().state.balance;
    final s = context.watch<SettingsCubit>().state;
    final cubit = context.read<SettingsCubit>();
    final initials = user.name
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          MediaQuery.paddingOf(context).top + 18,
          20,
          140,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.settingsTitle, style: AppText.ui(28, AppText.w8)),
            const SizedBox(height: 16),
            AppCard(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryAvatar,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      initials,
                      style: AppText.ui(
                        22,
                        AppText.w8,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name, style: AppText.ui(18, AppText.w8)),
                        Text(
                          user.email,
                          style: AppText.ui(
                            13,
                            AppText.w4,
                            color: AppColors.ink2,
                          ),
                        ),
                        Text(
                          l.profilePhone,
                          style: AppText.ui(
                            13,
                            AppText.w4,
                            color: AppColors.ink2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => context.push('/points'),
                          child: Container(
                            height: 28,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const AppIconView(
                                  AppIcon.coin,
                                  size: 15,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  l.profilePoints(_fmt(points)),
                                  style: AppText.ui(
                                    13,
                                    AppText.w7,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SectionLabel(l.settingsAccount),
            SettingsGroup(
              children: [
                SettingsRow(
                  icon: AppIcon.car,
                  title: l.settingsVehicles,
                  onTap: () => context.push('/vehicles'),
                ),
                SettingsRow(
                  icon: AppIcon.wallet,
                  title: l.settingsPayments,
                  onTap: () => context.push('/payment-methods'),
                ),
                SettingsRow(
                  icon: AppIcon.building,
                  title: l.settingsBilling,
                  onTap: () => showBillingSheet(context),
                ),
                SettingsRow(
                  icon: AppIcon.receipt,
                  title: l.settingsHistory,
                  onTap: () => context.push('/history'),
                ),
                SettingsRow(
                  icon: AppIcon.shield,
                  title: l.settingsCert,
                  tint: AppColors.gnv,
                  tintBg: AppColors.gnvSoft,
                  onTap: () => context.push('/certification'),
                ),
                SettingsRow(
                  icon: AppIcon.coin,
                  title: l.settingsPoints,
                  onTap: () => context.push('/points'),
                ),
              ],
            ),
            SectionLabel(l.settingsPrefs),
            SettingsGroup(
              children: [
                SettingsRow(
                  icon: AppIcon.bell,
                  title: l.settingsNotifications,
                  switchValue: s.notifications,
                  onSwitch: cubit.setNotifications,
                ),
                SettingsRow(
                  icon: AppIcon.tag,
                  title: l.settingsPriceAlerts,
                  switchValue: s.priceAlerts,
                  onSwitch: cubit.setPriceAlerts,
                ),
                SettingsRow(
                  icon: AppIcon.calendar,
                  title: l.settingsCertReminder,
                  switchValue: s.certReminder,
                  onSwitch: cubit.setCertReminder,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l.settingsPreferredFuel,
                          style: AppText.ui(15, AppText.w6),
                        ),
                      ),
                      for (final k in TankKind.values)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: ChoiceChipItem<TankKind>(
                            label: k == TankKind.gnv
                                ? l.fuelGnv
                                : l.fuelGasoline,
                            selected: s.preferred == k,
                            color: k == TankKind.gnv
                                ? AppColors.gnv
                                : AppColors.primary,
                            onTap: () => _prefer(context, k),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            SectionLabel(l.settingsSupport),
            SettingsGroup(
              children: [
                SettingsRow(
                  icon: AppIcon.help,
                  title: l.settingsHelp,
                  onTap: () => context.read<ToastService>().show(AppToast.help),
                ),
                SettingsRow(
                  icon: AppIcon.exit,
                  title: l.settingsLogout,
                  tint: AppColors.danger,
                  tintBg: AppColors.dangerSoft,
                  titleColor: AppColors.danger,
                  showChevron: false,
                  onTap: () => _logout(context),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Center(
              child: Text(
                l.settingsVersion,
                style: AppText.ui(12.5, AppText.w5, color: AppColors.ink3),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l.settingsCredits,
              textAlign: TextAlign.center,
              style: AppText.ui(11.5, AppText.w4, color: AppColors.ink3),
            ),
          ],
        ),
      ),
    );
  }

  static String _fmt(int v) => v.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );

  void _prefer(BuildContext context, TankKind k) {
    context.read<SettingsCubit>().setPreferred(k);
    context.read<FuelingBloc>().add(FuelChanged(k));
    context.read<ToastService>().show(
      k == TankKind.gnv ? AppToast.gnvPreferred : AppToast.gasolineOnly,
    );
  }

  Future<void> _logout(BuildContext context) async {
    final l = context.l10n;
    final ok = await showConfirmDialog(
      context,
      icon: AppIcon.exit,
      tint: AppColors.danger,
      tintBg: AppColors.dangerSoft,
      title: l.logoutTitle,
      body: l.logoutBody,
      cancelLabel: l.cancel,
      confirmLabel: l.logoutConfirm,
    );
    if (ok && context.mounted) context.go('/login');
  }
}
