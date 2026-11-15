import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../payment/data/payment_use_cases.dart';
import '../../payment/domain/tax_document.dart';

enum ReceiptStage { printing, stamped }

class ReceiptState extends Equatable {
  const ReceiptState({this.stage = ReceiptStage.printing});

  final ReceiptStage stage;

  bool get canShare => stage == ReceiptStage.stamped;

  @override
  List<Object?> get props => [stage];
}

/// Impresión del comprobante: a los 4.1 s cae el sello «PAGADO» y se
/// habilita «Compartir» (PDF y XML).
class ReceiptCubit extends Cubit<ReceiptState> {
  ReceiptCubit(this._share) : super(const ReceiptState());

  final ShareReceiptUseCase _share;
  Timer? _timer;

  static const paperDuration = Duration(milliseconds: 3400);
  static const paperDelay = Duration(milliseconds: 500);
  static const stampAt = Duration(milliseconds: 4100);

  void startPrinting({bool reduceMotion = false}) {
    _timer?.cancel();
    emit(const ReceiptState());
    _timer = Timer(
      reduceMotion ? const Duration(milliseconds: 100) : stampAt,
      () => emit(const ReceiptState(stage: ReceiptStage.stamped)),
    );
  }

  void share(TaxDocument document) {
    if (state.canShare) _share(document);
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
