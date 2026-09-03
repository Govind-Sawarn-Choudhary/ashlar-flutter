/// Temporary OTP credentials for staging only.
///
/// Enable with `--dart-define=DEV_AUTH=true` (never in production release).
abstract final class DevAuth {
  static const bool enabled = bool.fromEnvironment('DEV_AUTH', defaultValue: false);

  /// Test phone — exactly 10 digits.
  static const String phone = '8521429014';

  /// Test OTP — matches backend [TEMP_OTP_CODE].
  static const String otp = '123456';

  static bool matchesPhone(String value) =>
      enabled && value.trim() == phone;

  static bool matchesOtp(String entered) => enabled && entered == otp;
}
