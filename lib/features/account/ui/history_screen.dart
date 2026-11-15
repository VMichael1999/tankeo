import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/icons/icons.dart';
import '../../../core/l10n/fuel_l10n.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/tankeo_tokens.dart';
import '../../../core/utils/money.dart';
import '../../../core/utils/volume_format.dart';
import '../../../core/widgets/account_widgets.dart';
import '../../../core/widgets/app_card.dart';
import '../../payment/domain/tax_document_strategy.dart';
import '../bloc/history_cubit.dart';
import '../domain/account_models.dart';

/// Historial de cargas: resumen del mes, filtros y lista agrupada por mes.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final state = context.watch<HistoryCubit>().state;
    final all = state.visible;
    final groups = <String, List<FuelingRecord>>{};
    for (final r in all) {
      groups.putIfAbsent(DateFormat('yyyy-MM').format(r.date), () => []).add(r);
    }
    final filters = <(RecordFilter, String)>[
      (RecordFilter.all, l.filterAll),
      (RecordFilter.gnv, l.fuelGnv),
      (RecordFilter.gasoline, l.fuelGasoline),
      (RecordFilter.invoices, l.filterInvoices),
    ];
    return AccountScaffold(
      title: l.historyTitle,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (all.isNotEmpty) _MonthSummary(records: groups.values.first),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final (f, label) in filters)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChipItem<RecordFilter>(
                      label: label,
                      selected: state.filter == f,
                      onTap: () => context.read<HistoryCubit>().setFilter(f),
                    ),
                  ),
              ],
            ),
          ),
          if (all.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Center(
                child: Text(
                  l.historyEmpty,
                  style: AppText.ui(15, AppText.w5, color: AppColors.ink2),
                ),
              ),
            ),
          for (final entry in groups.entries) ...[
            SectionLabel(
              DateFormat(
                'MMMM yyyy',
                'es',
              ).format(DateTime.parse('${entry.key}-01')),
            ),
            for (final r in entry.value) _RecordTile(record: r),
          ],
        ],
      ),
    );
  }
}

class _MonthSummary extends StatelessWidget {
  const _MonthSummary({required this.records});

  final List<FuelingRecord> records;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final total = records.fold<double>(
      0,
      (a, r) => a + r.document.amounts.total,
    );
    final gnv = records
        .where((r) => r.document.result.fuel.isGnv)
        .fold<double>(0, (a, r) => a + r.document.amounts.total);
    final pct = total == 0 ? 0 : (gnv / total * 100).round();
    final month = DateFormat('MMMM', 'es').format(records.first.date);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.detailDark,
        borderRadius: BorderRadius.circular(TankeoTokens.rCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.historyMonthTotal(month),
            style: AppText.ui(
              13,
              AppText.w5,
              color: AppColors.white.withValues(alpha: .6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            Money.format(total),
            style: AppText.ui(32, AppText.w8, color: AppColors.white),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _Pill(l.historyChargesCount(records.length), AppColors.primary),
              const SizedBox(width: 8),
              _Pill(l.historyGnvShare(pct), AppColors.gnv),
            ],
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.text, this.color);

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    height: 28,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: color.withValues(alpha: .22),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Text(
      text,
      style: AppText.ui(12.5, AppText.w7, color: AppColors.white),
    ),
  );
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({required this.record});

  final FuelingRecord record;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = context.tokens;
    final d = record.document;
    final fuel = d.result.fuel;
    final color = fuel.color(t);
    final doc = d.type == TaxDocumentType.boleta
        ? l.documentBoleta
        : l.documentFactura;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.push('/receipt', extra: d),
      child: AppCard(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: AppIconView(
                  fuel.isGnv ? AppIcon.cylinder : AppIcon.pump,
                  size: 21,
                  color: color,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          d.issuer.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.ui(15, AppText.w7),
                        ),
                      ),
                      if (record.isNew) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            l.historyNew,
                            style: AppText.ui(
                              10.5,
                              AppText.w7,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    '${DateFormat("d MMM · h:mm a", "es").format(record.date)} · ${fuel.label(context)}',
                    style: AppText.ui(12.5, AppText.w4, color: AppColors.ink2),
                  ),
                  Text(
                    l.historyDocLine(
                      doc,
                      VolumeFormat.d2(d.result.volume),
                      fuel.unit,
                    ),
                    style: AppText.ui(12.5, AppText.w4, color: AppColors.ink3),
                  ),
                ],
              ),
            ),
            Text(
              Money.format(d.amounts.total),
              style: AppText.ui(15.5, AppText.w8),
            ),
          ],
        ),
      ),
    );
  }
}
