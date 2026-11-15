import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  const UserProfile({required this.name, required this.email});

  final String name;
  final String email;

  String get firstName => name.split(' ').first;

  @override
  List<Object?> get props => [name, email];
}
