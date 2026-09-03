import 'package:flutter/material.dart';

abstract final class AppColors {
  /// Figma `bg-black` base for all auth/splash screens.
  static const Color background = Color(0xFF000000);

  /// Figma ellipse fill `#897F39` at 34% opacity (fill-opacity="0.34").
  static const Color glowOrb = Color(0x57897F39);

  static const Color gold = Color(0xFFBA8220);
  static const Color goldLight = Color(0xFFD4AF37);
  static const Color textSecondary = Color(0xFFBEBEBE);
  static const Color textMuted = Color(0xFF808080);
  static const Color inputBackground = Color(0xFFFFFFFF);

  /// Verify OTP pill — light cream (top) → warm off-white (bottom).
  static const Color buttonGradientStart = Color(0xFFFFFCF7);
  static const Color buttonGradientEnd = Color(0xFFF0E8D8);

  /// Button label + chevrons on auth pills.
  static const Color buttonLabelGold = Color(0xFFA68942);

  /// Inactive page-indicator segment on dark backgrounds.
  static const Color indicatorInactive = Color(0xFF4D4D4D);

  /// OTP digit cell — vertical gradient (lighter at top).
  static const Color otpBoxGradientTop = Color(0xFFF5F5F5);
  static const Color otpBoxGradientBottom = Color(0xFFDCDCDC);
}
