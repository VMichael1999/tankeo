import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../icons/icons.dart';
import '../l10n/l10n.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'app_card.dart';

/// Certificación del cilindro de GNV con el chip Infogas.
class GnvCertificationCard extends StatelessWidget {
  const GnvCertificationCard({
    super.key,
    required this.cylinder,
    required this.validUntil,
    required this.daysLeft,
    required this.progress,
    required this.nextReview,
    this.expired = false,
  });

  final String cylinder;
  final DateTime validUntil;
  final int daysLeft;
  final double progress;
  final String nextReview;
  final bool expired;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final date = DateFormat(
      'd MMM yyyy',
      'es',
    ).format(validUntil).replaceAll('.', '').toUpperCase();
    return AppCard(
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.gnvSoft,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Center(
                  child: AppIconView(
                    AppIcon.shield,
                    size: 20,
                    color: AppColors.gnv,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.certTitle, style: AppText.ui(15.5, AppText.w7)),
                    Text(
                      l.certSubtitle(cylinder),
                      style: AppText.ui(
                        12.5,
                        AppText.w4,
                        color: AppColors.ink2,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 26,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: expired ? AppColors.dangerSoft : AppColors.successSoft,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Row(
                  children: [
                    AppIconView(
                      expired ? AppIcon.alert : AppIcon.check,
                      size: 13,
                      color: expired ? AppColors.danger : AppColors.success,
                      strokeWidth: 3,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      expired ? l.certExpiredBadge : l.certValid,
                      style: AppText.ui(
                        12,
                        AppText.w7,
                        color: expired ? AppColors.danger : AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 8,
              width: double.infinity,
              child: Stack(
                children: [
                  const Positioned.fill(
                    child: ColoredBox(color: AppColors.barTrack),
                  ),
                  FractionallySizedBox(
                    widthFactor: expired ? 0 : progress,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.gnvFillA, AppColors.gnv],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text.rich(
                TextSpan(
                  text: '${expired ? l.certExpiredOn : l.certAnnualExpires} ',
                  style: AppText.ui(12.5, AppText.w4, color: AppColors.ink2),
                  children: [
                    TextSpan(text: date, style: AppText.ui(12.5, AppText.w7)),
                  ],
                ),
              ),
              expired
                  ? Text(
                      l.certRenew,
                      style: AppText.ui(
                        12.5,
                        AppText.w7,
                        color: AppColors.danger,
                      ),
                    )
                  : Text.rich(
                      TextSpan(
                        text: '$daysLeft',
                        style: AppText.ui(12.5, AppText.w7),
                        children: [
                          TextSpan(
                            text: ' ${l.certDays}',
                            style: AppText.ui(
                              12.5,
                              AppText.w4,
                              color: AppColors.ink2,
                            ),
                          ),
                        ],
                      ),
                    ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.gnvSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const AppIconView(
                  AppIcon.calendar,
                  size: 16,
                  color: AppColors.gnv,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l.certReview(nextReview),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.ui(13, AppText.w6, color: AppColors.gnv),
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
