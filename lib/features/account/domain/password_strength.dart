/// Seguridad de la contraseña: 0 a 3 reglas cumplidas.
abstract final class PasswordStrength {
  static int score(String p) {
    var s = 0;
    if (p.length >= 8) s++;
    if (RegExp(r'[A-Z]').hasMatch(p) && RegExp(r'\d').hasMatch(p)) s++;
    if (p.length >= 12 || RegExp(r'[^A-Za-z0-9]').hasMatch(p)) s++;
    return s;
  }

  static bool isAcceptable(String p) => score(p) >= 2;
}
