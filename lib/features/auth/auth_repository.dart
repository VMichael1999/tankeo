import 'user_profile.dart';

/// Autenticación simulada: cualquier credencial entra como Michael Dev.
abstract class AuthRepository {
  UserProfile get currentUser;
  Future<UserProfile> signIn({required String email, required String password});

  /// Crea la cuenta y la deja como usuario actual.
  Future<UserProfile> register(UserProfile profile);
}

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.delay = const Duration(milliseconds: 1500)});

  final Duration delay;
  UserProfile _current = profile;

  static const profile = UserProfile(
    name: 'Michael Dev',
    email: 'michaeldev@gmail.com',
  );

  @override
  UserProfile get currentUser => _current;

  @override
  Future<UserProfile> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(delay);
    return _current;
  }

  @override
  Future<UserProfile> register(UserProfile profile) async {
    await Future<void>.delayed(delay);
    return _current = profile;
  }
}
