import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../core/icons/icons.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/clock.dart';
import '../../core/widgets/account_widgets.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/primary_button.dart';
import '../account/bloc/certification_cubit.dart';
import '../account/domain/account_models.dart';
import '../vehicle/bloc/vehicle_cubit.dart';

String shopName(BuildContext context, RepairShop s) {
  final l = context.l10n;
  return switch (s) {
    RepairShop.surco => l.shopSurco,
    RepairShop.miraflores => l.shopMiraflores,
    RepairShop.lince => l.shopLince,
  };
}

String dayLabel(BuildContext context, DateTime d) {
  final names = context.l10n.weekdayShort.split(',');
  return '${names[d.weekday % 7]} ${d.day}';
}

/// Certificación GNV: cabecera teal (roja si venció) con el anillo de días,
/// datos del cilindro, inspecciones en línea de tiempo y «Agendar renovación».
class CertificationScreen extends StatelessWidget {
  const CertificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cert = context.watch<VehicleCubit>().state.certification;
    final cs = context.watch<CertificationCubit>().state;
    final now = context.read<Clock>().now();
    final expired = cs.expired;
    final days = expired
        ? now.difference(DateTime(2026, 10, 18)).inDays
        : cert.daysLeft(now);
    final until = expired ? DateTime(2026, 10, 18) : cert.validUntil;
    String d(DateTime x) =>
        DateFormat('d MMM yyyy', 'es').format(x).replaceAll('.', '');
    final colors = expired
        ? const [AppColors.danger, AppColors.premium]
        : const [AppColors.gnvFillB, AppColors.gnvFillC];
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(
                        20,
                        MediaQuery.paddingOf(context).top + 10,
                        20,
                        30,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: colors,
                        ),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(34),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => goBack(context),
                                child: Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: AppColors.white.withValues(
                                      alpha: .18,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Semantics(
                                    button: true,
                                    label: l.back,
                                    child: const Center(
                                      child: AppIconView(
                                        AppIcon.back,
                                        size: 20,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Text(
                                l.certScreenTitle,
                                style: AppText.ui(
                                  21,
                                  AppText.w8,
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          SizedBox(
                            width: 150,
                            height: 150,
                            child: CustomPaint(
                              painter: _Ring(expired ? 0 : days / 365),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '$days',
                                      style: AppText.ui(
                                        40,
                                        AppText.w8,
                                        color: AppColors.white,
                                        height: 1,
                                      ),
                                    ),
                                    Text(
                                      l.certDays,
                                      style: AppText.ui(
                                        13,
                                        AppText.w5,
                                        color: AppColors.white.withValues(
                                          alpha: .8,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.white.withValues(alpha: .2),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              expired ? l.certStatusExpired : l.certStatusValid,
                              style: AppText.ui(
                                13.5,
                                AppText.w7,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            expired
                                ? l.certExpiredDaysAgo(days)
                                : l.certDaysLeft(days),
                            style: AppText.ui(
                              13.5,
                              AppText.w5,
                              color: AppColors.white.withValues(alpha: .85),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (cs.appointment != null)
                            _AppointmentCard(a: cs.appointment!),
                          SectionLabel(l.certDataTitle),
                          SettingsGroup(
                            children: [
                              _Data(l.certChip, '4821-0037-19'),
                              _Data(l.certCylinderLabel, cert.cylinder),
                              _Data(l.certShop, l.shopSurco),
                              _Data(l.certValidUntil, d(until).toUpperCase()),
                              _Data(l.certNextReview, cert.nextReview),
                            ],
                          ),
                          SectionLabel(l.certTimeline),
                          AppCard(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                            child: Column(
                              children: [
                                for (var i = 0; i < cs.inspections.length; i++)
                                  _TimelineRow(
                                    inspection: cs.inspections[i],
                                    last: i == cs.inspections.length - 1,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomActionBar(
          child: PrimaryButton(
            label: l.certSchedule,
            color: expired ? AppColors.danger : AppColors.gnv,
            onPressed: () => _schedule(context),
          ),
        ),
      ),
    );
  }

  Future<void> _schedule(BuildContext context) async {
    final cubit = context.read<CertificationCubit>();
    final now = context.read<Clock>().now();
    final shopLabels = {
      for (final s in RepairShop.values) s: shopName(context, s),
    };
    final result = await showAppSheet<Appointment>(
      context,
      builder: (_) => _ScheduleSheet(now: now, shops: shopLabels),
    );
    if (result == null || !context.mounted) return;
    cubit.schedule(
      appointment: result,
      shopName: shopLabels[result.shop]!,
      dayLabel: dayLabel(context, result.day),
    );
  }
}

class _Data extends StatelessWidget {
  const _Data(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 13),
    child: Row(
      children: [
        Text(label, style: AppText.ui(14, AppText.w4, color: AppColors.ink2)),
        const Spacer(),
        Text(value, style: AppText.ui(14, AppText.w7)),
      ],
    ),
  );
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.inspection, required this.last});

  final Inspection inspection;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 22,
            child: Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.only(top: 3),
                  decoration: const BoxDecoration(
                    color: AppColors.gnv,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!last)
                  Expanded(
                    child: Container(width: 2, color: AppColors.gnvTrack),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    inspection.annual
                        ? l.certInspectionAnnual
                        : l.certInspectionConversion,
                    style: AppText.ui(14.5, AppText.w7),
                  ),
                  Text(
                    '${DateFormat('d MMM yyyy', 'es').format(inspection.date).replaceAll('.', '')} · ${l.certApproved}',
                    style: AppText.ui(12.5, AppText.w4, color: AppColors.ink2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({required this.a});

  final Appointment a;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gnvSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const AppIconView(AppIcon.calendar, size: 24, color: AppColors.gnv),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.certScheduled,
                  style: AppText.ui(15, AppText.w8, color: AppColors.gnv),
                ),
                Text(
                  l.certScheduledBody(
                    shopName(context, a.shop),
                    dayLabel(context, a.day),
                    a.time,
                  ),
                  style: AppText.ui(13, AppText.w5, color: AppColors.inkBody),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleSheet extends StatefulWidget {
  const _ScheduleSheet({required this.now, required this.shops});

  final DateTime now;
  final Map<RepairShop, String> shops;

  @override
  State<_ScheduleSheet> createState() => _ScheduleSheetState();
}

class _ScheduleSheetState extends State<_ScheduleSheet> {
  RepairShop shop = RepairShop.surco;
  int day = 1;
  String time = '9:00';

  static const times = ['8:00', '9:00', '10:30', '15:00', '16:30'];

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final days = [
      for (var i = 1; i <= 6; i++) widget.now.add(Duration(days: i)),
    ];
    Widget wrap(List<Widget> c) => Wrap(spacing: 8, runSpacing: 8, children: c);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.certScheduleTitle, style: AppText.ui(22, AppText.w8)),
        SectionLabel(l.certScheduleShop),
        wrap([
          for (final e in widget.shops.entries)
            ChoiceChipItem<RepairShop>(
              label: e.value,
              selected: shop == e.key,
              color: AppColors.gnv,
              onTap: () => setState(() => shop = e.key),
            ),
        ]),
        SectionLabel(l.certScheduleDay),
        wrap([
          for (var i = 0; i < days.length; i++)
            ChoiceChipItem<int>(
              label: dayLabel(context, days[i]),
              selected: day == i + 1,
              color: AppColors.gnv,
              onTap: () => setState(() => day = i + 1),
            ),
        ]),
        SectionLabel(l.certScheduleTime),
        wrap([
          for (final t in times)
            ChoiceChipItem<String>(
              label: t,
              selected: time == t,
              color: AppColors.gnv,
              onTap: () => setState(() => time = t),
            ),
        ]),
        const SizedBox(height: 22),
        PrimaryButton(
          label: l.certScheduleConfirm,
          color: AppColors.gnv,
          onPressed: () =>
              Navigator.of(context)
                  .pop(Appointment(shop: shop, day: days[day - 1], time: time)),
        ),
      ],
    );
  }
}

class _Ring extends CustomPainter {
  _Ring(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2 - 8;
    final c = size.center(Offset.zero);
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..color = AppColors.white.withValues(alpha: .22);
    canvas.drawCircle(c, r, track);
    final fill = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 12
      ..color = AppColors.white;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -math.pi / 2,
      2 * math.pi * progress.clamp(0, 1),
      false,
      fill,
    );
  }

  @override
  bool shouldRepaint(_Ring old) => old.progress != progress;
}
