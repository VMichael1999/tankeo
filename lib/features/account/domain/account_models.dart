import 'package:equatable/equatable.dart';

import '../../payment/domain/payment_method_strategy.dart';
import '../../payment/domain/tax_document.dart';

/// Carga pagada con su comprobante.
class FuelingRecord extends Equatable {
  const FuelingRecord({required this.document, this.isNew = false});

  final TaxDocument document;
  final bool isNew;

  DateTime get date => document.issuedAt;

  FuelingRecord seen() => FuelingRecord(document: document);

  @override
  List<Object?> get props => [document, isNew];
}

enum NotificationKind { cert, price, payment, points, appointment }

class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.kind,
    required this.at,
    required this.args,
    this.read = false,
    this.points = 0,
  });

  final int id;
  final NotificationKind kind;
  final DateTime at;
  final List<String> args;
  final bool read;
  final int points;

  AppNotification asRead() => AppNotification(
    id: id,
    kind: kind,
    at: at,
    args: args,
    read: true,
    points: points,
  );

  @override
  List<Object?> get props => [id, kind, at, args, read, points];
}

enum MovementKind { charge, welcome, redeem }

class PointsMovement extends Equatable {
  const PointsMovement({
    required this.kind,
    required this.arg,
    required this.delta,
    required this.at,
  });

  final MovementKind kind;
  final String arg;
  final int delta;
  final DateTime at;

  @override
  List<Object?> get props => [kind, arg, delta, at];
}

enum Reward {
  gnv5(500),
  coffee(300),
  wash(800),
  gasoline20(2000);

  const Reward(this.cost);
  final int cost;
}

enum SavedKind { yape, plin, card }

class SavedPaymentMethod extends Equatable {
  const SavedPaymentMethod({
    required this.id,
    required this.kind,
    required this.last,
    this.brand = 'visa',
    this.expiry = '',
    this.holder = '',
  });

  final String id;
  final SavedKind kind;
  final String last;
  final String brand;
  final String expiry;
  final String holder;

  PaymentMethod get method => switch (kind) {
    SavedKind.yape => PaymentMethod.yape,
    SavedKind.plin => PaymentMethod.plin,
    SavedKind.card => PaymentMethod.visa,
  };

  @override
  List<Object?> get props => [id, kind, last, brand, expiry, holder];
}

class BillingProfile extends Equatable {
  const BillingProfile({
    this.dni = '',
    this.name = '',
    this.ruc = '',
    this.businessName = '',
  });

  final String dni;
  final String name;
  final String ruc;
  final String businessName;

  @override
  List<Object?> get props => [dni, name, ruc, businessName];
}

enum VehicleFuel { dual, gasoline, gnv }

class AccountVehicle extends Equatable {
  const AccountVehicle({
    required this.name,
    required this.year,
    required this.plate,
    required this.fuel,
    required this.gasLevel,
    required this.gnvLevel,
    this.cylinder,
    this.certified = false,
  });

  final String name;
  final int year;
  final String plate;
  final VehicleFuel fuel;
  final int gasLevel;
  final int gnvLevel;
  final String? cylinder;
  final bool certified;

  bool get hasGnv => fuel != VehicleFuel.gasoline;
  bool get hasGasoline => fuel != VehicleFuel.gnv;

  @override
  List<Object?> get props => [
    name,
    year,
    plate,
    fuel,
    gasLevel,
    gnvLevel,
    cylinder,
    certified,
  ];
}

enum RepairShop { surco, miraflores, lince }

class Appointment extends Equatable {
  const Appointment({
    required this.shop,
    required this.day,
    required this.time,
  });

  final RepairShop shop;
  final DateTime day;
  final String time;

  @override
  List<Object?> get props => [shop, day, time];
}

class Inspection extends Equatable {
  const Inspection({required this.date, required this.annual});

  final DateTime date;

  /// `true` = inspección anual; `false` = conversión inicial.
  final bool annual;

  @override
  List<Object?> get props => [date, annual];
}
