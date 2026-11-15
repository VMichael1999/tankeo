import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/icons/icons.dart';
import '../../../core/l10n/fuel_l10n.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/tankeo_tokens.dart';
import '../../../core/utils/money.dart';
import '../../../core/utils/volume_format.dart';
import '../../../core/widgets/app_spinner.dart';
import '../../../core/widgets/circle_icon_button.dart';
import '../../../core/widgets/dispense_progress.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/pump_lcd.dart';
import '../../../core/widgets/safety_hint.dart';
import '../bloc/fueling_bloc.dart';
import 'charge_view_model.dart';

/// Hoja del surtidor en vivo: pantalla LCD con importe, volumen y precio,
/// barra de progreso, indicadores y los botones Detener / Colgar manguera.
/// Se cierra con el chevron o tocando el velo; la carga sigue en segundo plano.
class ChargeSheet extends StatelessWidget {
  const ChargeSheet({super.key, required this.vm});

  final ChargeViewModel vm;

  @override
  Widget build(BuildContext context) {
    final open = vm.state.sheetOpen && vm.state.isBusy;
    final reduce = MediaQuery.disableAnimationsOf(context);
    final bloc = context.read<FuelingBloc>();
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              ignoring: !open,
              child: AnimatedOpacity(
                opacity: open ? 1 : 0,
                duration: reduce
                    ? Duration.zero
                    : const Duration(milliseconds: 300),
                child: GestureDetector(
                  onTap: () => bloc.add(const SheetToggled(false)),
                  child: ColoredBox(
                    color: AppColors.scrim.withValues(alpha: .45),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 112,
            bottom: 0,
            child: IgnorePointer(
              ignoring: !open,
              child: AnimatedSlide(
                offset: open ? Offset.zero : const Offset(0, 1.05),
                duration: reduce
                    ? Duration.zero
                    : const Duration(milliseconds: 420),
                curve: const Cubic(.2, .8, .2, 1),
                child: _Sheet(vm: vm),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Sheet extends StatelessWidget {
  const _Sheet({required this.vm});

  final ChargeViewModel vm;

  String _title(BuildContext context) {
    final l = context.l10n;
    final s = vm.state;
    if (s is Completed) return l.sheetComplete;
    if (s is HangingUp) return l.sheetHungUp;
    return l.sheetDispensing;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final s = vm.state;
    final gnv = vm.isGnv;
    final unit = vm.tank.unit;
    final dispensing = s is Dispensing;
    final done = vm.fullDone;
    final amount = vm.amount;
    final accent = gnv ? AppColors.gnv : AppColors.primary;
    final soft = gnv ? AppColors.gnvSoft : AppColors.primarySoft;
    final addedText = done
        ? l.sheetAddedDone(
            VolumeFormat.d3(vm.volume),
            unit,
            Money.format(amount),
          )
        : l.sheetAddedProgress(VolumeFormat.d3(vm.volume), unit);
    final status = switch (s) {
      Dispensing() => l.lcdStatusRunning,
      Completed() => l.lcdStatusCompleted,
      HangingUp() => l.lcdStatusHungUp,
      _ => l.lcdStatusReady,
    };
    final mins = vm.elapsed;
    final hint = done
        ? l.hintHangUp
        : gnv
        ? l.hintGnv
        : l.hintStill;
    final bloc = context.read<FuelingBloc>();
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(TankeoTokens.rSheetTop),
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 5,
                    margin: const EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      color: AppColors.grab,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                    child: Row(
                      children: [
                        CircleIconButton(
                          icon: AppIcon.down,
                          semanticLabel: l.minimize,
                          shadow: false,
                          background: AppColors.grayChip,
                          onPressed: () => bloc.add(const SheetToggled(false)),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 46),
                            child: Column(
                              children: [
                                Text(
                                  _title(context),
                                  style: AppText.ui(19, AppText.w8),
                                ),
                                Text(
                                  l.sheetSubtitle(
                                    vm.station.name,
                                    vm.pumpNumber,
                                  ),
                                  style: AppText.ui(
                                    13,
                                    AppText.w4,
                                    color: AppColors.ink2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 26, 22, 0),
                    child: PumpLcd(
                      gnv: gnv,
                      flowing: dispensing,
                      product: gnv
                          ? l.lcdProductGnv
                          : l.lcdProductGasoline(
                              vm.fuel.longLabel(context).toUpperCase(),
                            ),
                      status: status,
                      amount: Money.plain(amount),
                      volume: VolumeFormat.d3(vm.volume),
                      price: Money.plain(vm.price),
                      amountLabel: l.lcdAmount,
                      volumeLabel: l.lcdVolume(unit),
                      priceLabel: l.lcdPrice(unit),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
                    child: DispenseProgress(
                      progress: s.progress.toDouble(),
                      gnv: gnv,
                      animating: dispensing,
                      levelLabel: l.levelWord,
                      fromLabel: '${vm.quote.level.round()}%',
                      toLabel: '${vm.quote.targetLevel.round()}%',
                      trailing: dispensing
                          ? l.progressRemaining(Money.format(vm.remaining))
                          : s is Idle || s is Connecting
                          ? ''
                          : l.progressTotal(Money.format(amount)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 22),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: done ? context.tokens.ink : soft,
                        borderRadius: BorderRadius.circular(19),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppIconView(
                            done ? AppIcon.check : AppIcon.pump,
                            size: 16,
                            color: done ? AppColors.white : accent,
                            strokeWidth: 2,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            s is Dispensing && vm.volume == 0
                                ? l.sheetDispensingEllipsis
                                : addedText,
                            style: AppText.ui(
                              14.5,
                              AppText.w6,
                              color: done ? AppColors.white : accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
                    child: SafetyHint(text: hint),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 126,
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: _SheetStat(
                      value: '${vm.level.round()}',
                      unit: '%',
                      label: l.levelWord,
                    ),
                  ),
                  const VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: AppColors.line,
                  ),
                  Expanded(
                    child: _SheetStat(
                      value: '${vm.rangeKm}',
                      unit: 'km',
                      label: l.rangeWord,
                    ),
                  ),
                  const VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: AppColors.line,
                  ),
                  Expanded(
                    child: _SheetStat(value: _mmss(mins), label: l.timeWord),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 40,
            child: s is HangingUp
                ? const SizedBox(
                    height: 58,
                    child: Center(
                      child: AppSpinner(
                        size: 40,
                        stroke: 4,
                        color: AppColors.primary,
                        track: AppColors.primaryTrack,
                        period: Duration(milliseconds: 900),
                      ),
                    ),
                  )
                : PrimaryButton(
                    label: s is Completed ? l.sheetHangUp : l.sheetStop,
                    color: AppColors.ink,
                    dark: true,
                    onPressed: () => bloc.add(
                      s is Completed
                          ? const HangUpPressed()
                          : const StopPressed(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  String _mmss(Duration d) =>
      '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
}

class _SheetStat extends StatelessWidget {
  const _SheetStat({required this.value, this.unit, required this.label});

  final String value;
  final String? unit;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text.rich(
        TextSpan(
          text: value,
          style: AppText.ui(21, AppText.w8),
          children: [
            if (unit != null) ...[
              const WidgetSpan(child: SizedBox(width: 2)),
              TextSpan(
                text: unit,
                style: AppText.ui(13, AppText.w5, color: AppColors.ink2),
              ),
            ],
          ],
        ),
      ),
      const SizedBox(height: 2),
      Text(label, style: AppText.ui(12.5, AppText.w4, color: AppColors.ink2)),
    ],
  );
}
