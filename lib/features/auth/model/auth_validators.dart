import 'dart:math';

/// Auth / membership field validators and helpers.
abstract final class AuthValidators {
  static final emailRegex = RegExp(
    r'^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$',
  );

  /// Password: 6–20 letters and/or digits only.
  static final passwordRegex = RegExp(r'^[A-Za-z0-9]{6,20}$');

  static final publicIdRegex = RegExp(r'^[A-Za-z][A-Za-z0-9]{15}$');

  static bool isEmail(String value) => emailRegex.hasMatch(value.trim());

  static bool isPassword(String value) => passwordRegex.hasMatch(value);

  /// Digits only, length 9–11 (national mobile number).
  static String digitsOnly(String raw) =>
      raw.replaceAll(RegExp(r'[^0-9]'), '');

  static bool isNationalPhone(String raw) {
    final d = digitsOnly(raw);
    return d.length >= 9 && d.length <= 11;
  }

  /// Normalize country code to `+` + digits (default +82).
  static String normalizeCountryCode(String raw) {
    final d = digitsOnly(raw);
    if (d.isEmpty) return '+82';
    return '+$d';
  }

  static String makePublicId([Random? random]) {
    final rng = random ?? Random.secure();
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
    const alnum =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final buf = StringBuffer(letters[rng.nextInt(letters.length)]);
    for (var i = 0; i < 15; i++) {
      buf.write(alnum[rng.nextInt(alnum.length)]);
    }
    return buf.toString();
  }

  /// Synthetic Firebase Auth email for phone+password accounts.
  static String phoneAuthEmail({
    required String countryCode,
    required String nationalNumber,
  }) {
    final cc = digitsOnly(countryCode);
    final nn = digitsOnly(nationalNumber);
    return 'p${cc}_$nn@phone.hsdaily-toon.auth';
  }

  static String maskPasswordDisplay() => '********';
}
