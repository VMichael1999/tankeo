import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/domain/fuel_type.dart';
import '../../auth/user_profile.dart';
import '../../fueling/domain/fueling_result.dart';
import '../../payment/domain/payment_method_strategy.dart';
import '../../payment/domain/tax_document.dart';
import '../../payment/domain/tax_document_strategy.dart';
import '../../stations/data/station_repository.dart';
import '../domain/account_models.dart';

enum RecordFilter { all, gnv, gasoline, invoices }

class HistoryState extends Equatable {
  const HistoryState({required this.records, this.filter = RecordFilter.all});

  final List<FuelingRecord> records;
  final RecordFilter filter;

  /// Cargas visibles, de la más reciente a la más antigua.
  List<FuelingRecord> get visible {
    final list = records.where((r) {
      final d = r.document;
      return switch (filter) {
        RecordFilter.all => true,
        RecordFilter.gnv => d.result.fuel.isGnv,
        RecordFilter.gasoline => !d.result.fuel.isGnv,
        RecordFilter.invoices => d.type == TaxDocumentType.factura,
      };
    }).toList()..sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  HistoryState copyWith({List<FuelingRecord>? records, RecordFilter? filter}) =>
      HistoryState(
        records: records ?? this.records,
        filter: filter ?? this.filter,
      );

  @override
  List<Object?> get props => [records, filter];
}

/// Historial de cargas: cada pago agrega un registro con su comprobante.
class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit(StationRepository stations)
    : super(HistoryState(records: _seed(stations)));

  static List<FuelingRecord> _seed(StationRepository repo) {
    final all = repo.getStations();
    FuelingRecord rec(
      int station,
      FuelType fuel,
      double volume,
      DateTime at,
      TaxDocumentType type,
      PaymentMethod method,
    ) {
      final st = [for (var i = 0; i < 4; i++) all[i % all.length]];
      final result = FuelingResult.fromSession(
        fuel: fuel,
        stationIndex: station,
        levelBefore: 20,
        volume: volume,
        price: st[station].priceOf(fuel),
        createdAt: at,
      );
      final strategy = TaxDocumentStrategy.of(type);
      return FuelingRecord(
        document: TaxDocument.from(
          result: result,
          strategy: strategy,
          customer: Customer(
            id: strategy.defaultId,
            name: type == TaxDocumentType.boleta
                ? 'Michael Dev'
                : strategy.defaultName(
                    const UserProfile(
                      name: 'Michael Dev',
                      email: 'michaeldev@gmail.com',
                    ),
                  ),
          ),
          issuer: st[station],
          method: PaymentMethodStrategy.of(method),
        ),
      );
    }

    const b = TaxDocumentType.boleta;
    return [
      rec(
        0,
        FuelType.gnv,
        11.25,
        DateTime(2026, 11, 12, 18, 40),
        b,
        PaymentMethod.yape,
      ),
      rec(
        1,
        FuelType.regular,
        3.1,
        DateTime(2026, 11, 8, 9, 15),
        b,
        PaymentMethod.visa,
      ),
      rec(
        3,
        FuelType.gnv,
        9.8,
        DateTime(2026, 11, 3, 20, 5),
        TaxDocumentType.factura,
        PaymentMethod.visa,
      ),
      rec(
        2,
        FuelType.regular,
        5,
        DateTime(2026, 10, 27, 13, 30),
        b,
        PaymentMethod.plin,
      ),
      rec(
        0,
        FuelType.gnv,
        10.5,
        DateTime(2026, 10, 19, 19, 50),
        b,
        PaymentMethod.yape,
      ),
      rec(
        1,
        FuelType.premium,
        3.5,
        DateTime(2026, 10, 11, 8, 20),
        b,
        PaymentMethod.visa,
      ),
    ];
  }

  void setFilter(RecordFilter f) => emit(state.copyWith(filter: f));

  /// Agrega la carga recién pagada con la etiqueta «Nuevo».
  void add(TaxDocument document) => emit(
    state.copyWith(
      records: [
        FuelingRecord(document: document, isNew: true),
        ...state.records.map((r) => r.seen()),
      ],
    ),
  );
}
